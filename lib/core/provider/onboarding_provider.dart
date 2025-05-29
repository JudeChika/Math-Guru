import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

// FutureProvider to load onboarding status
final onboardingSeenProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_seen') ?? false;
});

// Notifier to refresh onboarding status after update
final onboardingSeenNotifierProvider = StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(false);

  Future<void> complete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    state = true;
    context.go('/auth'); // Redirect after onboarding
  }
}
