import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authControllerProvider = Provider<AuthController>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return AuthController(auth);
});

class AuthController {
  final FirebaseAuth _auth;

  AuthController(this._auth);

  Future<String?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      if (!userCred.user!.emailVerified) {
        await userCred.user!.sendEmailVerification();
      }
      // Mark that user just registered and should verify email
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('email_verification_pending', true);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong";
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (!userCred.user!.emailVerified) {
        // Don't allow sign-in if not verified
        await _auth.signOut();
        return "Please verify your email address before signing in.";
      }
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong";
    }
  }
}