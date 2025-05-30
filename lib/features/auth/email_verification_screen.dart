import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isVerified = false;
  bool _checking = false;
  String? _error;

  Future<void> checkVerification() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    await FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('email_verification_pending');
      setState(() => _isVerified = true);

      // Set flag to allow /success for just this session
      await prefs.setBool('show_success_screen', true);

      await FirebaseAuth.instance.signOut();

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) context.go('/success');
    } else {
      setState(() {
        _checking = false;
        _error = "Email not verified yet. Please check your inbox.";
      });
    }
  }

  Future<void> resendEmail() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _error = "Verification email resent!";
        });
      }
    } catch (e) {
      setState(() {
        _error = "Could not resend verification email.";
      });
    } finally {
      setState(() {
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify your email")),
      body: Center(
        child: _isVerified
            ? const Text("Email verified! Redirecting...")
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.email_outlined, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              "A verification email has been sent to your address.\nPlease click the link in that email to verify your account.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checking ? null : checkVerification,
              child: _checking ? const CircularProgressIndicator() : const Text("I've verified my email"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: _checking ? null : resendEmail,
              child: const Text("Resend verification email"),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ]
          ],
        ),
      ),
    );
  }
}