import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/provider/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnboardingPageData> _pages = [
    _OnboardingPageData(
      gif: 'assets/images/onboarding_1.gif',
      title: 'Master mathematics like never before',
      description:
      'Math Guru helps you solve complex math problems with ease. Get step-by-step solutions, explanations, and tips to sharpen your skills.',
    ),
    _OnboardingPageData(
      gif: 'assets/images/onboarding_2.gif',
      title: 'How it works',
      description:
      'Simply enter your math problems, and let Math Guru break it down step by step. Learn smarter, not harder.',
    ),
    _OnboardingPageData(
      gif: 'assets/images/onboarding_3.gif',
      title: 'Get Started',
      description:
      'Ready to level up your math skills? Let\'s dive in and start solving! Math success begins here.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) =>
                    setState(() => _currentIndex = index),
                itemBuilder: (_, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(page.gif,
                            height: 250, fit: BoxFit.contain),
                        const SizedBox(height: 32),
                        Text(
                          page.title,
                          style: textTheme.displayLarge,
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fade(duration: 400.ms)
                            .slideY(begin: 0.3, curve: Curves.easeOut),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        )
                            .animate()
                            .fadeIn(duration: 500.ms)
                            .slideY(begin: 0.3, curve: Curves.easeOut),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildPageIndicator(),
            const SizedBox(height: 24),

            /// Show Proceed button on last page
            if (_currentIndex == _pages.length - 1)
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(onboardingSeenNotifierProvider.notifier)
                      .complete(context);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Proceed'),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.2)
                  .shake(hz: 2, duration: 1.seconds),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return Container(
          width: 20,
          height: 2,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _currentIndex == index ? Colors.purple : Colors.grey[300],
          ),
        );
      }),
    );
  }
}

class _OnboardingPageData {
  final String gif;
  final String title;
  final String description;

  _OnboardingPageData({
    required this.gif,
    required this.title,
    required this.description,
  });
}
