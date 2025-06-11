import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class LogoutConfirmationScreen extends StatelessWidget {
  const LogoutConfirmationScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      // Use GoRouter (replace with your navigation if needed)
      context.go('/sign-in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Confirm Logout"),
      content: const Text("Are you sure you want to logout?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Logout"),
          onPressed: () => _logout(context),
        ),
      ],
    );
  }
}