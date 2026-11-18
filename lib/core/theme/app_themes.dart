import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/settings_provider.dart';
import '../services/feedback_and_notification_service.dart';

/// StateNotifier that keeps `themeModeProvider` and `themeModeProvider.notifier`
/// working seamlessly while syncing with `appSettingsProvider`.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final Ref _ref;

  ThemeModeNotifier(this._ref, ThemeMode initialMode) : super(initialMode);

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _ref.read(appSettingsProvider.notifier).setThemeMode(mode);
  }
}

final themeModeProvider =
StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final ThemeMode currentMode = ref.watch(appSettingsProvider).themeMode;
  return ThemeModeNotifier(ref, currentMode);
});

class AppThemes {
  static const Color primaryColor = Color(0xFF4E5AE8);
  static const Color secondaryColor = Color(0xFFFF8746);
  static const Color darkBackground = Color(0xFF0E111F);
  static const Color darkSurface = Color(0xFF1A1E33);
  static const Color darkCard = Color(0xFF222741);

  /// Helper to check whether Dark Mode is currently active on the given context.
  static bool isDark(BuildContext context, WidgetRef ref) {
    final ThemeMode mode = ref.watch(themeModeProvider);
    if (mode == ThemeMode.dark) return true;
    if (mode == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }

  /// Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Poppins',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      primary: Colors.deepPurple,
      secondary: secondaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.deepPurple,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  /// Native Dark Theme (Used on Onboarding, AuthScreen, HomeScreen, Profile & Settings
  /// so GIF animations and PNG logos retain their true colors!)
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Poppins',
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      primary: const Color(0xFFB39DDB),
      secondary: secondaryColor,
      surface: darkSurface,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );

  /// 5x4 ColorMatrix that performs a **Hue-Preserving Luminance Inversion**:
  /// Converts white solver cards (`#FFFFFF`) into deep slate (`#121212`) and
  /// dark `Math.tex` formulas into crisp light formulas while preserving hues!
  static const List<double> huePreservingDarkMatrix = <double>[
    0.074, -0.926, -0.926, 0.0, 236.0,
    -0.926, 0.074, -0.926, 0.0, 236.0,
    -0.926, -0.926, 0.074, 0.0, 236.0,
    0.0, 0.0, 0.0, 1.0, 0.0,
  ];
}

/// A sleek, floating 1-tap Theme Pill (`📱 System` / `☀️ Light` / `🌙 Dark`)
/// that can be placed in the top corner of `OnboardingScreen`, `AuthScreen`, etc.
class FloatingThemeTogglePill extends ConsumerWidget {
  const FloatingThemeTogglePill({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final bool isDark = AppThemes.isDark(context, ref);

    String label;
    IconData icon;
    switch (settings.themeMode) {
      case ThemeMode.light:
        label = 'Light';
        icon = Icons.wb_sunny_rounded;
        break;
      case ThemeMode.dark:
        label = 'Dark';
        icon = Icons.nightlight_round;
        break;
      case ThemeMode.system:
        label = isDark ? 'Auto (Dark)' : 'Auto (Light)';
        icon = Icons.brightness_auto_rounded;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          final Brightness platformBrightness =
          MediaQuery.platformBrightnessOf(context);
          ref
              .read(appSettingsProvider.notifier)
              .cycleThemeMode(platformBrightness);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.14)
                : Colors.deepPurple.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.28)
                  : Colors.deepPurple.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? Colors.amberAccent : Colors.deepPurple,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.deepPurple,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Global wrapper in `main.dart` that synchronizes system status/navigation bars
/// and applies the Hue-Preserving Dark Filter to hardcoded white solver screens
/// when Dark Mode is active—while exempting screens with native Dark Mode & GIFs
/// (`OnboardingScreen`, `AuthScreen`, `HomeScreen`, `SettingsScreen`)!
class SmartDarkModeWrapper extends ConsumerWidget {
  final Widget child;
  final String? currentRoutePath;

  const SmartDarkModeWrapper({
    super.key,
    required this.child,
    this.currentRoutePath,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final bool isDarkActive = AppThemes.isDark(context, ref);

    final SystemUiOverlayStyle overlayStyle = isDarkActive
        ? SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: AppThemes.darkBackground,
      systemNavigationBarIconBrightness: Brightness.light,
    )
        : SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    );

    // Apply user's preferred text scale factor
    final MediaQueryData mq = MediaQuery.of(context);
    final Widget scaledChild = Listener(
      behavior: HitTestBehavior.translucent,
      onPointerUp: (PointerUpEvent event) {
        FeedbackAndNotificationService.instance.handleGlobalPointerUp(
          event,
          context,
          settings,
        );
      },
      child: MediaQuery(
        data: mq.copyWith(
          textScaler: TextScaler.linear(settings.mathFontScale),
        ),
        child: child,
      ),
    );

    if (!isDarkActive || !settings.darkMathCanvasEnabled) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: scaledChild,
      );
    }

    // Native Dark Mode routes (Onboarding with GIFs, AuthScreen with logos, Home, Settings)
    // render their own native dark surfaces so GIFs and logos are never inverted!
    final String path = currentRoutePath ?? '';
    final bool isNativeDarkRoute = path == '/onboarding' ||
        path == '/auth' ||
        path == '/home' ||
        path == '/settings';

    if (isNativeDarkRoute) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: scaledChild,
      );
    }

    // For all 300+ JSS 1–3 / SSS 1–3 solver screens (and legacy white-card screens),
    // force Light ThemeData inside the Hue-Preserving Dark Matrix so white cards
    // become dark slate (#121212) and dark LaTeX math becomes crisp white/lavender!
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: ColorFiltered(
        colorFilter: const ColorFilter.matrix(
          AppThemes.huePreservingDarkMatrix,
        ),
        child: Theme(
          data: AppThemes.lightTheme,
          child: scaledChild,
        ),
      ),
    );
  }
}