import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    _handleSuccess();
  }

  Future<void> _handleSuccess() async {
    await Future.delayed(const Duration(seconds: 3));
    // Remove the flag so user can't revisit success screen
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('show_success_screen');
    await FirebaseAuth.instance.signOut(); // just in case
    if (mounted) {
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // <-- centralise content horizontally
          children: [
            Image.asset('assets/images/success.gif', height: 250),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Account created and verified successfully!",
                style: TextStyle(fontSize: 18, fontFamily: "Poppins"),
                textAlign: TextAlign.center, // <-- centralise text
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Redirecting to sign in...",
                style: TextStyle(fontSize: 14, color: Colors.grey, fontFamily: "Poppins"),
                textAlign: TextAlign.center, // <-- centralise text
              ),
            ),
          ],
        ),
      ),
    );
  }
}