import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../provider/settings_provider.dart';

/// Centralized service that handles:
/// 1. Tactile Haptic Vibration when solutions are generated or presets are loaded
/// 2. Crisp System Sound notifications
/// 3. Native Android / iOS Push Notifications (via `flutter_local_notifications`)
class FeedbackAndNotificationService {
  FeedbackAndNotificationService._();
  static final FeedbackAndNotificationService instance =
  FeedbackAndNotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  DateTime _lastTriggeredAt = DateTime.fromMillisecondsSinceEpoch(0);

  /// Initializes the local push notification channel and requests Android 13+ / iOS permissions.
  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) return;
    try {
      const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings iosSettings =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(initSettings);

      // Request Android 13+ (API 33+) runtime notification permission
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();

      _isInitialized = true;
    } catch (e) {
      debugPrint('Notification service initialization warning: $e');
    }
  }

  /// Triggers Haptic Vibration, Sound Effect, and Push Notification based on the user's Settings.
  Future<void> triggerSolutionGeneratedFeedback({
    required AppSettingsState settings,
    String title = '✅ Math Guru Solution Ready!',
    String body =
    'Step-by-step workings, formulas, and interactive visualizer generated.',
    bool isPresetLoad = false,
    bool forcePushNotification = false,
  }) async {
    // Debounce rapid double-taps within 350ms
    final DateTime now = DateTime.now();
    if (now.difference(_lastTriggeredAt).inMilliseconds < 350) return;
    _lastTriggeredAt = now;

    // 1. HAPTIC VIBRATION FEEDBACK
    if (settings.hapticFeedbackEnabled) {
      try {
        await HapticFeedback.heavyImpact();
        await Future<void>.delayed(const Duration(milliseconds: 60));
        await HapticFeedback.vibrate();
        if (!isPresetLoad) {
          await Future<void>.delayed(const Duration(milliseconds: 80));
          await HapticFeedback.mediumImpact();
        }
      } catch (e) {
        debugPrint('Haptic feedback warning: $e');
      }
    }

    // 2. SOUND EFFECT NOTIFICATION
    if (settings.soundEffectsEnabled) {
      try {
        await SystemSound.play(SystemSoundType.click);
        if (!isPresetLoad) {
          await Future<void>.delayed(const Duration(milliseconds: 90));
          await SystemSound.play(SystemSoundType.alert);
        }
      } catch (e) {
        debugPrint('Sound effect warning: $e');
      }
    }

    // 3. SYSTEM PUSH NOTIFICATION
    if ((settings.pushNotificationsEnabled && !isPresetLoad) ||
        forcePushNotification) {
      await showInstantPushNotification(
        title: title,
        body: body,
        playSound: settings.soundEffectsEnabled,
        enableVibration: settings.hapticFeedbackEnabled,
      );
    }
  }

  /// Displays a real Android / iOS Heads-Up Push Notification in the device status bar.
  Future<void> showInstantPushNotification({
    required String title,
    required String body,
    bool playSound = true,
    bool enableVibration = true,
  }) async {
    if (kIsWeb) return;
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'math_guru_solutions_channel_v1',
        'Math Guru Solutions & Study Alerts',
        channelDescription:
        'Notifications when Math Guru generates step-by-step solutions and daily study reminders.',
        importance: Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: enableVibration,
        icon: '@mipmap/ic_launcher',
      );

      final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: playSound,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        platformDetails,
      );
    } catch (e) {
      debugPrint('Push notification display warning: $e');
    }
  }

  /// Sends a confirmation push notification when the user sets or updates their Daily Study Reminder.
  Future<void> sendStudyReminderConfirmationPush(String timeStr) async {
    await showInstantPushNotification(
      title: '⏰ Math Guru Daily Study Reminder Active',
      body:
      'We will remind you to practice JSS & SSS Mathematics daily at $timeStr!',
    );
  }

  /// Inspects the widget tree under a user's tap (`PointerUpEvent`).
  /// If the user tapped a Solver button ("Calculate...", "Solve...", "Find...", "Extract...", "Draw...", "Construct...")
  /// or a Textbook Preset chip (`ActionChip`), it automatically fires Haptic Vibration, Sound & Push Notification
  /// across ALL 300+ screens without needing manual code inside each topic file!
  void handleGlobalPointerUp(
      PointerUpEvent event,
      BuildContext rootContext,
      AppSettingsState settings,
      ) {
    if (!settings.hapticFeedbackEnabled &&
        !settings.soundEffectsEnabled &&
        !settings.pushNotificationsEnabled) {
      return;
    }

    try {
      final RenderObject? renderObject = rootContext.findRenderObject();
      if (renderObject is! RenderBox) return;

      final BoxHitTestResult result = BoxHitTestResult();
      final Offset localPos = renderObject.globalToLocal(event.position);
      if (!renderObject.hitTest(result, position: localPos)) return;

      bool isSolveButtonTap = false;
      bool isPresetChipTap = false;
      String? detectedButtonLabel;

      for (final HitTestEntry entry in result.path) {
        final HitTestTarget target = entry.target;
        if (target is RenderObject) {
          final Object? debugCreator = target.debugCreator;
          if (debugCreator is DebugCreator) {
            Element? current = debugCreator.element;
            int depth = 0;
            while (current != null && depth < 18) {
              final Widget? w = current?.widget;

              if (w is ActionChip) {
                isPresetChipTap = true;
                if (w.label is Text) {
                  detectedButtonLabel = (w.label as Text).data;
                }
                break;
              }

              if (w is ElevatedButton) {
                final String labelText = _extractTextFromSubtree(current!);
                final String lower = labelText.toLowerCase();
                if (lower.contains('calculate') ||
                    lower.contains('solve') ||
                    lower.contains('find') ||
                    lower.contains('extract') ||
                    lower.contains('construct') ||
                    lower.contains('draw') ||
                    lower.contains('evaluate') ||
                    lower.contains('convert') ||
                    lower.contains('simplify') ||
                    lower.contains('factor')) {
                  isSolveButtonTap = true;
                  detectedButtonLabel = labelText;
                  break;
                }
              }

              current?.visitAncestorElements((Element ancestor) {
                current = ancestor;
                return false;
              });
              depth++;
            }
          }
        }
        if (isSolveButtonTap || isPresetChipTap) break;
      }

      if (isSolveButtonTap) {
        triggerSolutionGeneratedFeedback(
          settings: settings,
          title: '✅ Math Guru Solution Generated!',
          body: detectedButtonLabel != null && detectedButtonLabel.isNotEmpty
              ? '$detectedButtonLabel — Step-by-step workings & visualizer ready.'
              : 'Your step-by-step mathematical workings & visualizer are ready.',
          isPresetLoad: false,
        );
      } else if (isPresetChipTap) {
        triggerSolutionGeneratedFeedback(
          settings: settings,
          title: '📘 Textbook Example Loaded!',
          body: detectedButtonLabel ??
              'Preset example solved step-by-step.',
          isPresetLoad: true,
        );
      }
    } catch (_) {}
  }

  String _extractTextFromSubtree(Element root) {
    final StringBuffer buffer = StringBuffer();
    void visit(Element el) {
      final Widget w = el.widget;
      if (w is Text && w.data != null) {
        buffer.write('${w.data} ');
      }
      el.visitChildren(visit);
    }

    visit(root);
    return buffer.toString().trim();
  }
}