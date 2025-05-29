import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/provider/auth_state_provider.dart';
import '../core/provider/onboarding_provider.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/success_screen.dart';
import '../features/home/home_page.dart';
import '../features/onboarding/onboarding_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingSeen = ref.watch(onboardingSeenProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthScreen()),
      GoRoute(path: '/sign-up', builder: (_, __) => const SignUpScreen()),
      GoRoute(path: '/success', builder: (_, __) => const SuccessScreen()),
      GoRoute(path: '/sign-in', builder: (_, __) => const SignInScreen()),
      GoRoute(path: '/home', builder: (_, __) => const MyHomePage()),
    ],
    redirect: (context, state) {
      final user = authState.asData?.value;
      final hasSeenOnboarding = onboardingSeen.asData?.value ?? false;
      final location = state.uri.toString();

      final isAuthRoute = location == '/sign-in' ||
          location == '/sign-up' ||
          location == '/auth' ||
          location == '/success';

      if (!hasSeenOnboarding && location != '/onboarding') {
        return '/onboarding';
      }

      if (user == null) {
        return isAuthRoute || location == '/onboarding' ? null : '/sign-in';
      }

      if ((isAuthRoute || location == '/onboarding')) {
        return '/home';
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
