import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/auth_controller.dart';
import '../../core/provider/settings_provider.dart';
import '../../core/services/feedback_and_notification_service.dart';
import '../../core/theme/app_themes.dart';
import '../../models/user_account_model.dart';
import '../auth/terms_and_conditions_screen.dart';
import '../home/change_password_dialog.dart';
import '../home/edit_profile_screen.dart';
import '../subscription/subscription_paywall_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _savedAccountCount = 0;

  @override
  void initState() {
    super.initState();
    _loadSavedAccountsCount();
  }

  Future<void> _loadSavedAccountsCount() async {
    final list = await ref
        .read(authControllerProvider.notifier)
        .getSavedDeviceAccounts();
    if (mounted) {
      setState(() => _savedAccountCount = list.length);
    }
  }

  Future<void> _pickStudyReminderTime(String currentTime) async {
    final parts = currentTime.split(':');
    final int initialHour = int.tryParse(parts.first) ?? 17;
    final int initialMinute =
    parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: initialHour, minute: initialMinute),
    );

    if (picked != null) {
      final String formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      await ref.read(appSettingsProvider.notifier).setStudyReminder(
        enabled: true,
        time: formatted,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '⏰ Daily Mathematics study reminder set for ${picked.format(context)}!'),
            backgroundColor: Colors.deepPurple,
          ),
        );
      }
    }
  }

  Future<void> _clearSavedDeviceVault() async {
    final accounts = await ref
        .read(authControllerProvider.notifier)
        .getSavedDeviceAccounts();
    for (final acc in accounts) {
      await ref
          .read(authControllerProvider.notifier)
          .removeSavedDeviceAccount(acc.email);
    }
    await _loadSavedAccountsCount();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '🔐 Saved device login credentials cleared from this phone.'),
          backgroundColor: Colors.deepPurple,
        ),
      );
    }
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10, top: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: isDark ? Colors.amberAccent : Colors.deepPurple,
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.amberAccent : Colors.deepPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({
    required bool isDark,
    required Widget child,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemes.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.10)
              : Colors.deepPurple.shade100,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final bool isDark = AppThemes.isDark(context, ref);
    final UserAccountModel? account =
        ref.watch(currentUserAccountProvider).value;

    final Color textPrimary = isDark ? Colors.white : Colors.black87;
    final Color textSecondary =
    isDark ? Colors.white70 : Colors.grey.shade700;

    return Scaffold(
      backgroundColor:
      isDark ? AppThemes.darkBackground : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor:
        isDark ? AppThemes.darkSurface : Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings & Study Preferences',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Reset to Defaults',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () async {
              await ref
                  .read(appSettingsProvider.notifier)
                  .resetAllSettingsToDefaults();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings restored to default values.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // =================================================================
            // 1. APPEARANCE & DISPLAY PREFERENCES
            // =================================================================
            _buildSectionHeader(
              icon: Icons.palette_outlined,
              title: '1. Appearance & Dark Mode',
              isDark: isDark,
            ),
            _buildCardContainer(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Theme Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose System Default to automatically match your phone\'s Light/Dark setting:',
                    style: TextStyle(fontSize: 12.5, color: textSecondary),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<ThemeMode>(
                      groupValue: settings.themeMode,
                      thumbColor: Colors.deepPurple,
                      backgroundColor: isDark
                          ? AppThemes.darkBackground
                          : Colors.deepPurple.shade50,
                      children: {
                        ThemeMode.system: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '📱 System',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: settings.themeMode == ThemeMode.system
                                  ? Colors.white
                                  : textPrimary,
                            ),
                          ),
                        ),
                        ThemeMode.light: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '☀️ Light',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: settings.themeMode == ThemeMode.light
                                  ? Colors.white
                                  : textPrimary,
                            ),
                          ),
                        ),
                        ThemeMode.dark: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            '🌙 Dark',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: settings.themeMode == ThemeMode.dark
                                  ? Colors.white
                                  : textPrimary,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (ThemeMode? mode) {
                        if (mode != null) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setThemeMode(mode);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 24),

                  // Dark Math Canvas Switch
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurpleAccent,
                    title: Text(
                      'Dark Math Workings & Graph Canvas',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'When Dark Mode is on, convert white math cards, LaTeX equations & graph canvases to eye-friendly dark slate.',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    value: settings.darkMathCanvasEnabled,
                    onChanged: (val) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setDarkMathCanvasEnabled(val);
                    },
                  ),
                  const Divider(height: 20),

                  // Math Formula & Text Size Scaler
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Text & Math Formula Size',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: textPrimary,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          settings.mathFontScale <= 0.95
                              ? 'Compact (90%)'
                              : (settings.mathFontScale >= 1.10
                              ? 'Large (115%)'
                              : 'Standard (100%)'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.amberAccent
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: settings.mathFontScale,
                    min: 0.90,
                    max: 1.15,
                    divisions: 2,
                    activeColor: Colors.deepPurple,
                    onChanged: (val) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setMathFontScale(val);
                    },
                  ),
                ],
              ),
            ),

            // =================================================================
            // 2. STUDY & SMART SOLVER PREFERENCES
            // =================================================================
            _buildSectionHeader(
              icon: Icons.psychology_outlined,
              title: '2. Study & Solver Preferences',
              isDark: isDark,
            ),
            _buildCardContainer(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Default Solver Input Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoSlidingSegmentedControl<int>(
                      groupValue: settings.defaultSolverInputMode,
                      thumbColor: Colors.deepPurple,
                      backgroundColor: isDark
                          ? AppThemes.darkBackground
                          : Colors.deepPurple.shade50,
                      children: {
                        1: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Text(
                            '🛠️ Manual Builder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: settings.defaultSolverInputMode == 1
                                  ? Colors.white
                                  : textPrimary,
                            ),
                          ),
                        ),
                        0: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          child: Text(
                            '📷 AI Vision Camera',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              color: settings.defaultSolverInputMode == 0
                                  ? Colors.white
                                  : textPrimary,
                            ),
                          ),
                        ),
                      },
                      onValueChanged: (int? val) {
                        if (val != null) {
                          ref
                              .read(appSettingsProvider.notifier)
                              .setDefaultSolverInputMode(val);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 24),

                  // Daily Study Reminder Toggle & Time Picker
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurpleAccent,
                    title: Text(
                      'Daily Mathematics Study Reminder',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Scheduled for ${settings.studyReminderTime} daily',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    value: settings.studyReminderEnabled,
                    onChanged: (val) {
                      ref
                          .read(appSettingsProvider.notifier)
                          .setStudyReminder(enabled: val);
                    },
                  ),
                  if (settings.studyReminderEnabled)
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _pickStudyReminderTime(settings.studyReminderTime),
                        icon: const Icon(Icons.access_time_rounded, size: 17),
                        label: Text(
                          'Change Time (${settings.studyReminderTime})',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ),
                    ),
                  const Divider(height: 20),

                  // 1. Haptic Vibration Feedback Toggle
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurpleAccent,
                    secondary: Icon(
                      Icons.vibration_rounded,
                      color: isDark ? Colors.amberAccent : Colors.deepPurple,
                    ),
                    title: Text(
                      'Haptic Vibration Feedback',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Vibrate phone when Math Guru generates a step-by-step solution',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    value: settings.hapticFeedbackEnabled,
                    onChanged: (val) async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setHapticFeedbackEnabled(val);
                      if (val) {
                        await HapticFeedback.heavyImpact();
                        await HapticFeedback.vibrate();
                      }
                    },
                  ),
                  const Divider(height: 16),

                  // 2. Sound Notification Toggle
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurpleAccent,
                    secondary: Icon(
                      Icons.volume_up_rounded,
                      color: isDark ? Colors.amberAccent : Colors.deepPurple,
                    ),
                    title: Text(
                      'Solution Sound Notification',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Play an audio chime when an answer or preset is solved',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    value: settings.soundEffectsEnabled,
                    onChanged: (val) async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setSoundEffectsEnabled(val);
                      if (val) {
                        await SystemSound.play(SystemSoundType.click);
                        await SystemSound.play(SystemSoundType.alert);
                      }
                    },
                  ),
                  const Divider(height: 16),

                  // 3. Push Notification Toggle
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.deepPurpleAccent,
                    secondary: Icon(
                      Icons.notifications_active_outlined,
                      color: isDark ? Colors.amberAccent : Colors.deepPurple,
                    ),
                    title: Text(
                      'Push Notifications',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Receive system push alerts when solutions finish & for daily study reminders',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    value: settings.pushNotificationsEnabled,
                    onChanged: (val) async {
                      await ref
                          .read(appSettingsProvider.notifier)
                          .setPushNotificationsEnabled(val);
                      if (val) {
                        await FeedbackAndNotificationService.instance
                            .showInstantPushNotification(
                          title: '🔔 Math Guru Push Notifications Enabled',
                          body:
                          'You will now receive solution alerts and daily study notifications!',
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // 1-Tap Test Button so the user can immediately verify Vibration, Sound & Push Notification!
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FeedbackAndNotificationService.instance
                            .triggerSolutionGeneratedFeedback(
                          settings: ref.read(appSettingsProvider),
                          title: '🎉 Math Guru Notification Test!',
                          body:
                          'Vibration, Sound & Push Notifications are working on your device!',
                          forcePushNotification: true,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  '✅ Triggered Haptic Vibration, Sound & Push Notification!'),
                              backgroundColor: Colors.deepPurple,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active_rounded,
                          size: 18),
                      label: const Text(
                        'Test Vibration, Sound & Push Notification Now',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor:
                        isDark ? Colors.amberAccent : Colors.deepPurple,
                        side: BorderSide(
                          color: isDark
                              ? Colors.amberAccent
                              : Colors.deepPurple.shade300,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =================================================================
            // 3. SUBSCRIPTION, AFFILIATE & ACCOUNT SECURITY
            // =================================================================
            _buildSectionHeader(
              icon: Icons.security_outlined,
              title: '3. Account, Security & Subscription',
              isDark: isDark,
            ),
            _buildCardContainer(
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                      Colors.deepPurple.withValues(alpha: 0.15),
                      child: const Icon(Icons.workspace_premium_rounded,
                          color: Colors.amber),
                    ),
                    title: Text(
                      'Subscription & Promo Code Checkout',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      account != null && account.isInFreeTrial
                          ? '7-Day Free Trial Active (${account.trialDaysRemaining} days left)'
                          : 'Monthly (₦1,500) • Annual (₦12,000)',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SubscriptionPaywallScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                      Colors.deepPurple.withValues(alpha: 0.15),
                      child: const Icon(Icons.edit_outlined,
                          color: Colors.deepPurpleAccent),
                    ),
                    title: Text(
                      account?.role == UserRole.student
                          ? 'Edit Student Profile & School Details'
                          : 'Edit Profile & Payout Bank Account (NUBAN)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Update your name, phone number, state, or bank details',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                      Colors.deepPurple.withValues(alpha: 0.15),
                      child: const Icon(Icons.lock_reset_rounded,
                          color: Colors.deepPurpleAccent),
                    ),
                    title: Text(
                      'Change Account Password',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Update your login password securely',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () {
                      final String userEmail = account?.email ??
                          fb_auth.FirebaseAuth.instance.currentUser?.email ??
                          '';
                      showDialog<void>(
                        context: context,
                        builder: (_) => ChangePasswordDialog(email: userEmail),
                      );
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withValues(alpha: 0.15),
                      child: const Icon(Icons.vpn_key_off_outlined,
                          color: Colors.orange),
                    ),
                    title: Text(
                      'Clear Saved Login Credentials ($_savedAccountCount saved)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Remove remembered emails & passwords from this device vault',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    onTap: _savedAccountCount == 0
                        ? null
                        : _clearSavedDeviceVault,
                  ),
                ],
              ),
            ),

            // =================================================================
            // 4. SUPPORT, SHARE & LEGAL CENTER
            // =================================================================
            _buildSectionHeader(
              icon: Icons.support_agent_rounded,
              title: '4. Support, Share & Legal',
              isDark: isDark,
            ),
            _buildCardContainer(
              isDark: isDark,
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.green.withValues(alpha: 0.15),
                      child:
                      const Icon(Icons.share_rounded, color: Colors.green),
                    ),
                    title: Text(
                      'Share Math Guru with Friends & Students',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      account?.promoCode != null
                          ? 'Includes your promo code (${account!.promoCode}) for instant discount!'
                          : 'Invite classmates to master JSS & SSS Mathematics',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () {
                      final String promoLine = account?.promoCode != null
                          ? '\nUse promo code *${account!.promoCode}* for ${account.role == UserRole.school ? "15%" : "10%"} OFF!'
                          : '';
                      Share.share(
                        '📚 Master JSS 1–3 & SSS Mathematics step-by-step with the Math Guru App!$promoLine',
                      );
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.15),
                      child: const Icon(Icons.mail_outline_rounded,
                          color: Colors.blue),
                    ),
                    title: Text(
                      'Contact Math Guru Support',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Get help with subscriptions, promo codes, or payouts',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () async {
                      final Uri emailUri = Uri(
                        scheme: 'mailto',
                        path: 'hello@mathguru.com.ng',
                        queryParameters: {
                          'subject':
                          'Math Guru Support (${account?.email ?? "User"})',
                        },
                      );
                      await launchUrl(emailUri).catchError((_) => false);
                    },
                  ),
                  const Divider(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                      Colors.deepPurple.withValues(alpha: 0.15),
                      child: const Icon(Icons.policy_outlined,
                          color: Colors.deepPurpleAccent),
                    ),
                    title: Text(
                      'Terms of Use, Privacy & Affiliate Policy',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      'Read our 7-day trial, no-repeat-trial & payout policies',
                      style: TextStyle(fontSize: 12.5, color: textSecondary),
                    ),
                    trailing: Icon(Icons.chevron_right, color: textSecondary),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TermsAndConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  if (account != null) ...[
                    const Divider(height: 16),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.red.withValues(alpha: 0.15),
                        child: const Icon(Icons.logout_rounded,
                            color: Colors.redAccent),
                      ),
                      title: const Text(
                        'Log Out',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Colors.redAccent,
                        ),
                      ),
                      subtitle: Text(
                        'Your email & password remain remembered on this device',
                        style: TextStyle(fontSize: 12, color: textSecondary),
                      ),
                      onTap: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          context.go('/sign-in');
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),

            // Footer Version Badge
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Text(
                    'Math Guru v1.0.0 (Production Edition)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'NERDC Curriculum • JSS 1 – JSS 3 & SSS 1 – SSS 3',
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}