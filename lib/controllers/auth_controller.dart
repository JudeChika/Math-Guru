import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account_model.dart';

// =============================================================================
// RIVERPOD PROVIDERS FOR AUTH, USER ACCOUNT STREAM & CREDENTIAL MEMORY
// =============================================================================

final authControllerProvider =
StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

/// Real-time stream of the currently authenticated Firebase User.
final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Real-time stream of the user's rich `UserAccountModel` from Firestore (`users/{uid}`).
final currentUserAccountProvider = StreamProvider<UserAccountModel?>((ref) {
  final authState = ref.watch(firebaseAuthStateProvider);
  final User? user = authState.value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((snapshot) {
    if (!snapshot.exists) return null;
    return UserAccountModel.fromFirestore(snapshot);
  });
});

/// Holds cross-screen draft email & password so if a user types their email in Sign-Up
/// and switches to Sign-In (or logs out and comes back), their email & password are pre-filled!
class AuthDraftMemory extends StateNotifier<SavedDeviceCredential?> {
  AuthDraftMemory() : super(null);

  void setDraft({
    required String email,
    String password = '',
    String displayName = '',
    String role = 'student',
  }) {
    state = SavedDeviceCredential(
      email: email.trim(),
      password: password,
      displayName: displayName,
      role: role,
      lastUsedAt: DateTime.now(),
    );
  }
}

final authDraftMemoryProvider =
StateNotifierProvider<AuthDraftMemory, SavedDeviceCredential?>((ref) {
  return AuthDraftMemory();
});

// =============================================================================
// MAIN AUTH CONTROLLER (Directly replaces lib/controllers/auth_controller.dart)
// =============================================================================

