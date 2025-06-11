import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordDialog extends StatelessWidget {
  final String email;
  const ChangePasswordDialog({super.key, required this.email});

  Future<void> _sendResetEmail(BuildContext context) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset email sent. Please check your inbox.")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Change Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'A link to reset your password will be sent to your email address.\n\n'
                'Password must:\n'
                '- be at least 6 characters\n'
                '- contain at least one letter\n'
                '- contain at least one number.',
          ),
          const SizedBox(height: 14),
          Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: const Text("Send Link"),
          onPressed: () => _sendResetEmail(context),
        ),
      ],
    );
  }
}