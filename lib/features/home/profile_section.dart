import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_account_model.dart';
import '../auth/terms_and_conditions_screen.dart';
import '../subscription/subscription_paywall_screen.dart';
import 'edit_profile_screen.dart';
import 'home_page.dart';

class ProfileSection extends ConsumerStatefulWidget {
  const ProfileSection({super.key});

  @override
  ConsumerState<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends ConsumerState<ProfileSection> {
  bool _isWithdrawing = false;

  String _formatNaira(double amount) {
    final int rounded = amount.round();
    final String str = rounded.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₦$formatted';
  }

  Future<void> _handleAffiliateWithdrawal(UserAccountModel account) async {
    if (!account.canRequestWithdrawal) {
      final double minReq = account.role.minimumWithdrawalNaira;
      final double needed = minReq - account.walletBalance;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Minimum withdrawal for a ${account.role.displayLabel} is ${_formatNaira(minReq)}. You need ${_formatNaira(needed)} more to unlock bank withdrawal.',
          ),
          backgroundColor: Colors.orange.shade900,
        ),
      );
      return;
    }

    if (account.accountNumber.trim().length < 10 ||
        account.bankName.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please link your 10-digit Nigerian Bank Account in "Edit Profile & Bank Details" first.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
      );
      return;
    }

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Automated Bank Payout',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.deepPurple),
        ),
        content: Text(
          'Transfer ${_formatNaira(account.walletBalance)} directly to:\n\n'
              '• Bank: ${account.bankName}\n'
              '• Account Number: ${account.accountNumber}\n'
              '• Account Name: ${account.accountName}\n\n'
              'Proceed with automated transfer?',
          style: const TextStyle(fontSize: 14, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(ctx).pop(true),
            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            label: const Text('Send to My Bank'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isWithdrawing = true);
    try {
      final String reqId = await ref
          .read(authControllerProvider.notifier)
          .requestAffiliateWithdrawal(account: account);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ Payout of ${_formatNaira(account.walletBalance)} initiated (Ref: $reqId) to ${account.bankName} (${account.accountNumber})!',
          ),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Withdrawal failed: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isWithdrawing = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount(UserAccountModel account) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Delete Account Permanently?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete your Math Guru account?\n\n'
              '⚠️ IMPORTANT ANTI-ABUSE NOTICE:\n'
              'Deleting your account will NOT reset your 7-day free trial. If you register again in the future with this email address, you will NOT receive another free trial and must pay for a Monthly (₦1,500) or Annual (₦12,000) subscription immediately.',
          style: TextStyle(fontSize: 13.8, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep My Account'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authControllerProvider.notifier).deleteAccount();
        if (mounted) {
          context.go('/sign-in');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not delete account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildSubscriptionBanner(UserAccountModel account) {
    final bool isPaidActive = account.subscriptionStatus == 'active' &&
        account.paidSubscriptionDaysRemaining > 0;
    final bool inTrial = account.isInFreeTrial;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPaidActive
              ? [Colors.green.shade800, Colors.teal.shade600]
              : (inTrial
              ? [Colors.deepPurple.shade700, Colors.indigo.shade600]
              : [Colors.red.shade800, Colors.deepOrange.shade700]),
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPaidActive
                    ? Icons.workspace_premium_rounded
                    : (inTrial ? Icons.timer_outlined : Icons.lock_outline),
                color: Colors.amberAccent,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaidActive
                          ? 'Math Guru Pro (${account.subscriptionPlan.toUpperCase()})'
                          : (inTrial
                          ? '7-Day Free Trial Active'
                          : 'Subscription Expired'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      isPaidActive
                          ? '${account.paidSubscriptionDaysRemaining} days remaining on your paid subscription'
                          : (inTrial
                          ? '${account.trialDaysRemaining} day(s) left in your first-time free trial'
                          : 'Subscribe now (₦1,500/mo or ₦12,000/yr) to unlock all topics'),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SubscriptionPaywallScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.bolt_rounded, size: 18),
              label: Text(
                isPaidActive
                    ? 'Extend / Manage Subscription'
                    : 'Subscribe Now (₦1,500/mo • ₦12,000/yr)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade400,
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAffiliateDashboardCard(UserAccountModel account) {
    if (account.role == UserRole.student) return const SizedBox.shrink();

    final String code = account.promoCode ?? 'GENERATING...';
    final int cutPct = account.role == UserRole.school ? 15 : 10;
    final double minThreshold = account.role.minimumWithdrawalNaira;
    final double progress = account.withdrawalThresholdProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade200, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                child: const Icon(Icons.account_balance_wallet,
                    color: Colors.deepPurple),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${account.role.displayLabel} Earnings & Promo Hub',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.5,
                        color: Colors.deepPurple,
                      ),
                    ),
                    Text(
                      'Students get $cutPct% OFF • You earn $cutPct% on every subscription!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Unique Promo Code Box with Copy & WhatsApp Share
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YOUR UNIQUE PROMO CODE:',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Copy Code',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Promo code "$code" copied!'),
                        backgroundColor: Colors.deepPurple,
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, color: Colors.deepPurple),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final String shareMsg =
                        '📚 Master JSS 1–3 Mathematics step-by-step with the Math Guru App!\n\n'
                        'Use our official promo code *$code* at checkout to get *$cutPct% OFF* your Monthly (₦1,500) or Annual (₦12,000) subscription!';
                    Share.share(shareMsg);
                  },
                  icon: const Icon(Icons.share, size: 16, color: Colors.white),
                  label: const Text(
                    'Share',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Wallet Metrics Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  label: 'Available Balance',
                  value: _formatNaira(account.walletBalance),
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Total Withdrawn',
                  value: _formatNaira(account.totalWithdrawn),
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  label: 'Subscribed Students',
                  value: '${account.activeSubscribedReferralsCount}',
                  color: Colors.orange.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar toward ₦20,000 (Teacher) or ₦50,000 (School)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payout Threshold (${_formatNaira(minThreshold)} min):',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                account.canRequestWithdrawal
                    ? Colors.green.shade700
                    : Colors.deepPurple,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Linked Bank Account Status
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(
                  account.accountNumber.length == 10
                      ? Icons.check_circle
                      : Icons.info_outline,
                  color: account.accountNumber.length == 10
                      ? Colors.green
                      : Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    account.accountNumber.length == 10
                        ? 'Payout Bank: ${account.bankName} • ${account.accountNumber} (${account.accountName})'
                        : 'No payout bank account linked yet. Tap "Edit Profile & Bank" below to link your account.',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Automated Withdraw Button
          ElevatedButton.icon(
            onPressed: _isWithdrawing
                ? null
                : () => _handleAffiliateWithdrawal(account),
            icon: const Icon(Icons.account_balance_rounded,
                color: Colors.white, size: 18),
            label: Text(
              account.canRequestWithdrawal
                  ? 'Withdraw ${_formatNaira(account.walletBalance)} to My Bank Now'
                  : 'Withdraw to Bank (Unlocks at ${_formatNaira(minThreshold)})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: account.canRequestWithdrawal
                  ? Colors.green.shade700
                  : Colors.grey.shade500,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(currentUserAccountProvider);

    return accountAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),
      error: (err, _) => Center(child: Text('Error loading profile: $err')),
      data: (UserAccountModel? account) {
        if (account == null) {
          return Center(
            child: ElevatedButton(
              onPressed: () => context.go('/sign-in'),
              child: const Text('Sign In to View Profile'),
            ),
          );
        }

        final double topInset = MediaQuery.of(context).padding.top;

        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Stack(
            children: [
              // BackgroundWaves placed inside the SingleChildScrollView so background & content scroll together!
              const Positioned.fill(child: BackgroundWaves()),
              Padding(
                padding: EdgeInsets.fromLTRB(16.0, topInset + 12.0, 16.0, 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Modern Profile Header Card
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.deepPurple.shade100),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: Colors.deepPurple.shade100,
                            child: Text(
                              account.name.isNotEmpty
                                  ? account.name[0].toUpperCase()
                                  : 'M',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  account.name,
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  account.email,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.deepPurple,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        account.role.displayLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    if (account.role == UserRole.student)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.shade100,
                                          borderRadius:
                                          BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          account.classLevel,
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        account.stateOfResidence,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit Profile',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Live Subscription Status Banner
                    _buildSubscriptionBanner(account),

                    // Properly Listed Personal, Academic & Account Details Card
                    _buildProfileDetailsListCard(account),

                    // Teacher / School Affiliate Dashboard Card
                    _buildAffiliateDashboardCard(account),

                    // Profile Actions Menu
                    Card(
                      elevation: 0.6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.edit_note_rounded,
                                color: Colors.deepPurple),
                            title: Text(
                              account.role == UserRole.student
                                  ? 'Edit Student Profile & Class'
                                  : 'Edit Profile & Payout Bank Account',
                              style:
                              const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              account.schoolName.isNotEmpty
                                  ? 'School: ${account.schoolName}'
                                  : 'Update your personal details and school info',
                              style: const TextStyle(fontSize: 12.5),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.policy_outlined,
                                color: Colors.deepPurple),
                            title: const Text(
                              'Terms & Conditions • Affiliate Policy',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: const Text(
                              'Read subscription rules, privacy & payout thresholds',
                              style: TextStyle(fontSize: 12.5),
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                  const TermsAndConditionsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.logout_rounded,
                                color: Colors.deepOrange),
                            title: const Text(
                              'Log Out',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.deepOrange,
                              ),
                            ),
                            subtitle: const Text(
                              'Your email & password stay remembered on this device for easy re-login',
                              style: TextStyle(fontSize: 12),
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
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.delete_forever_outlined,
                                color: Colors.red),
                            title: const Text(
                              'Delete Account',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                            subtitle: const Text(
                              'Permanently delete account (does not reset free trial)',
                              style: TextStyle(fontSize: 12),
                            ),
                            onTap: () => _confirmDeleteAccount(account),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Displays all of the user's personal, school, subscription, and bank details in a structured list card.
  Widget _buildProfileDetailsListCard(UserAccountModel account) {
    String formatDate(DateTime dt) {
      const List<String> months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }

    final bool isPaidActive = account.subscriptionStatus == 'active' &&
        account.paidSubscriptionDaysRemaining > 0;
    final String planSummary = isPaidActive
        ? '${account.subscriptionPlan.toUpperCase()} Plan (${account.paidSubscriptionDaysRemaining} days left)'
        : (account.isInFreeTrial
        ? '7-Day Free Trial (${account.trialDaysRemaining} days left — Ends ${formatDate(account.trialEndDate)})'
        : 'Expired — Subscription Required');

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepPurple.shade100, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.badge_outlined,
                      color: Colors.deepPurple, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'My Profile & Account Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, size: 15),
                label: const Text(
                  'Edit',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          _buildDetailItemRow(
            icon: Icons.person_outline,
            label: account.role == UserRole.school
                ? 'Official School Name'
                : 'Full Name',
            value: account.name.isNotEmpty ? account.name : 'Not set',
          ),
          _buildDetailItemRow(
            icon: Icons.email_outlined,
            label: 'Email Address',
            value: account.email.isNotEmpty ? account.email : 'Not set',
          ),
          _buildDetailItemRow(
            icon: Icons.phone_outlined,
            label: 'Phone Number',
            value: account.phoneNumber.trim().isNotEmpty
                ? account.phoneNumber
                : 'Tap Edit to add phone number',
            isMuted: account.phoneNumber.trim().isEmpty,
          ),
          _buildDetailItemRow(
            icon: Icons.verified_user_outlined,
            label: 'Account Role',
            value: account.role.displayLabel,
          ),
          if (account.role == UserRole.student)
            _buildDetailItemRow(
              icon: Icons.class_outlined,
              label: 'Class Level',
              value: account.classLevel,
            ),
          if (account.role != UserRole.school)
            _buildDetailItemRow(
              icon: Icons.school_outlined,
              label: account.role == UserRole.teacher
                  ? 'School Where You Teach'
                  : 'School Name',
              value: account.schoolName.trim().isNotEmpty
                  ? account.schoolName
                  : 'Tap Edit to add school name',
              isMuted: account.schoolName.trim().isEmpty,
            ),
          _buildDetailItemRow(
            icon: Icons.location_on_outlined,
            label: 'State of Residence',
            value: account.stateOfResidence,
          ),
          _buildDetailItemRow(
            icon: Icons.card_membership_outlined,
            label: 'Subscription Status',
            value: planSummary,
          ),
          if (account.appliedPromoCode != null &&
              account.appliedPromoCode!.trim().isNotEmpty)
            _buildDetailItemRow(
              icon: Icons.local_offer_outlined,
              label: 'Applied Promo Code',
              value: account.appliedPromoCode!,
            ),
          if (account.role != UserRole.student) ...[
            _buildDetailItemRow(
              icon: Icons.campaign_outlined,
              label: 'Your Official Promo Code',
              value:
              '${account.promoCode ?? "Generating..."} (${account.role == UserRole.school ? "15%" : "10%"} Cut)',
            ),
            _buildDetailItemRow(
              icon: Icons.account_balance_outlined,
              label: 'Linked Payout Bank',
              value: account.accountNumber.trim().length == 10
                  ? '${account.bankName} • ${account.accountNumber} (${account.accountName})'
                  : 'Not linked yet (Tap Edit to link NUBAN)',
              isMuted: account.accountNumber.trim().length != 10,
              isLast: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItemRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMuted = false,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 2.0 : 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 17, color: Colors.deepPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isMuted ? FontWeight.normal : FontWeight.bold,
                    fontStyle: isMuted ? FontStyle.italic : FontStyle.normal,
                    color: isMuted ? Colors.grey.shade500 : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}