import 'package:flutter/material.dart';

import '../auth/auth_screen.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: BackgroundWaves()),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text(
              "Profile Section",
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
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