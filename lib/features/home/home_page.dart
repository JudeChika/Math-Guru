import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'junior_section.dart';
import 'senior_section.dart';
import 'profile_section.dart';

// Riverpod provider to manage the current home tab index
final homeTabIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static final List<Widget> _pages = [
    const _HomeSection(),
    const JuniorSection(),
    const SeniorSection(),
    const ProfileSection(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeTabIndexProvider);

    return Stack(
      children: [
        const Positioned.fill(child: BackgroundWaves()),
        Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: SafeArea(child: _pages[currentIndex]),
          bottomNavigationBar: _ThemedNavBar(
            currentIndex: currentIndex,
            onTap: (idx) => ref.read(homeTabIndexProvider.notifier).state = idx,
          ),
        ),
      ],
    );
  }
}

class _ThemedNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _ThemedNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, left: 16, right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BottomNavigationBar(
          backgroundColor: Colors.white.withOpacity(0.98),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey[500],
          currentIndex: currentIndex,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded), label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded), label: 'Junior',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined), label: 'Senior',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded), label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSection extends ConsumerWidget {
  const _HomeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _HomeAppBar(),
          const SizedBox(height: 18),
          if (uid != null)
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final String? profileImageUrl = data['profileImageUrl'];
                final String fullName = data['name'] ?? "User";
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: profileImageUrl != null && profileImageUrl.isNotEmpty
                                ? Image.network(profileImageUrl, fit: BoxFit.cover)
                                : Image.asset(
                              'assets/images/profile_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Welcome",
                                style: textTheme.bodySmall?.copyWith(
                                    color: Colors.white70, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                fullName,
                                style: textTheme.displayLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/JAY_2589_transcpr_1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome",
                            style: textTheme.bodySmall?.copyWith(
                                color: Colors.white70, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            "User",
                            style: textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 24,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 70),
          Text(
            "Categories",
            style: textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          _CategoryCard(
            icon: Icons.school_rounded,
            iconColor: Colors.purple,
            title: "Junior Secondary",
            subtitle: "Mathematics topics",
            onTap: () => ref.read(homeTabIndexProvider.notifier).state = 1,
          ),
          const SizedBox(height: 18),
          _CategoryCard(
            icon: Icons.school_rounded,
            iconColor: Colors.purple,
            title: "Senior Secondary",
            subtitle: "Mathematics topics",
            onTap: () => ref.read(homeTabIndexProvider.notifier).state = 2,
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Home",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 28),
          onPressed: () {
            // Navigate to settings page
          },
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(22),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.13),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(icon, color: iconColor, size: 36),
              ),
              const SizedBox(width: 18),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        fontSize: 22,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.purple,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy CircleContainer for background
class CircleContainer extends StatelessWidget {
  final Color color;
  final double size;
  const CircleContainer({required this.color, required this.size, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration:
      BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.7)),
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