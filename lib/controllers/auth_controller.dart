import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong";
    }
  }
}
