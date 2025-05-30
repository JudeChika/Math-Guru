import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/provider/auth_state_provider.dart';
import '../core/provider/onboarding_provider.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/success_screen.dart';
import '../features/auth/email_verification_screen.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingSeen = ref.watch(onboardingSeenNotifierProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/verify-email', builder: (_, __) => const EmailVerificationScreen()),
      GoRoute(path: '/success', builder: (_, __) => const SuccessScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/home', builder: (_, __) => const MyHomePage()),
    ],
    redirect: (context, state) async {
      if (onboardingSeen == null) return null;

      final user = authState.asData?.value;
      final location = state.uri.toString();

      final isAuthRoute = location == '/sign-in' ||
          location == '/sign-up' ||
          location == '/auth';

      // Onboarding not seen
      if (!onboardingSeen && location != '/onboarding') {
        return '/onboarding';
      }

      // Email verification step for signed-in, unverified users
      if (user != null && !user.emailVerified && location != '/verify-email') {
        return '/verify-email';
      }
      if (user != null && user.emailVerified && location == '/verify-email') {
        return '/success';
      }

      // Show success screen for unauthenticated users if flag is set
      final prefs = await SharedPreferences.getInstance();
      final showSuccessScreen = prefs.getBool('show_success_screen') ?? false;
      if (showSuccessScreen) {
        // Only redirect to /success if not already there
        if (location != '/success') {
          return '/success';
        }
        // If already on /success, do NOT redirect further!
        return null;
      }
      // If on /success but flag not set, go to sign-in (prevents direct access)
      if (location == '/success' && !showSuccessScreen) {
        return '/sign-in';
      }

      // Not authenticated
      if (onboardingSeen && user == null) {
        if (location == '/onboarding') return '/auth';
        if (isAuthRoute || location == '/onboarding') return null;
        return '/sign-in';
      }

      // Authenticated & verified
      if (onboardingSeen && user != null && user.emailVerified) {
        if (location == '/onboarding' || isAuthRoute) {
          return '/home';
        }
        return null;
      }

      return null;
    },
  );
});

// Helper to notify GoRouter when auth changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}