import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/auth_controller.dart';
import '../core/provider/auth_state_provider.dart';
import '../core/provider/onboarding_provider.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/sign_in_screen.dart';
import '../features/auth/sign_up_screen.dart';
import '../features/auth/success_screen.dart';
import '../features/auth/email_verification_screen.dart';
import '../features/auth/terms_and_conditions_screen.dart';
import '../features/home/edit_profile_screen.dart';
import '../features/home/home_page.dart';
import '../features/junior_secondary/jss1/jss1_topic_detail_screen.dart';
import '../features/junior_secondary/jss1/jss1_topics_screen.dart';
import '../features/junior_secondary/jss2/jss2_topic_detail_screen.dart';
import '../features/junior_secondary/jss2/jss2_topics_screen.dart';
import '../features/junior_secondary/jss3/jss3_topic_detail_screen.dart';
import '../features/junior_secondary/jss3/jss3_topics_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/senior_secondary/sss1/sss1_topic_detail_screen.dart';
import '../features/senior_secondary/sss1/sss1_topics_screen.dart';
import '../features/senior_secondary/sss2/sss2_topic_detail_screen.dart';
import '../features/senior_secondary/sss2/sss2_topics_screen.dart';
import '../features/senior_secondary/sss3/sss3_topic_detail_screen.dart';
import '../features/senior_secondary/sss3/sss3_topics_screen.dart';
import '../features/subscription/subscription_paywall_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final onboardingSeen = ref.watch(onboardingSeenNotifierProvider);
  final userAccountAsync = ref.watch(currentUserAccountProvider);

  return GoRouter(
    initialLocation: '/onboarding',
    refreshListenable: GoRouterRefreshStream(
      FirebaseAuth.instance.authStateChanges(),
    ),
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (_, __) => const AuthScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (_, __) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/signup',
        redirect: (_, __) => '/sign-up',
      ),
      GoRoute(
        path: '/verify-email',
        builder: (_, __) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/success',
        builder: (_, __) => const SuccessScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (_, __) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signin',
        redirect: (_, __) => '/sign-in',
      ),
      GoRoute(
        path: '/terms',
        builder: (_, __) => const TermsAndConditionsScreen(),
      ),
      GoRoute(
        path: '/paywall',
        builder: (_, state) {
          final bool forced =
              state.uri.queryParameters['expired'] == 'true';
          return SubscriptionPaywallScreen(
            isForcedByExpiredTrial: forced,
          );
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (_, __) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/',
        redirect: (_, __) => '/home',
      ),
      GoRoute(
        path: '/home',
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: '/jss1',
        builder: (_, __) => const Jss1TopicsScreen(),
      ),
      GoRoute(
        path: '/jss2',
        builder: (_, __) => const Jss2TopicsScreen(),
      ),
      GoRoute(
        path: '/jss3',
        builder: (_, __) => const Jss3TopicsScreen(),
      ),
      GoRoute(
        path: '/sss1',
        builder: (_, __) => const Sss1TopicsScreen(),
      ),
      GoRoute(
        path: '/sss2',
        builder: (_, __) => const Sss2TopicsScreen(),
      ),
      GoRoute(
        path: '/sss3',
        builder: (_, __) => const Sss3TopicsScreen(),
      ),
      GoRoute(
        path: '/jss1-topic/:topic/:subtopic',
        builder: (context, state) {
          final topic = Uri.decodeComponent(state.pathParameters['topic']!);
          final subtopic =
          Uri.decodeComponent(state.pathParameters['subtopic']!);
          return Jss1TopicDetailScreen(topic: topic, subtopic: subtopic);
        },
      ),
      GoRoute(
        path: '/jss2-topic/:topic/:subtopic',
        builder: (context, state) {
          final topic = Uri.decodeComponent(state.pathParameters['topic']!);
          final subtopic =
          Uri.decodeComponent(state.pathParameters['subtopic']!);
          return Jss2TopicDetailScreen(topic: topic, subtopic: subtopic);
        },
      ),
      GoRoute(
        path: '/jss3-topic/:topic/:subtopic',
        builder: (context, state) {
          final topic = Uri.decodeComponent(state.pathParameters['topic']!);
          final subtopic =
          Uri.decodeComponent(state.pathParameters['subtopic']!);
          return Jss3TopicDetailScreen(topic: topic, subtopic: subtopic);
        },
      ),
      GoRoute(
        path: '/sss1-topic/:topic/:subtopic',
        builder: (context, state) {
          final topic = Uri.decodeComponent(state.pathParameters['topic']!);
          final subtopic =
          Uri.decodeComponent(state.pathParameters['subtopic']!);
          return Sss1TopicDetailScreen(topic: topic, subtopic: subtopic);
        },
      ),
      GoRoute(
        path: '/sss2-topic/:topic/:subtopic',
        builder: (context, state) {
          final topic = Uri.decodeComponent(state.pathParameters['topic']!);
          final subtopic =
          Uri.decodeComponent(state.pathParameters['subtopic']!);
          return Sss2TopicDetailScreen(topic: topic, subtopic: subtopic);
        },
      ),
      GoRoute(
        path: '/sss3-topic/:topic/:subtopic',
        builder: (context, state) {
          final topic = Uri.decodeComponent(state.pathParameters['topic']!);
          final subtopic =
          Uri.decodeComponent(state.pathParameters['subtopic']!);
          return Sss3TopicDetailScreen(topic: topic, subtopic: subtopic);
        },
      ),
    ],
    redirect: (context, state) async {
      if (onboardingSeen == null) return null;

      final user = authState.asData?.value;
      final location = state.uri.path;

      // Always allow access to Legal Terms & Conditions
      if (location == '/terms') return null;

      final isAuthRoute = location == '/sign-in' ||
          location == '/signin' ||
          location == '/sign-up' ||
          location == '/signup' ||
          location == '/auth';

      // 1. Onboarding not seen
      if (!onboardingSeen && location != '/onboarding') {
        return '/onboarding';
      }

      // 2. Email verification step for signed-in, unverified users
      if (user != null && !user.emailVerified && location != '/verify-email') {
        return '/verify-email';
      }
      if (user != null && user.emailVerified && location == '/verify-email') {
        return '/success';
      }

      // 3. Show success screen for unauthenticated users if flag is set
      final prefs = await SharedPreferences.getInstance();
      final showSuccessScreen = prefs.getBool('show_success_screen') ?? false;
      if (showSuccessScreen) {
        if (location != '/success') {
          return '/success';
        }
        return null;
      }
      if (location == '/success' && !showSuccessScreen) {
        return '/sign-in';
      }

      // 4. Not authenticated
      if (onboardingSeen && user == null) {
        if (location == '/onboarding') return '/auth';
        if (isAuthRoute || location == '/onboarding') return null;
        return '/sign-in';
      }

      // 5. Authenticated & verified
      if (onboardingSeen && user != null && user.emailVerified) {
        if (location == '/onboarding' || isAuthRoute) {
          return '/home';
        }

        // 6. SUBSCRIPTION & 7-DAY FREE TRIAL GUARD FOR ALL JSS 1–3 & SSS 1–3 TOPICS
        final bool isProtectedCurriculumRoute = location.startsWith('/jss1') ||
            location.startsWith('/jss2') ||
            location.startsWith('/jss3') ||
            location.startsWith('/sss1') ||
            location.startsWith('/sss2') ||
            location.startsWith('/sss3');

        if (isProtectedCurriculumRoute) {
          final account = userAccountAsync.asData?.value;
          // If the user's 7-day trial has expired (or they are a returning deleted user)
          // and they do not have an active paid subscription, redirect them to the Paywall!
          if (account != null && !account.hasActiveAccess) {
            return '/paywall?expired=true';
          }
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