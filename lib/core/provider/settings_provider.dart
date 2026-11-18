import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/feedback_and_notification_service.dart';

/// Holds all user-customizable settings for Math Guru, including Haptic Vibration,
/// Sound Effects, and System Push Notifications.
class AppSettingsState {
  final ThemeMode themeMode;
  final bool darkMathCanvasEnabled; // If true, applies hue-preserving dark filter to the 300+ math solver screens in Dark Mode
  final double mathFontScale; // 0.9 (Compact), 1.0 (Standard), 1.15 (Large)
  final int defaultSolverInputMode; // 0: AI Vision, 1: Manual Builder
  final String defaultClassLevel; // 'JSS 1', 'JSS 2', 'JSS 3', 'SSS 1', 'SSS 2', 'SSS 3'
  final bool studyReminderEnabled;
  final String studyReminderTime; // e.g. '17:00' (5:00 PM)
  final bool hapticFeedbackEnabled; // Vibrates when an answer is generated
  final bool soundEffectsEnabled; // Plays a sound effect when an answer is generated
  final bool pushNotificationsEnabled; // Sends a system push notification when a solution or study reminder triggers

  const AppSettingsState({
    this.themeMode = ThemeMode.system,
    this.darkMathCanvasEnabled = true,
    this.mathFontScale = 1.0,
    this.defaultSolverInputMode = 1,
    this.defaultClassLevel = 'JSS 3',
    this.studyReminderEnabled = true,
    this.studyReminderTime = '17:00',
    this.hapticFeedbackEnabled = true,
    this.soundEffectsEnabled = true,
    this.pushNotificationsEnabled = true,
  });

  AppSettingsState copyWith({
    ThemeMode? themeMode,
    bool? darkMathCanvasEnabled,
    double? mathFontScale,
    int? defaultSolverInputMode,
    String? defaultClassLevel,
    bool? studyReminderEnabled,
    String? studyReminderTime,
    bool? hapticFeedbackEnabled,
    bool? soundEffectsEnabled,
    bool? pushNotificationsEnabled,
  }) {
    return AppSettingsState(
      themeMode: themeMode ?? this.themeMode,
      darkMathCanvasEnabled:
      darkMathCanvasEnabled ?? this.darkMathCanvasEnabled,
      mathFontScale: mathFontScale ?? this.mathFontScale,
      defaultSolverInputMode:
      defaultSolverInputMode ?? this.defaultSolverInputMode,
      defaultClassLevel: defaultClassLevel ?? this.defaultClassLevel,
      studyReminderEnabled: studyReminderEnabled ?? this.studyReminderEnabled,
      studyReminderTime: studyReminderTime ?? this.studyReminderTime,
      hapticFeedbackEnabled:
      hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      pushNotificationsEnabled:
      pushNotificationsEnabled ?? this.pushNotificationsEnabled,
    );
  }
}

class AppSettingsNotifier extends StateNotifier<AppSettingsState> {
  static const String _kThemeMode = 'math_guru_theme_mode_v1';
  static const String _kDarkMathCanvas = 'math_guru_dark_math_canvas_v1';
  static const String _kMathFontScale = 'math_guru_math_font_scale_v1';
  static const String _kDefaultInputMode = 'math_guru_default_input_mode_v1';
  static const String _kDefaultClass = 'math_guru_default_class_level_v1';
  static const String _kReminderEnabled = 'math_guru_reminder_enabled_v1';
  static const String _kReminderTime = 'math_guru_reminder_time_v1';
  static const String _kHaptics = 'math_guru_haptic_feedback_v1';
  static const String _kSoundEffects = 'math_guru_sound_effects_v1';
  static const String _kPushNotifications = 'math_guru_push_notifications_v1';

  AppSettingsNotifier() : super(const AppSettingsState()) {
    _loadSettings();
    FeedbackAndNotificationService.instance.initialize();
  }

  Future<void> _loadSettings() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? savedTheme = prefs.getString(_kThemeMode);
      ThemeMode mode = ThemeMode.system;
      if (savedTheme == 'light') {
        mode = ThemeMode.light;
      } else if (savedTheme == 'dark') {
        mode = ThemeMode.dark;
      }

