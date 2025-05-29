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
    // Remove the flag first!
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('just_signed_up');
    // Sign out
    await FirebaseAuth.instance.signOut();
    // Now navigate
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
          children: [
            Image.asset('assets/images/success.gif', height: 250),
            const SizedBox(height: 20),
            const Text("Account created successfully!", style: TextStyle(fontSize: 18, fontFamily: "Poppins")),
            const SizedBox(height: 12),
            const Text("Redirecting to sign in...", style: TextStyle(fontSize: 14, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}