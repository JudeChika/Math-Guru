import 'package:cloud_firestore/cloud_firestore.dart';

/// Supported user roles in Math Guru.
/// - [student]: Standard learner account; gets 7-day trial (if first time) and can apply a Teacher/School promo code.
/// - [teacher]: Affiliate teacher account; receives a unique `TCHR-XXXX` promo code (10% student discount + 10% commission, ₦20,000 minimum withdrawal).
/// - [school]: Partner school account; receives a unique `SCH-XXXX` promo code (15% student discount + 15% commission, ₦50,000 minimum withdrawal).
enum UserRole {
  student,
  teacher,
  school;

  String get value => name;

  static UserRole fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'teacher':
        return UserRole.teacher;
      case 'school':
        return UserRole.school;
      default:
        return UserRole.student;
    }
  }

  String get displayLabel {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher (Affiliate)';
      case UserRole.school:
        return 'School Partner';
    }
  }

  /// Discount & Commission percentage for this role's promo code.
  double get promoRatePercent {
    switch (this) {
      case UserRole.teacher:
        return 10.0; // 10% off for student + 10% credited to teacher
      case UserRole.school:
        return 15.0; // 15% off for student + 15% credited to school
      case UserRole.student:
        return 0.0;
    }
  }

  /// Minimum Naira balance required before "Withdraw to Bank" unlocks.
  double get minimumWithdrawalNaira {
    switch (this) {
      case UserRole.teacher:
        return 20000.0; // ₦20,000 minimum for Teachers
      case UserRole.school:
        return 50000.0; // ₦50,000 minimum for Schools
      case UserRole.student:
        return 0.0;
    }
  }
}

/// Official Naira Subscription Pricing Constants.
class SubscriptionPricing {
  static const double monthlyBasePriceNaira = 1500.0; // ₦1,500 / month
  static const double annualBasePriceNaira = 12000.0; // ₦12,000 / annum

  static const double teacherPromoRate = 0.10; // 10%
  static const double schoolPromoRate = 0.15; // 15%

  static const double teacherMinWithdrawalNaira = 20000.0; // ₦20,000
  static const double schoolMinWithdrawalNaira = 50000.0; // ₦50,000

  /// Calculates final student price and affiliate commission for a given base price and promo role.
  static ({
  double basePrice,
  double discountAmount,
  double finalStudentPrice,
  double affiliateCommission,
  double discountPercent,
  }) calculateCheckoutBreakdown({
    required bool isAnnual,
    UserRole? promoOwnerRole,
  }) {
    final double base =
    isAnnual ? annualBasePriceNaira : monthlyBasePriceNaira;
    if (promoOwnerRole == null || promoOwnerRole == UserRole.student) {
      return (
      basePrice: base,
      discountAmount: 0.0,
      finalStudentPrice: base,
      affiliateCommission: 0.0,
      discountPercent: 0.0,
      );
    }

    final double rate = promoOwnerRole == UserRole.school
        ? schoolPromoRate
        : teacherPromoRate;
    final double cut = base * rate;
    return (
    basePrice: base,
    discountAmount: cut,
    finalStudentPrice: base - cut,
    affiliateCommission: cut,
    discountPercent: rate * 100.0,
    );
  }
}

/// Represents a saved credential entry on this device so the user can log back in after logging out without retyping.
class SavedDeviceCredential {
  final String email;
  final String password;
  final String displayName;
  final String role;
  final DateTime lastUsedAt;

