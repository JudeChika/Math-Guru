import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/auth_controller.dart';
import 'auth_screen.dart';

final _passwordVisibleProvider = StateProvider<bool>((ref) => false);

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isVisible = ref.watch(_passwordVisibleProvider);

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
                    onPressed: () => context.go('/Auth'),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      'Sign In',
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Text('Sign in to continue',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        )),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !isVisible,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          isVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () => ref
                            .read(_passwordVisibleProvider.notifier)
                            .state = !isVisible,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {}, // Add forgot password logic
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 130),
                  Center(
                    child: Column(
                      children: [
                        GradientButton(
                          label: 'Sign In',
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text;

                            if (email.isEmpty || password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Please fill all fields")),
                              );
                              return;
                            }

                            final authController =
                            ref.read(authControllerProvider);
                            final error = await authController.signIn(
                                email: email, password: password);

                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error)));
                            } else {
                              context.go('/home');
                            }
                          },
                          width: 200,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Wrap(
                      children: [
                        Text("Not yet signed up?, ",
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.black)),
                        GestureDetector(
                          onTap: () => context.go('/sign-up'),
                          child: Text("Sign up",
                              style: textTheme.bodyMedium
                                  ?.copyWith(color: Colors.purple)),
                        ),
                        Text(" here.",
                            style: textTheme.bodyMedium
                                ?.copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Wrap(
                      children: [
                        const Text(
                          "or sign in with",
                          style: TextStyle(color: Colors.purple, fontSize: 14),
                        ),
                        const SizedBox(width: 5),
                        GestureDetector(
                          onTap: () {
                            // Implement Google sign-in
                          },
                          child: Image.asset(
                            'assets/images/google.png',
                            height: 17,
                          ),
                        ),
                      ],
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