      state = AppSettingsState(
        themeMode: mode,
        darkMathCanvasEnabled: prefs.getBool(_kDarkMathCanvas) ?? true,
        mathFontScale: prefs.getDouble(_kMathFontScale) ?? 1.0,
        defaultSolverInputMode: prefs.getInt(_kDefaultInputMode) ?? 1,
        defaultClassLevel: prefs.getString(_kDefaultClass) ?? 'JSS 3',
        studyReminderEnabled: prefs.getBool(_kReminderEnabled) ?? true,
        studyReminderTime: prefs.getString(_kReminderTime) ?? '17:00',
        hapticFeedbackEnabled: prefs.getBool(_kHaptics) ?? true,
        soundEffectsEnabled: prefs.getBool(_kSoundEffects) ?? true,
        pushNotificationsEnabled: prefs.getBool(_kPushNotifications) ?? true,
      );
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String val = mode == ThemeMode.light
        ? 'light'
        : (mode == ThemeMode.dark ? 'dark' : 'system');
    await prefs.setString(_kThemeMode, val);
  }

  /// Cycles through System -> Dark -> Light -> System (used by the 1-tap pill on Onboarding & Auth screens).
  Future<void> cycleThemeMode(Brightness currentPlatformBrightness) async {
    if (state.themeMode == ThemeMode.system) {
      final ThemeMode next = currentPlatformBrightness == Brightness.dark
          ? ThemeMode.light
          : ThemeMode.dark;
      await setThemeMode(next);
    } else if (state.themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.system);
    }
  }

  Future<void> setDarkMathCanvasEnabled(bool enabled) async {
    state = state.copyWith(darkMathCanvasEnabled: enabled);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMathCanvas, enabled);
  }

  Future<void> setMathFontScale(double scale) async {
    state = state.copyWith(mathFontScale: scale);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kMathFontScale, scale);
  }

  Future<void> setDefaultSolverInputMode(int mode) async {
    state = state.copyWith(defaultSolverInputMode: mode);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDefaultInputMode, mode);
  }

  Future<void> setDefaultClassLevel(String level) async {
    state = state.copyWith(defaultClassLevel: level);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kDefaultClass, level);
  }

  Future<void> setStudyReminder({
    required bool enabled,
    String? time,
  }) async {
    final String updatedTime = time ?? state.studyReminderTime;
    state = state.copyWith(
      studyReminderEnabled: enabled,
      studyReminderTime: updatedTime,
    );
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, enabled);
    await prefs.setString(_kReminderTime, updatedTime);

    if (enabled) {
      await FeedbackAndNotificationService.instance
          .sendStudyReminderConfirmationPush(updatedTime);
    }
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    state = state.copyWith(hapticFeedbackEnabled: enabled);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHaptics, enabled);
  }

  Future<void> setSoundEffectsEnabled(bool enabled) async {
    state = state.copyWith(soundEffectsEnabled: enabled);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSoundEffects, enabled);
  }

  Future<void> setPushNotificationsEnabled(bool enabled) async {
    state = state.copyWith(pushNotificationsEnabled: enabled);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPushNotifications, enabled);
    if (enabled) {
      await FeedbackAndNotificationService.instance.initialize();
    }
  }

  Future<void> resetAllSettingsToDefaults() async {
    state = const AppSettingsState();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kThemeMode);
    await prefs.remove(_kDarkMathCanvas);
    await prefs.remove(_kMathFontScale);
    await prefs.remove(_kDefaultInputMode);
    await prefs.remove(_kDefaultClass);
    await prefs.remove(_kReminderEnabled);
    await prefs.remove(_kReminderTime);
    await prefs.remove(_kHaptics);
    await prefs.remove(_kSoundEffects);
    await prefs.remove(_kPushNotifications);
  }
}

final appSettingsProvider =
StateNotifierProvider<AppSettingsNotifier, AppSettingsState>((ref) {
  return AppSettingsNotifier();
});