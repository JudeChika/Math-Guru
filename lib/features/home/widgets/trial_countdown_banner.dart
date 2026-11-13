import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../controllers/auth_controller.dart';
import '../../../models/user_account_model.dart';
import '../../subscription/subscription_paywall_screen.dart';

/// Drop `const TrialCountdownBanner()` at the top of your `home_page.dart` body!
/// It updates every second to show a live countdown (Days, Hours, Minutes, Seconds)
/// of the user's 7-Day Free Trial (or their active Monthly/Annual Pro subscription).
class TrialCountdownBanner extends ConsumerStatefulWidget {
  const TrialCountdownBanner({super.key});

  @override
  ConsumerState<TrialCountdownBanner> createState() =>
      _TrialCountdownBannerState();
}

class _TrialCountdownBannerState extends ConsumerState<TrialCountdownBanner> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _now = DateTime.now());
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatLiveCountdown(DateTime targetDate) {
    final Duration diff = targetDate.difference(_now);
    if (diff.isNegative || diff.inSeconds <= 0) {
      return '0d 00h 00m 00s';
    }
    final int days = diff.inDays;
    final int hours = diff.inHours % 24;
    final int minutes = diff.inMinutes % 60;
    final int seconds = diff.inSeconds % 60;

    final String h = hours.toString().padLeft(2, '0');
    final String m = minutes.toString().padLeft(2, '0');
    final String s = seconds.toString().padLeft(2, '0');
    return '${days}d ${h}h ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(currentUserAccountProvider);
    final UserAccountModel? account = accountAsync.value;
    if (account == null) return const SizedBox.shrink();

    final bool isPaidActive = account.subscriptionStatus == 'active' &&
        account.subscriptionExpiryDate != null &&
        account.subscriptionExpiryDate!.isAfter(_now);

    final bool isInTrial = !account.isReturningDeletedUser &&
        account.subscriptionStatus == 'trial' &&
        account.trialEndDate.isAfter(_now);

    final List<Color> gradientColors = isPaidActive
        ? [Colors.green.shade800, Colors.teal.shade600]
        : (isInTrial
        ? [Colors.deepPurple.shade800, Colors.indigo.shade700]
        : [Colors.red.shade800, Colors.deepOrange.shade700]);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradientColors),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaidActive
                  ? Icons.workspace_premium_rounded
                  : (isInTrial
                  ? Icons.timer_outlined
                  : Icons.warning_amber_rounded),
              color: Colors.amberAccent,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPaidActive
                      ? 'Math Guru Pro (${account.subscriptionPlan.toUpperCase()})'
                      : (isInTrial
                      ? '⏳ 7-Day Free Trial: ${_formatLiveCountdown(account.trialEndDate)}'
                      : '🔒 Free Trial Expired — Subscribe to Unlock Topics'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaidActive
                      ? '${account.paidSubscriptionDaysRemaining} days remaining on your active plan'
                      : (isInTrial
                      ? 'Enjoy full access! Subscribe anytime for ₦1,500/mo or ₦12,000/yr'
                      : 'Plans: ₦1,500/mo or ₦12,000/yr (10%–15% off with Promo Code)'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SubscriptionPaywallScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade400,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              isPaidActive ? 'Manage' : 'Upgrade',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}