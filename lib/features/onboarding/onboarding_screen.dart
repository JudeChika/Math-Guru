import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/provider/onboarding_provider.dart';
import '../../core/theme/app_themes.dart';

class OnboardingPageModel {
  final String imagePath;
  final String title;
  final String description;

  OnboardingPageModel({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingPageModel> pages = [
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_1.gif',
      title: 'Welcome to Math Guru',
      description:
      'Master mathematics from Junior to Senior Secondary with clear, step-by-step guidance.',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_2.gif',
      title: 'Snap & Solve Instantly',
      description:
      'Take a photo or type any math problem for detailed, easy-to-follow solutions.',
    ),
    OnboardingPageModel(
      imagePath: 'assets/images/onboarding_3.gif',
      title: 'Learn Your Way',
      description:
      'Enjoy interactive visuals and personalized paths that make every concept click.',
    ),
  ];

  void _completeOnboarding() async {
    final dynamic notifier =
    ref.read(onboardingSeenNotifierProvider.notifier);
    try {
      await notifier.setOnboardingSeen();
    } catch (_) {
      try {
        await notifier.completeOnboarding();
      } catch (_) {
        try {
          await notifier.markOnboardingSeen();
        } catch (_) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_seen', true);
          ref.invalidate(onboardingSeenNotifierProvider);
        }
      }
    }
    if (mounted) {
      context.go('/auth');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AppThemes.isDark(context, ref);

    final Color bgColor =
    isDark ? AppThemes.darkBackground : Colors.white;
    final Color titleColor =
    isDark ? Colors.white : Colors.black;
    final Color descriptionColor =
    isDark ? Colors.white70 : Colors.grey.shade600;
    final Color skipColor =
    isDark ? Colors.amberAccent : const Color(0xFF4E5AE8);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView for onboarding slides (GIFs stay in their true original colors!)
            PageView.builder(
              controller: _controller,
              itemCount: pages.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (_, index) {
                final page = pages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Soft glowing frame in Dark Mode so transparent/white-backed GIFs look polished
                      Container(
                        padding: EdgeInsets.all(isDark ? 14 : 0),
                        decoration: isDark
                            ? BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple
                                  .withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        )
                            : null,
                        child: Image.asset(
                          page.imagePath,
                          height: 280,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        page.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(color: titleColor),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        page.description,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: descriptionColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Top Bar: 1-Tap Theme Toggle Pill (Left) + Skip Button (Right)
            Positioned(
              top: 16,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const FloatingThemeTogglePill(),
                  if (_currentPage < pages.length - 1)
                    TextButton(
                      onPressed: _completeOnboarding,
                      child: Text(
                        "Skip",
                        style: TextStyle(
                          color: skipColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Bottom indicator + Next / Get Started button
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? (isDark
                              ? Colors.amberAccent
                              : Colors.deepPurple)
                              : (isDark
                              ? Colors.white24
                              : Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == pages.length - 1) {
                          _completeOnboarding();
                        } else {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _currentPage == pages.length - 1
                            ? "Get Started"
                            : "Next",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}