  const SavedDeviceCredential({
    required this.email,
    required this.password,
    this.displayName = '',
    this.role = 'student',
    required this.lastUsedAt,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
    'displayName': displayName,
    'role': role,
    'lastUsedAt': lastUsedAt.toIso8601String(),
  };

  factory SavedDeviceCredential.fromJson(Map<String, dynamic> json) {
    return SavedDeviceCredential(
      email: (json['email'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      displayName: (json['displayName'] ?? '').toString(),
      role: (json['role'] ?? 'student').toString(),
      lastUsedAt: DateTime.tryParse((json['lastUsedAt'] ?? '').toString()) ??
          DateTime.now(),
    );
  }
}

/// Complete Firestore User Profile, Subscription, and Affiliate Wallet Model.
class UserAccountModel {
  final String uid;
  final String name;
  final String email;
  final UserRole role;

  // Rich Student / Teacher / School Profile Fields
  final String phoneNumber;
  final String classLevel; // e.g., 'JSS 1', 'JSS 2', 'JSS 3'
  final String schoolName;
  final String stateOfResidence;

  // Subscription & 7-Day Free Trial Fields
  final String subscriptionStatus; // 'trial', 'active', 'expired'
  final String subscriptionPlan; // 'free_trial', 'monthly', 'annual', 'none'
  final DateTime trialStartDate;
  final DateTime trialEndDate;
  final DateTime? subscriptionExpiryDate;
  final bool isReturningDeletedUser; // True if they previously deleted their account (no repeat free trial!)
  final String? appliedPromoCode;

  // Teacher / School Affiliate & Automated Payout Fields
  final String? promoCode; // e.g. 'TCHR-ADEWALE48' or 'SCH-QUEENS92'
  final double promoDiscountPercent; // 10.0 for teacher, 15.0 for school
  final double minimumWithdrawalThreshold; // 20000.0 for teacher, 50000.0 for school
  final double walletBalance; // Available Naira balance
  final double totalEarned; // Lifetime Naira earned
  final double totalWithdrawn; // Lifetime Naira withdrawn
  final int referredStudentsCount;
  final int activeSubscribedReferralsCount;

  // Linked Nigerian Bank Account Details for Automated Transfers
  final String bankName;
  final String bankCode;
  final String accountNumber;
  final String accountName;
  final String paystackRecipientCode;

  const UserAccountModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phoneNumber = '',
    this.classLevel = 'JSS 3',
    this.schoolName = '',
    this.stateOfResidence = 'Lagos',
    this.subscriptionStatus = 'trial',
    this.subscriptionPlan = 'free_trial',
    required this.trialStartDate,
    required this.trialEndDate,
    this.subscriptionExpiryDate,
    this.isReturningDeletedUser = false,
    this.appliedPromoCode,
    this.promoCode,
    this.promoDiscountPercent = 0.0,
    this.minimumWithdrawalThreshold = 0.0,
    this.walletBalance = 0.0,
    this.totalEarned = 0.0,
    this.totalWithdrawn = 0.0,
    this.referredStudentsCount = 0,
    this.activeSubscribedReferralsCount = 0,
    this.bankName = '',
    this.bankCode = '',
    this.accountNumber = '',
    this.accountName = '',
    this.paystackRecipientCode = '',
  });

  /// Returns true if the user currently has valid access (either within their 7-day trial or an active paid subscription).
  bool get hasActiveAccess {
    final DateTime now = DateTime.now();
    if (subscriptionStatus == 'active' &&
        subscriptionExpiryDate != null &&
        subscriptionExpiryDate!.isAfter(now)) {
      return true;
    }
    if (!isReturningDeletedUser &&
        subscriptionStatus == 'trial' &&
        trialEndDate.isAfter(now)) {
      return true;
    }
    return false;
  }

  /// Returns true if the user is currently in their 7-day free trial.
  bool get isInFreeTrial {
    final DateTime now = DateTime.now();
    return !isReturningDeletedUser &&
        subscriptionStatus == 'trial' &&
        trialEndDate.isAfter(now);
  }

  /// Remaining full or partial days in the 7-day free trial.
  int get trialDaysRemaining {
    if (!isInFreeTrial) return 0;
    final int hours = trialEndDate.difference(DateTime.now()).inHours;
    if (hours <= 0) return 0;
    return (hours / 24).ceil();
  }

  /// Remaining days in an active paid subscription.
  int get paidSubscriptionDaysRemaining {
    if (subscriptionExpiryDate == null) return 0;
    final int hours =
        subscriptionExpiryDate!.difference(DateTime.now()).inHours;
    if (hours <= 0) return 0;
    return (hours / 24).ceil();
  }

  /// Returns true if this Teacher or School has reached their minimum payout threshold (₦20,000 or ₦50,000).
  bool get canRequestWithdrawal {
    if (role == UserRole.student) return false;
    return walletBalance >= role.minimumWithdrawalNaira;
  }

  /// Progress (0.0 to 1.0) toward the Teacher (₦20,000) or School (₦50,000) withdrawal threshold.
  double get withdrawalThresholdProgress {
    final double minReq = role.minimumWithdrawalNaira;
    if (minReq <= 0) return 0.0;
    return (walletBalance / minReq).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email.toLowerCase().trim(),
      'role': role.value,
      'phoneNumber': phoneNumber,
      'classLevel': classLevel,
      'schoolName': schoolName,
      'stateOfResidence': stateOfResidence,
      'subscriptionStatus': subscriptionStatus,
      'subscriptionPlan': subscriptionPlan,
      'trialStartDate': Timestamp.fromDate(trialStartDate),
      'trialEndDate': Timestamp.fromDate(trialEndDate),
      'subscriptionExpiryDate': subscriptionExpiryDate != null
          ? Timestamp.fromDate(subscriptionExpiryDate!)
          : null,
      'isReturningDeletedUser': isReturningDeletedUser,
      'appliedPromoCode': appliedPromoCode,
      'promoCode': promoCode,
      'promoDiscountPercent': promoDiscountPercent,
      'minimumWithdrawalThreshold': minimumWithdrawalThreshold,
      'walletBalance': walletBalance,
      'totalEarned': totalEarned,
      'totalWithdrawn': totalWithdrawn,
      'referredStudentsCount': referredStudentsCount,
      'activeSubscribedReferralsCount': activeSubscribedReferralsCount,
      'bankName': bankName,
      'bankCode': bankCode,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'paystackRecipientCode': paystackRecipientCode,
    };
  }

