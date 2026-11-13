import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  final int initialTabIndex;

  const TermsAndConditionsScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  Widget _buildPolicySection({
    required IconData icon,
    required String title,
    required List<String> paragraphs,
    Color? highlightColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: highlightColor ?? Colors.deepPurple.shade100,
          width: 1.4,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Icon(icon, color: Colors.deepPurple, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...paragraphs.map(
                  (text) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.8,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex.clamp(0, 2),
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          title: const Text(
            'Legal, Terms & Affiliate Policy',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.amber,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'Terms of Use'),
              Tab(text: 'Affiliate Rules'),
              Tab(text: 'Privacy Policy'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: TERMS & CONDITIONS
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPolicySection(
                  icon: Icons.timer_outlined,
                  title: '1. 7-Day Free Trial (First-Time Users Only)',
                  paragraphs: [
                    '• Every genuine first-time user who registers on Math Guru receives complimentary 7-day access to all JSS 1, JSS 2, and JSS 3 step-by-step solvers, interactive visualizers, and AI textbook image extraction.',
                    '• Once the 7-day free trial period expires, an active Monthly (₦1,500/month) or Annual (₦12,000/annum) subscription is required to continue accessing curriculum topics.',
                  ],
                ),
                _buildPolicySection(
                  icon: Icons.security_update_warning_rounded,
                  title:
                  '2. Account Deletion & Strict Anti-Abuse Policy (No Repeat Free Trials)',
                  highlightColor: Colors.red.shade300,
                  paragraphs: [
                    '• You may delete your Math Guru account at any time from your Profile page.',
                    '• IMPORTANT: Deleting your account does NOT reset your eligibility for a 7-day free trial. When an account is deleted, Math Guru permanently retains a cryptographic SHA-256 record of the email address.',
                    '• If you re-register using an email address that previously belonged to a deleted account, you will NOT receive a second free trial and will be required to complete a paid subscription immediately to activate access.',
                  ],
                ),
                _buildPolicySection(
                  icon: Icons.payments_outlined,
                  title: '3. Subscription Plans & Billing (₦1,500 / ₦12,000)',
                  paragraphs: [
                    '• Standard Monthly Plan: ₦1,500 for 30 days of full access.',
                    '• Standard Annual Plan: ₦12,000 for 365 days of full access (saving 33% compared to monthly billing).',
                    '• Payments are processed securely via Paystack (Naira Debit Cards, Bank Transfer, USSD, OPay/PalmPay) or Google Play Billing. Because digital educational content is unlocked immediately upon payment, completed subscription fees are non-refundable.',
                  ],
                ),
                _buildPolicySection(
                  icon: Icons.menu_book_outlined,
                  title: '4. Fair Use & Academic Integrity',
                  paragraphs: [
                    '• Math Guru is designed as a step-by-step learning companion aligned with the Nigerian NERDC JSS 1–3 Mathematics curriculum.',
                    '• Sharing a single subscription account across multiple unauthorized devices simultaneously is prohibited.',
                  ],
                ),
              ],
            ),

            // TAB 2: TEACHER & SCHOOL AFFILIATE PROGRAM
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPolicySection(
                  icon: Icons.campaign_outlined,
                  title: '1. How the Teacher & School Promo Code Works',
                  paragraphs: [
                    '• Registered Teachers automatically receive a unique promo code prefixed with "TCHR-". When a student applies a Teacher promo code at checkout, the student receives a 10% discount (paying ₦1,350 Monthly or ₦10,800 Annually) AND an equal 10% commission (₦150 Monthly or ₦1,200 Annually) is credited to the Teacher\'s Math Guru Wallet.',
                    '• Registered Partner Schools automatically receive a unique promo code prefixed with "SCH-". When a student applies a School promo code at checkout, the student receives a 15% discount (paying ₦1,275 Monthly or ₦10,200 Annually) AND an equal 15% commission (₦225 Monthly or ₦1,800 Annually) is credited to the School\'s Math Guru Wallet.',
                  ],
                ),
                _buildPolicySection(
                  icon: Icons.account_balance_wallet_outlined,
                  title:
                  '2. Minimum Withdrawal Thresholds (₦20,000 & ₦50,000)',
                  highlightColor: Colors.green.shade400,
                  paragraphs: [
                    '• Teacher Affiliate Accounts: You can request an automated bank payout once your available wallet balance reaches a minimum of ₦20,000.',
                    '• School Partner Accounts: You can request an automated bank payout once your available wallet balance reaches a minimum of ₦50,000.',
                    '• Commissions are credited only when a student completes a verified paid subscription (free-trial sign-ups do not generate cash commission until the student subscribes).',
                  ],
                ),
                _buildPolicySection(
                  icon: Icons.account_balance_outlined,
                  title: '3. Automated Nigerian Bank Transfers',
                  paragraphs: [
                    '• Teachers and Schools must provide a valid 10-digit Nigerian NUBAN bank account number and matching account name in their Profile before requesting a payout.',
                    '• Once the minimum threshold is met and "Withdraw to Bank" is tapped, funds are transferred directly into the linked bank account.',
                  ],
                ),
              ],
            ),

            // TAB 3: PRIVACY POLICY
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPolicySection(
                  icon: Icons.lock_outline,
                  title: '1. Device Credential Memory & Encryption',
                  paragraphs: [
                    '• For your convenience, when "Remember email & password on this device" is enabled, Math Guru stores your login credentials locally inside your phone\'s hardware-encrypted storage (Android EncryptedSharedPreferences / iOS Keychain) so you can sign back in effortlessly after logging out.',
                    '• You can remove saved credentials from your device at any time directly on the Sign-In screen.',
                  ],
                ),
                _buildPolicySection(
                  icon: Icons.privacy_tip_outlined,
                  title: '2. Data We Collect & How We Use It',
                  paragraphs: [
                    '• We collect your name, email address, role (Student, Teacher, or School), class level, school name, and state of residence to personalize your curriculum and manage your subscription or affiliate wallet.',
                    '• If you are a Teacher or School Partner, your bank account number is used strictly for sending your affiliate commission payouts.',
                    '• Textbook photos snapped with AI Vision are transmitted securely to the Gemini AI Vision API solely to extract and solve the mathematical problem.',
                  ],
                ),
              ],
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'I Understand & Accept',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}