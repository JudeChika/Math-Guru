import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_themes.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyBfLeYsRNvNXesYxMEouMfGssGmFKiYyhA",
          authDomain: "math-guru-f8ba2.firebaseapp.com",
          projectId: "math-guru-f8ba2",
          storageBucket: "math-guru-f8ba2.firebasestorage.app",
          messagingSenderId: "217703973724",
          appId: "1:217703973724:web:36d6cc63c69f32426db799",
          measurementId: "G-KV6H87HJ5Z",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(
    const ProviderScope(child: MathGuruApp()),
  );
}

class MathGuruApp extends ConsumerWidget {
  const MathGuruApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Math Guru',
      debugShowCheckedModeBanner: false,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