  factory UserAccountModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc,
      ) {
    final Map<String, dynamic> data = doc.data() ?? {};
    final UserRole parsedRole = UserRole.fromString(data['role']?.toString());

    DateTime parseDate(dynamic raw, DateTime fallback) {
      if (raw is Timestamp) return raw.toDate();
      if (raw is String) return DateTime.tryParse(raw) ?? fallback;
      return fallback;
    }

    final DateTime now = DateTime.now();
    final DateTime tStart = parseDate(data['trialStartDate'], now);
    final DateTime tEnd =
    parseDate(data['trialEndDate'], tStart.add(const Duration(days: 7)));
    final DateTime? subExp = data['subscriptionExpiryDate'] != null
        ? parseDate(data['subscriptionExpiryDate'], now)
        : null;

    return UserAccountModel(
      uid: doc.id,
      name: (data['name'] ?? '').toString(),
      email: (data['email'] ?? '').toString(),
      role: parsedRole,
      phoneNumber: (data['phoneNumber'] ?? '').toString(),
      classLevel: (data['classLevel'] ?? 'JSS 3').toString(),
      schoolName: (data['schoolName'] ?? '').toString(),
      stateOfResidence: (data['stateOfResidence'] ?? 'Lagos').toString(),
      subscriptionStatus: (data['subscriptionStatus'] ?? 'trial').toString(),
      subscriptionPlan: (data['subscriptionPlan'] ?? 'free_trial').toString(),
      trialStartDate: tStart,
      trialEndDate: tEnd,
      subscriptionExpiryDate: subExp,
      isReturningDeletedUser: data['isReturningDeletedUser'] == true,
      appliedPromoCode: data['appliedPromoCode']?.toString(),
      promoCode: data['promoCode']?.toString(),
      promoDiscountPercent: (data['promoDiscountPercent'] as num?)?.toDouble() ??
          parsedRole.promoRatePercent,
      minimumWithdrawalThreshold:
      (data['minimumWithdrawalThreshold'] as num?)?.toDouble() ??
          parsedRole.minimumWithdrawalNaira,
      walletBalance: (data['walletBalance'] as num?)?.toDouble() ?? 0.0,
      totalEarned: (data['totalEarned'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawn: (data['totalWithdrawn'] as num?)?.toDouble() ?? 0.0,
      referredStudentsCount:
      (data['referredStudentsCount'] as num?)?.toInt() ?? 0,
      activeSubscribedReferralsCount:
      (data['activeSubscribedReferralsCount'] as num?)?.toInt() ?? 0,
      bankName: (data['bankName'] ?? '').toString(),
      bankCode: (data['bankCode'] ?? '').toString(),
      accountNumber: (data['accountNumber'] ?? '').toString(),
      accountName: (data['accountName'] ?? '').toString(),
      paystackRecipientCode: (data['paystackRecipientCode'] ?? '').toString(),
    );
  }
}