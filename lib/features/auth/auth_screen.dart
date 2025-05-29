import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background curves
          const Positioned.fill(child: BackgroundWaves()),

          // Foreground content
          SafeArea(
            child: Center( // <-- Ensures horizontal centering
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 30),

                  // Logo + App Name
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Image.asset(
                          'assets/images/math_guru_logo.png',
                          height: 100,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'MATH',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 40,
                          height: 1.0, // Reduces line height
                        ),
                      ),
                      Text(
                        'GURU',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 80,
                          height: 1.0,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 100),

                  // Buttons
                  Column(
                    children: [
                      GradientButton(
                        label: 'Sign In',
                        onPressed: () => context.go('/sign-in'),
                        width: 200,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: 200,
                        height: 54,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextButton(
                          onPressed: () => context.go('/sign-up'),
                          child: Text(
                            'Sign up',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Need Help?',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Gradient Button
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final double width;

  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFAB47BC), Color(0xFF1E88E5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


// Background Layer
class BackgroundWaves extends StatelessWidget {
  const BackgroundWaves({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: const Color(0xFFFFFFFF)), // base blue

        const Positioned(
          top: -450,
          left: -330,
          child: CircleContainer(color: Color(0xFFB5C8FF), size: 1000),
        ),
        const Positioned(
          top: -500,
          right: -200,
          child: CircleContainer(color: Color(0xFF849DF9), size: 1000),
        ),
        const Positioned(
          top: -500,
          left: -120,
          child: CircleContainer(color: Color(0xFF3D79F4), size: 1000),
        ),
      ],
    );
  }
}

class CircleContainer extends StatelessWidget {
  final Color color;
  final double size;

  const CircleContainer({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