class AuthController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  AuthController(this._ref) : super(const AsyncData(null));

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _savedAccountsKey = 'math_guru_saved_device_accounts_v1';
  static const String _lastActiveEmailKey = 'math_guru_last_active_email_v1';
  static const String _rememberMePrefKey = 'math_guru_remember_me_enabled_v1';

  // ---------------------------------------------------------------------------
  // 1. ENCRYPTED DEVICE CREDENTIAL VAULT (REMEMBERS EMAIL & PASSWORD AFTER LOGOUT)
  // ---------------------------------------------------------------------------

  /// Saves the user's email & password securely on this device so that even after
  /// logging out, the Sign-In screen automatically remembers and pre-fills them.
  Future<void> saveCredentialsToDeviceVault({
    required String email,
    required String password,
    String displayName = '',
    String role = 'student',
    bool rememberMe = true,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty) return;

    // Always update in-memory cross-screen draft
    _ref.read(authDraftMemoryProvider.notifier).setDraft(
      email: cleanEmail,
      password: rememberMe ? password : '',
      displayName: displayName,
      role: role,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_rememberMePrefKey, rememberMe);
    await prefs.setString(_lastActiveEmailKey, cleanEmail);

    if (!rememberMe || password.isEmpty) return;

    try {
      final List<SavedDeviceCredential> existing =
      await getSavedDeviceAccounts();
      existing.removeWhere(
              (item) => item.email.toLowerCase() == cleanEmail);

      existing.insert(
        0,
        SavedDeviceCredential(
          email: cleanEmail,
          password: password,
          displayName: displayName,
          role: role,
          lastUsedAt: DateTime.now(),
        ),
      );

      // Keep up to 5 most recent accounts on the device
      final List<Map<String, dynamic>> serialized =
      existing.take(5).map((e) => e.toJson()).toList();
      await _secureStorage.write(
        key: _savedAccountsKey,
        value: jsonEncode(serialized),
      );

      // Trigger Android / iOS native password autofill save
      TextInput.finishAutofillContext(shouldSave: true);
    } catch (e) {
      debugPrint('Secure storage write warning: $e');
    }
  }

  /// Loads all saved accounts (email + password) stored on this device.
  Future<List<SavedDeviceCredential>> getSavedDeviceAccounts() async {
    try {
      final String? rawJson =
      await _secureStorage.read(key: _savedAccountsKey);
      if (rawJson == null || rawJson.isEmpty) return [];
      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => SavedDeviceCredential.fromJson(
          Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('Secure storage read warning: $e');
      return [];
    }
  }

  /// Returns the most recently used credential on this device (or current draft)
  /// to automatically populate the Sign-In screen after logout.
  Future<SavedDeviceCredential?> getLastRememberedCredential() async {
    final SavedDeviceCredential? draft = _ref.read(authDraftMemoryProvider);
    final List<SavedDeviceCredential> savedList =
    await getSavedDeviceAccounts();

    if (draft != null && draft.email.isNotEmpty) {
      if (draft.password.isEmpty) {
        for (final acc in savedList) {
          if (acc.email.toLowerCase() == draft.email.toLowerCase()) {
            return acc;
          }
        }
      }
      return draft;
    }

    if (savedList.isNotEmpty) {
      return savedList.first;
    }
    return null;
  }

  /// Removes a single saved account from the device vault if the user explicitly taps "Remove".
  Future<void> removeSavedDeviceAccount(String email) async {
    try {
      final List<SavedDeviceCredential> existing =
      await getSavedDeviceAccounts();
      existing.removeWhere(
              (item) => item.email.toLowerCase() == email.trim().toLowerCase());
      await _secureStorage.write(
        key: _savedAccountsKey,
        value: jsonEncode(existing.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // 2. ANTI-ABUSE DELETED ACCOUNT TOMBSTONE REGISTRY (NO REPEAT FREE TRIAL)
  // ---------------------------------------------------------------------------

  /// Generates a deterministic SHA-256 hash of a normalized email address.
  String _hashEmail(String email) {
    final String normalized = email.trim().toLowerCase();
    return sha256.convert(utf8.encode(normalized)).toString();
  }

  /// Checks if this email address previously deleted a Math Guru account.
  Future<bool> hasPreviouslyDeletedAccount(String email) async {
    try {
      final String emailHash = _hashEmail(email);
      final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('deleted_accounts')
          .doc(emailHash)
          .get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 3. AUTOMATIC UNIQUE PROMO CODE GENERATOR FOR TEACHERS & SCHOOLS
  // ---------------------------------------------------------------------------

  Future<String> _generateUniquePromoCode({
    required String name,
    required UserRole role,
  }) async {
    final String prefix = role == UserRole.school ? 'SCH' : 'TCHR';
    final String cleanLetters =
    name.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    final String nameStem = cleanLetters.isEmpty
        ? 'PARTNER'
        : cleanLetters.substring(0, min(6, cleanLetters.length));

    final Random rng = Random.secure();
    for (int attempt = 0; attempt < 5; attempt++) {
      final int digits = 10 + rng.nextInt(90); // 10..99
      final String candidate = '$prefix-$nameStem$digits';
      final doc =
      await _firestore.collection('promo_codes').doc(candidate).get();
      if (!doc.exists) {
        return candidate;
      }
    }
    final int fallbackDigits = 100 + rng.nextInt(900);
    return '$prefix-$nameStem$fallbackDigits';
  }

  /// Validates a Teacher or School promo code entered by a Student.
  Future<Map<String, dynamic>?> validatePromoCode(String rawCode) async {
    final String code = rawCode.trim().toUpperCase();
    if (code.isEmpty) return null;
    final DocumentSnapshot<Map<String, dynamic>> doc =
    await _firestore.collection('promo_codes').doc(code).get();
    if (!doc.exists) return null;
    final Map<String, dynamic>? data = doc.data();
    if (data == null || data['active'] == false) return null;
    return data;
  }

  // ---------------------------------------------------------------------------
  // 4. ROLE-BASED SIGN UP (WITH 7-DAY FREE TRIAL & RETURNING-USER CHECK)
  // ---------------------------------------------------------------------------

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.student,
    String phoneNumber = '',
    String classLevel = 'JSS 3',
    String schoolName = '',
    String stateOfResidence = 'Lagos',
    String referralPromoCode = '',
    bool rememberMe = true,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();
    final String cleanName = name.trim();

    _ref.read(authDraftMemoryProvider.notifier).setDraft(
      email: cleanEmail,
      password: password,
      displayName: cleanName,
      role: role.value,
    );

    state = const AsyncLoading();
    bool isReturningDeletedUser = false;

    try {
      isReturningDeletedUser = await hasPreviouslyDeletedAccount(cleanEmail);

      final UserCredential userCredential =
      await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      final User? user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(cleanName);
        await user.sendEmailVerification().catchError((_) {});

        String? generatedPromoCode;
        if (role == UserRole.teacher || role == UserRole.school) {
          generatedPromoCode = await _generateUniquePromoCode(
            name: cleanName,
            role: role,
          );
        }

        String? validReferredByCode;
        String? promoOwnerUid;
        final String cleanReferral = referralPromoCode.trim().toUpperCase();
        if (role == UserRole.student && cleanReferral.isNotEmpty) {
          final Map<String, dynamic>? promoDoc =
          await validatePromoCode(cleanReferral);
          if (promoDoc != null) {
            validReferredByCode = cleanReferral;
            promoOwnerUid = promoDoc['ownerUid']?.toString();
          }
        }

        final DateTime now = DateTime.now();
        final DateTime trialEnd = isReturningDeletedUser
            ? now.subtract(const Duration(seconds: 10))
            : now.add(const Duration(days: 7));

        final UserAccountModel newAccount = UserAccountModel(
          uid: user.uid,
          name: cleanName,
          email: cleanEmail,
          role: role,
          phoneNumber: phoneNumber.trim(),
          classLevel: classLevel,
          schoolName: schoolName.trim(),
          stateOfResidence: stateOfResidence,
          subscriptionStatus: isReturningDeletedUser ? 'expired' : 'trial',
          subscriptionPlan:
          isReturningDeletedUser ? 'none' : 'free_trial',
          trialStartDate: now,
          trialEndDate: trialEnd,
          isReturningDeletedUser: isReturningDeletedUser,
          appliedPromoCode: validReferredByCode,
          promoCode: generatedPromoCode,
          promoDiscountPercent: role.promoRatePercent,
          minimumWithdrawalThreshold: role.minimumWithdrawalNaira,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set({
          ...newAccount.toMap(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (generatedPromoCode != null) {
          await _firestore
              .collection('promo_codes')
              .doc(generatedPromoCode)
              .set({
            'code': generatedPromoCode,
            'ownerUid': user.uid,
            'ownerName': cleanName,
            'ownerEmail': cleanEmail,
            'ownerRole': role.value,
            'discountPercent': role.promoRatePercent,
            'commissionPercent': role.promoRatePercent,
            'minimumWithdrawalNaira': role.minimumWithdrawalNaira,
            'referredStudentsCount': 0,
            'activeSubscriptionsCount': 0,
            'active': true,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }

        if (validReferredByCode != null && promoOwnerUid != null) {
          await _firestore
              .collection('promo_codes')
              .doc(validReferredByCode)
              .update({
            'referredStudentsCount': FieldValue.increment(1),
          }).catchError((_) {});

          await _firestore.collection('users').doc(promoOwnerUid).update({
            'referredStudentsCount': FieldValue.increment(1),
          }).catchError((_) {});
        }

        await saveCredentialsToDeviceVault(
          email: cleanEmail,
          password: password,
          displayName: cleanName,
          role: role.value,
          rememberMe: rememberMe,
        );
      }

      state = const AsyncData(null);
      return isReturningDeletedUser;
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. SIGN IN (REMEMBERS CREDENTIALS ON DEVICE & HYDRATES LEGACY ACCOUNTS)
  // ---------------------------------------------------------------------------

  Future<void> signIn({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    final String cleanEmail = email.trim().toLowerCase();
    state = const AsyncLoading();

    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      String displayName = cred.user?.displayName ?? '';
      String userRole = 'student';

      if (cred.user != null) {
        final DocumentReference<Map<String, dynamic>> userRef =
        _firestore.collection('users').doc(cred.user!.uid);
        final DocumentSnapshot<Map<String, dynamic>> snap =
        await userRef.get();

        if (!snap.exists) {
          final bool wasDeleted = await hasPreviouslyDeletedAccount(cleanEmail);
          final DateTime now = DateTime.now();
          await userRef.set({
            'uid': cred.user!.uid,
            'name': displayName.isNotEmpty ? displayName : 'Math Guru User',
            'email': cleanEmail,
            'role': 'student',
            'subscriptionStatus': wasDeleted ? 'expired' : 'trial',
            'subscriptionPlan': wasDeleted ? 'none' : 'free_trial',
            'trialStartDate': Timestamp.fromDate(now),
            'trialEndDate': Timestamp.fromDate(
              wasDeleted
                  ? now.subtract(const Duration(seconds: 10))
                  : now.add(const Duration(days: 7)),
            ),
            'isReturningDeletedUser': wasDeleted,
            'createdAt': FieldValue.serverTimestamp(),
          });
        } else {
          final data = snap.data() ?? {};
          displayName = (data['name'] ?? displayName).toString();
          userRole = (data['role'] ?? 'student').toString();

          if (data['trialEndDate'] == null) {
            final DateTime now = DateTime.now();
            await userRef.set({
              'role': userRole,
              'subscriptionStatus': data['subscriptionStatus'] ?? 'trial',
              'subscriptionPlan': data['subscriptionPlan'] ?? 'free_trial',
              'trialStartDate': Timestamp.fromDate(now),
              'trialEndDate':
              Timestamp.fromDate(now.add(const Duration(days: 7))),
            }, SetOptions(merge: true));
          }
        }
      }

      await saveCredentialsToDeviceVault(
        email: cleanEmail,
        password: password,
        displayName: displayName,
        role: userRole,
        rememberMe: rememberMe,
      );

      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // 6. SOCIAL LOGINS (GOOGLE & FACEBOOK WITH RETURNING-USER TOMBSTONE CHECK)
  // ---------------------------------------------------------------------------

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        state = const AsyncData(null);
        return;
      }
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final User u = userCredential.user!;
        final String cleanEmail = (u.email ?? '').trim().toLowerCase();
        final DocumentReference<Map<String, dynamic>> docRef =
        _firestore.collection('users').doc(u.uid);
        final DocumentSnapshot<Map<String, dynamic>> docSnap =
        await docRef.get();

        if (!docSnap.exists) {
          final bool wasDeleted = cleanEmail.isNotEmpty
              ? await hasPreviouslyDeletedAccount(cleanEmail)
              : false;
          final DateTime now = DateTime.now();

          await docRef.set({
            'uid': u.uid,
            'name': u.displayName ?? 'Math Guru Student',
            'email': cleanEmail,
            'role': 'student',
            'classLevel': 'JSS 3',
            'subscriptionStatus': wasDeleted ? 'expired' : 'trial',
            'subscriptionPlan': wasDeleted ? 'none' : 'free_trial',
            'trialStartDate': Timestamp.fromDate(now),
            'trialEndDate': Timestamp.fromDate(
              wasDeleted
                  ? now.subtract(const Duration(seconds: 10))
                  : now.add(const Duration(days: 7)),
            ),
            'isReturningDeletedUser': wasDeleted,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  Future<void> signInWithFacebook() async {
    state = const AsyncLoading();
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final OAuthCredential credential =
        FacebookAuthProvider.credential(result.accessToken!.tokenString);
        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

        if (userCredential.user != null) {
          final User u = userCredential.user!;
          final String cleanEmail = (u.email ?? '').trim().toLowerCase();
          final DocumentReference<Map<String, dynamic>> docRef =
          _firestore.collection('users').doc(u.uid);
          final DocumentSnapshot<Map<String, dynamic>> docSnap =
          await docRef.get();

          if (!docSnap.exists) {
            final bool wasDeleted = cleanEmail.isNotEmpty
                ? await hasPreviouslyDeletedAccount(cleanEmail)
                : false;
            final DateTime now = DateTime.now();

            await docRef.set({
              'uid': u.uid,
              'name': u.displayName ?? 'Math Guru Student',
              'email': cleanEmail,
              'role': 'student',
              'classLevel': 'JSS 3',
              'subscriptionStatus': wasDeleted ? 'expired' : 'trial',
              'subscriptionPlan': wasDeleted ? 'none' : 'free_trial',
              'trialStartDate': Timestamp.fromDate(now),
              'trialEndDate': Timestamp.fromDate(
                wasDeleted
                    ? now.subtract(const Duration(seconds: 10))
                    : now.add(const Duration(days: 7)),
              ),
              'isReturningDeletedUser': wasDeleted,
              'createdAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // 7. SIGN OUT (PRESERVES SAVED DEVICE CREDENTIALS SO RE-LOGIN IS 1-TAP!)
  // ---------------------------------------------------------------------------

  Future<void> signOut() async {
    state = const AsyncLoading();
    try {
      await GoogleSignIn().signOut().catchError((_) => null);
      await FacebookAuth.instance.logOut().catchError((_) {});
      await _auth.signOut();
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
    }
  }

  // ---------------------------------------------------------------------------
  // 8. PROFILE UPDATES & BANK ACCOUNT LINKING FOR TEACHERS / SCHOOLS
  // ---------------------------------------------------------------------------

  Future<void> updateProfile({
    required String name,
    String? phoneNumber,
    String? classLevel,
    String? schoolName,
    String? stateOfResidence,
  }) async {
    state = const AsyncLoading();
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        final Map<String, dynamic> updates = {
          'name': name.trim(),
        };
        if (phoneNumber != null) updates['phoneNumber'] = phoneNumber.trim();
        if (classLevel != null) updates['classLevel'] = classLevel;
        if (schoolName != null) updates['schoolName'] = schoolName.trim();
        if (stateOfResidence != null) {
          updates['stateOfResidence'] = stateOfResidence;
        }
        await _firestore.collection('users').doc(user.uid).update(updates);
      }
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
      rethrow;
    }
  }

  /// Links a Teacher's or School's Nigerian bank account for automated payouts.
  Future<void> updateAffiliateBankDetails({
    required String bankName,
    required String bankCode,
    required String accountNumber,
    required String accountName,
    String paystackRecipientCode = '',
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update({
      'bankName': bankName.trim(),
      'bankCode': bankCode.trim(),
      'accountNumber': accountNumber.trim(),
      'accountName': accountName.trim(),
      'paystackRecipientCode': paystackRecipientCode.trim(),
      'bankUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------------------------------------------------------------------
  // 9. SUBSCRIPTION ACTIVATION + AUTOMATIC TEACHER (10%) / SCHOOL (15%) CREDIT
  // ---------------------------------------------------------------------------

  Future<void> activateSubscriptionAfterPayment({
    required bool isAnnual,
    required String paymentProvider,
    required String transactionReference,
    required double amountPaidNaira,
    String? promoCodeUsed,
  }) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final DateTime now = DateTime.now();
    final DateTime expiry = isAnnual
        ? now.add(const Duration(days: 365))
        : now.add(const Duration(days: 30));

    final DocumentReference<Map<String, dynamic>> userRef =
    _firestore.collection('users').doc(user.uid);

    await userRef.set({
      'subscriptionStatus': 'active',
      'subscriptionPlan': isAnnual ? 'annual' : 'monthly',
      'subscriptionExpiryDate': Timestamp.fromDate(expiry),
      'lastPaymentReference': transactionReference,
      'lastPaymentProvider': paymentProvider,
      'lastAmountPaidNaira': amountPaidNaira,
      'lastSubscribedAt': FieldValue.serverTimestamp(),
      if (promoCodeUsed != null && promoCodeUsed.trim().isNotEmpty)
        'appliedPromoCode': promoCodeUsed.trim().toUpperCase(),
    }, SetOptions(merge: true));

    final String cleanCode = (promoCodeUsed ?? '').trim().toUpperCase();
    if (cleanCode.isNotEmpty) {
      final Map<String, dynamic>? promoData =
      await validatePromoCode(cleanCode);
      if (promoData != null) {
        final String ownerUid = (promoData['ownerUid'] ?? '').toString();
        final UserRole ownerRole =
        UserRole.fromString(promoData['ownerRole']?.toString());

        final breakdown = SubscriptionPricing.calculateCheckoutBreakdown(
          isAnnual: isAnnual,
          promoOwnerRole: ownerRole,
        );
        final double commissionNaira = breakdown.affiliateCommission;

        if (ownerUid.isNotEmpty && commissionNaira > 0) {
          await _firestore.collection('users').doc(ownerUid).set({
            'walletBalance': FieldValue.increment(commissionNaira),
            'totalEarned': FieldValue.increment(commissionNaira),
            'activeSubscribedReferralsCount': FieldValue.increment(1),
          }, SetOptions(merge: true));

          await _firestore.collection('promo_codes').doc(cleanCode).set({
            'activeSubscriptionsCount': FieldValue.increment(1),
            'totalCommissionGenerated': FieldValue.increment(commissionNaira),
          }, SetOptions(merge: true));

          await _firestore.collection('affiliate_commissions').add({
            'promoCode': cleanCode,
            'affiliateOwnerUid': ownerUid,
            'affiliateRole': ownerRole.value,
            'studentUid': user.uid,
            'studentEmail': user.email ?? '',
            'plan': isAnnual ? 'annual' : 'monthly',
            'basePriceNaira': breakdown.basePrice,
            'studentDiscountNaira': breakdown.discountAmount,
            'studentPaidNaira': amountPaidNaira,
            'commissionCreditedNaira': commissionNaira,
            'transactionReference': transactionReference,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 10. AUTOMATED TEACHER (≥ ₦20,000) & SCHOOL (≥ ₦50,000) WITHDRAWAL REQUEST
  // ---------------------------------------------------------------------------

  Future<String> requestAffiliateWithdrawal({
    required UserAccountModel account,
  }) async {
    final double minThreshold = account.role.minimumWithdrawalNaira;
    if (account.walletBalance < minThreshold) {
      throw Exception(
        'Minimum withdrawal threshold for a ${account.role.displayLabel} is ₦${minThreshold.toStringAsFixed(0)}.',
      );
    }
    if (account.accountNumber.trim().length < 10 ||
        account.bankName.trim().isEmpty) {
      throw Exception(
        'Please link and verify your 10-digit Nigerian Bank Account (NUBAN) before requesting a payout.',
      );
    }

    final String requestId =
        'WDR-${DateTime.now().millisecondsSinceEpoch}-${account.uid.substring(0, 5).toUpperCase()}';

    final DocumentReference<Map<String, dynamic>> userRef =
    _firestore.collection('users').doc(account.uid);
    final DocumentReference<Map<String, dynamic>> reqRef =
    _firestore.collection('withdrawal_requests').doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> freshUser =
      await transaction.get(userRef);
      final double currentBal =
          (freshUser.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;
      if (currentBal < minThreshold) {
        throw Exception('Insufficient wallet balance for withdrawal.');
      }

      transaction.update(userRef, {
        'walletBalance': 0.0,
        'totalWithdrawn': FieldValue.increment(currentBal),
        'lastWithdrawalAt': FieldValue.serverTimestamp(),
      });

      transaction.set(reqRef, {
        'requestId': requestId,
        'uid': account.uid,
        'name': account.name,
        'email': account.email,
        'role': account.role.value,
        'promoCode': account.promoCode ?? '',
        'amountNaira': currentBal,
        'bankName': account.bankName,
        'bankCode': account.bankCode,
        'accountNumber': account.accountNumber,
        'accountName': account.accountName,
        'paystackRecipientCode': account.paystackRecipientCode,
        'status': 'processing_auto_transfer',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return requestId;
  }

  // ---------------------------------------------------------------------------
  // 11. ANTI-ABUSE ACCOUNT DELETION (SAVES PERMANENT TOMBSTONE BEFORE DELETING)
  // ---------------------------------------------------------------------------

  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        final String cleanEmail = (user.email ?? '').trim().toLowerCase();
        if (cleanEmail.isNotEmpty) {
          final String emailHash = _hashEmail(cleanEmail);
          await _firestore.collection('deleted_accounts').doc(emailHash).set({
            'emailHash': emailHash,
            'email': cleanEmail,
            'previousUid': user.uid,
            'hadUsedFreeTrial': true,
            'deletedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
      }
      state = const AsyncData(null);
    } catch (e, stackTrace) {
      state = AsyncError(_handleAuthError(e), stackTrace);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ERROR MAPPER
  // ---------------------------------------------------------------------------

  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found':
          return 'No account found for that email. Please Sign Up first.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Incorrect email or password. Please check and try again.';
        case 'email-already-in-use':
          return 'This email is already registered! Tap "Sign In" below — we have already filled in your email for you.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Password must be at least 6 characters long.';
        case 'requires-recent-login':
          return 'For security, please sign out and sign back in before deleting your account.';
        default:
          return e.message ?? 'An authentication error occurred.';
      }
    }
    return e.toString();
  }
}