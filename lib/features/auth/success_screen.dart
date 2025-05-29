import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      context.go('/sign-in');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/success.gif', height: 120), // Make sure to include this asset
            const SizedBox(height: 20),
            const Text("Account created successfully!", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
