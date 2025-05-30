import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import 'auth_screen.dart';

final _passwordVisibleProvider = StateProvider<bool>((ref) => false);
final _repeatPasswordVisibleProvider = StateProvider<bool>((ref) => false);

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final passwordVisible = ref.watch(_passwordVisibleProvider);
    final repeatVisible = ref.watch(_repeatPasswordVisibleProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Positioned.fill(child: BackgroundWaves()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.go('/auth'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text('Sign Up',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Wrap(
                      children: [
                        Text("Already signed up, ", style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        GestureDetector(
                          onTap: () => context.go('/sign-in'),
                          child: Text("login", style: textTheme.bodyMedium?.copyWith(color: Colors.purple)),
                        ),
                        Text(" here.", style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  _CustomTextField(
                    hintText: 'Name',
                    controller: nameController,
                  ),
                  const SizedBox(height: 16),

                  _CustomTextField(
                    hintText: 'Email',
                    controller: emailController,
                  ),
                  const SizedBox(height: 16),

                  _CustomTextField(
                    hintText: 'Password',
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        passwordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => ref
                          .read(_passwordVisibleProvider.notifier)
                          .state = !passwordVisible,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _CustomTextField(
                    hintText: 'Repeat Password',
                    controller: repeatPasswordController,
                    obscureText: !repeatVisible,
                    suffixIcon: IconButton(
                      icon: Icon(
                        repeatVisible ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => ref
                          .read(_repeatPasswordVisibleProvider.notifier)
                          .state = !repeatVisible,
                    ),
                  ),
                  const SizedBox(height: 130),

                  Center(
                    child: GradientButton(
                      label: 'Sign Up',
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        final password = passwordController.text;
                        final repeatPassword = repeatPasswordController.text;

                        if (name.isEmpty || email.isEmpty || password.isEmpty || repeatPassword.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("All fields are required")));
                          return;
                        }

                        if (password.length < 6 ||
                            !RegExp(r'[A-Za-z]').hasMatch(password) ||
                            !RegExp(r'[0-9]').hasMatch(password)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Password must be at least 6 characters long and contain at least one letter and one number"),
                            ),
                          );
                          return;
                        }

                        if (password != repeatPassword) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
                          return;
                        }

                        final authController = ref.read(authControllerProvider);
                        final error = await authController.signUp(email: email, password: password);

                        if (error != null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                        } else {
                          context.go('/verify-email');
                        }
                      },
                      width: 200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextEditingController? controller;

  const _CustomTextField({
    required this.hintText,
    this.obscureText = false,
    this.suffixIcon,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}