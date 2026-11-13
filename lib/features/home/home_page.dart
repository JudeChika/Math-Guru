import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'junior_section.dart';
import 'senior_section.dart';
import 'profile_section.dart';
import 'widgets/trial_countdown_banner.dart';

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
    final bool isUnifiedScrollPage = currentIndex == 0 || currentIndex == 3;

    return Stack(
      children: [
        // Only show fixed BackgroundWaves on tabs that don't have their own synchronized scrolling BackgroundWaves
        if (!isUnifiedScrollPage)
          const Positioned.fill(child: BackgroundWaves()),
        Scaffold(
          backgroundColor: isUnifiedScrollPage
              ? const Color(0xFFFFFFFF)
              : Colors.transparent,
          extendBody: true,
          body: SafeArea(
            top: !isUnifiedScrollPage,
            child: _pages[currentIndex],
          ),
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
          backgroundColor: Colors.white.withValues(alpha: 0.98),
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          selectedItemColor: Colors.purple,
          unselectedItemColor: Colors.grey[500],
          currentIndex: currentIndex,
          onTap: onTap,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_rounded),
              label: 'Junior',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school_outlined),
              label: 'Senior',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
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
    final double topInset = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Stack(
        children: [
          // BackgroundWaves now lives INSIDE the SingleChildScrollView so it scrolls simultaneously with the content!
          const Positioned.fill(child: BackgroundWaves()),
          Padding(
            padding: EdgeInsets.fromLTRB(24.0, topInset + 8.0, 24.0, 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HomeAppBar(
                  onSettingsTap: () {
                    // Switch to Profile & Subscription Settings tab
                    ref.read(homeTabIndexProvider.notifier).state = 3;
                  },
                ),
                const SizedBox(height: 18),
                if (uid != null)
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      final data = snapshot.data?.data() ?? {};
                      final String? profileImageUrl = data['profileImageUrl'];
                      final String fullName =
                      (data['name'] ?? user?.displayName ?? "User")
                          .toString();
                      final String roleLabel =
                      (data['role'] ?? 'student').toString().toUpperCase();

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
                                  child: profileImageUrl != null &&
                                      profileImageUrl.isNotEmpty
                                      ? Image.network(profileImageUrl,
                                      fit: BoxFit.cover)
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
                                      "Welcome ($roleLabel)",
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
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

                const SizedBox(height: 18),

                // LIVE 7-DAY FREE TRIAL COUNTDOWN & SUBSCRIPTION STATUS BANNER
                const TrialCountdownBanner(),

                const SizedBox(height: 28),
                Text(
                  "Categories",
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                _CategoryCard(
                  icon: Icons.school_rounded,
                  iconColor: Colors.purple,
                  title: "Junior Secondary",
                  subtitle: "Mathematics topics (JSS 1 – JSS 3)",
                  onTap: () => ref.read(homeTabIndexProvider.notifier).state = 1,
                ),
                const SizedBox(height: 18),
                _CategoryCard(
                  icon: Icons.school_rounded,
                  iconColor: Colors.purple,
                  title: "Senior Secondary",
                  subtitle: "Mathematics topics (SSS 1 – SSS 3)",
                  onTap: () => ref.read(homeTabIndexProvider.notifier).state = 2,
                ),
                const SizedBox(height: 48),
                Center(
                  child: Image.asset(
                    "assets/images/math_guru_logo.png",
                    width: 180,
                  ),
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  final VoidCallback? onSettingsTap;

  const _HomeAppBar({this.onSettingsTap});

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
          icon: const Icon(Icons.settings_rounded,
              color: Colors.white, size: 28),
          tooltip: 'Profile & Subscription Settings',
          onPressed: onSettingsTap,
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
                color: Colors.black.withValues(alpha: 0.18),
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
                  color: iconColor.withValues(alpha: 0.13),
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
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.7),
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