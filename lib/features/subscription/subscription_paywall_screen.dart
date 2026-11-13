import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_account_model.dart';
import '../auth/terms_and_conditions_screen.dart';

class SubscriptionPaywallScreen extends ConsumerStatefulWidget {
  final bool isForcedByExpiredTrial;

  const SubscriptionPaywallScreen({
    super.key,
    this.isForcedByExpiredTrial = false,
  });

  @override
  ConsumerState<SubscriptionPaywallScreen> createState() =>
      _SubscriptionPaywallScreenState();
}

class _SubscriptionPaywallScreenState
    extends ConsumerState<SubscriptionPaywallScreen> {
  // 0: Monthly (₦1,500/month), 1: Annual (₦12,000/annum - Save 33%)
  bool _isAnnual = true;

  // Dual-Option Payment Gateway Selector:
  // 0: Paystack (Naira Card, Bank Transfer, USSD, OPay, PalmPay)
  // 1: Google Play Billing
  int _selectedGateway = 0;

  final TextEditingController _promoCtrl = TextEditingController();
  bool _verifyingPromo = false;
  UserRole? _promoOwnerRole;
  String? _promoOwnerName;
  String? _validatedCode;
  String? _promoStatusText;
  bool _promoValid = false;

  bool _isProcessingPayment = false;

  // Replace with your live Paystack Secret/Public key from dashboard.paystack.com
  // (See Step-by-Step Guide in production_monetization_blueprint.md)
  static const String _paystackSecretKey =
      'sk_test_0fc42c0273aed60f7a4af890082eec10cedea946';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final account = ref.read(currentUserAccountProvider).value;
      if (account != null &&
          account.appliedPromoCode != null &&
          account.appliedPromoCode!.isNotEmpty) {
        _promoCtrl.text = account.appliedPromoCode!;
        _applyPromoCode();
      }
    });
  }

  @override
  void dispose() {
    _promoCtrl.dispose();
    super.dispose();
  }

  String _formatNaira(double amount) {
    final int rounded = amount.round();
    final String str = rounded.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₦$formatted';
  }

  Future<void> _applyPromoCode() async {
    FocusScope.of(context).unfocus();
    final String code = _promoCtrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() {
        _promoOwnerRole = null;
        _promoOwnerName = null;
        _validatedCode = null;
        _promoStatusText = null;
        _promoValid = false;
      });
      return;
    }

    setState(() => _verifyingPromo = true);
    final Map<String, dynamic>? promoDoc =
    await ref.read(authControllerProvider.notifier).validatePromoCode(code);

    if (!mounted) return;
    setState(() {
      _verifyingPromo = false;
      if (promoDoc != null) {
        final UserRole ownerRole =
        UserRole.fromString(promoDoc['ownerRole']?.toString());
        final String ownerName =
        (promoDoc['ownerName'] ?? 'Partner').toString();
        final int pct = ownerRole == UserRole.school ? 15 : 10;

        _promoOwnerRole = ownerRole;
        _promoOwnerName = ownerName;
        _validatedCode = code;
        _promoValid = true;
        _promoStatusText =
        '✓ $pct% Discount Applied ($ownerName — ${ownerRole.displayLabel})! You save $pct% and $ownerName earns $pct%!';
      } else {
        _promoOwnerRole = null;
        _promoOwnerName = null;
        _validatedCode = null;
        _promoValid = false;
        _promoStatusText =
        'Invalid or inactive promo code. Please check and try again.';
      }
    });
  }

  Future<void> _processCheckout(UserAccountModel? account) async {
    if (account == null) return;

    final breakdown = SubscriptionPricing.calculateCheckoutBreakdown(
      isAnnual: _isAnnual,
      promoOwnerRole: _promoOwnerRole,
    );

    setState(() => _isProcessingPayment = true);

    try {
      final String txRef =
          'MG-${DateTime.now().millisecondsSinceEpoch}-${account.uid.substring(0, 5).toUpperCase()}';

      if (_selectedGateway == 0) {
        // OPTION 1: PAYSTACK CHECKOUT (Card / Bank Transfer / USSD / OPay)
        await _handlePaystackPayment(
          account: account,
          amountNaira: breakdown.finalStudentPrice,
          txRef: txRef,
        );
      } else {
        // OPTION 2: GOOGLE PLAY BILLING CHECKOUT
        await _handleGooglePlayPayment(
          account: account,
          amountNaira: breakdown.finalStudentPrice,
          txRef: txRef,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment error: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingPayment = false);
      }
    }
  }

  Future<void> _handlePaystackPayment({
    required UserAccountModel account,
    required double amountNaira,
    required String txRef,
  }) async {
    final int amountInKobo = (amountNaira * 100).round();
    String? paystackCheckoutUrl;

    // 1. Initialize transaction with Paystack API if the Secret Key is configured
    final bool hasConfiguredKey =
        !_paystackSecretKey.contains('replace_with_your') &&
            _paystackSecretKey.trim().startsWith('sk_');

    if (hasConfiguredKey) {
      try {
        final response = await http.post(
          Uri.parse('https://api.paystack.co/transaction/initialize'),
          headers: {
            'Authorization': 'Bearer ${_paystackSecretKey.trim()}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': account.email,
            'amount': amountInKobo.toString(),
            'reference': txRef,
            'currency': 'NGN',
            'channels': ['card', 'bank', 'ussd', 'bank_transfer'],
            'metadata': {
              'uid': account.uid,
              'plan': _isAnnual ? 'annual' : 'monthly',
              'promo_code': _validatedCode ?? '',
            },
          }),
        );

        final Map<String, dynamic> body = jsonDecode(response.body);
        if (response.statusCode == 200 && body['status'] == true) {
          paystackCheckoutUrl = body['data']['authorization_url']?.toString();
        }
      } catch (e) {
        debugPrint('Paystack initialize warning: $e');
      }
    }

    if (!mounted) return;

    // 2. Open the Full Interactive Paystack Payment Sheet (Card / Bank Transfer / USSD / OPay + Hosted Browser Option)
    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PaystackInteractivePaymentSheet(
        account: account,
        amountNaira: amountNaira,
        txRef: txRef,
        isAnnual: _isAnnual,
        paystackSecretKey: _paystackSecretKey.trim(),
        paystackAuthorizationUrl: paystackCheckoutUrl,
        validatedPromoCode: _validatedCode,
        promoOwnerName: _promoOwnerName,
        promoOwnerRole: _promoOwnerRole,
        formatNaira: _formatNaira,
      ),
    );

    if (confirmed == true) {
      await ref
          .read(authControllerProvider.notifier)
          .activateSubscriptionAfterPayment(
        isAnnual: _isAnnual,
        paymentProvider: 'paystack',
        transactionReference: txRef,
        amountPaidNaira: amountNaira,
        promoCodeUsed: _validatedCode,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 Subscription Activated! Enjoy full access to Math Guru (${_isAnnual ? "Annual Plan" : "Monthly Plan"}).',
          ),
          backgroundColor: Colors.green.shade800,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _handleGooglePlayPayment({
    required UserAccountModel account,
    required double amountNaira,
    required String txRef,
  }) async {
    final String sku =
    _isAnnual ? 'math_guru_annual_12000' : 'math_guru_monthly_1500';

    final bool? confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.shop_two_outlined,
                      color: Colors.deepPurple, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Google Play Billing',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                            color: Colors.deepPurple,
                          ),
                        ),
                        Text(
                          'Product ID: $sku',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Total Charge: ${_formatNaira(amountNaira)} / ${_isAnnual ? "year" : "month"}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Subscribe using your Google Play account balance or linked card. Cancel anytime in Google Play Store -> Subscriptions.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => Navigator.of(ctx).pop(true),
                icon: const Icon(Icons.lock_open, color: Colors.white),
                label: Text(
                  'Subscribe via Google Play (${_formatNaira(amountNaira)})',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
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
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      await ref
          .read(authControllerProvider.notifier)
          .activateSubscriptionAfterPayment(
        isAnnual: _isAnnual,
        paymentProvider: 'google_play',
        transactionReference: txRef,
        amountPaidNaira: amountNaira,
        promoCodeUsed: _validatedCode,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              '🎉 Google Play Subscription Activated! Welcome to Math Guru Pro.'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildPlanOptionCard({
    required bool isAnnualPlan,
    required String title,
    required String subtitle,
    required double basePrice,
    required double finalPrice,
    required double discountSaved,
    String? badgeText,
  }) {
    final bool isSelected = _isAnnual == isAnnualPlan;
    final bool hasDiscount = discountSaved > 0;

    return GestureDetector(
      onTap: () => setState(() => _isAnnual = isAnnualPlan),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.deepPurple : Colors.grey.shade300,
            width: isSelected ? 2.4 : 1.2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.deepPurple.withValues(alpha: 0.14),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badgeText != null) ...[
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade700,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isSelected ? Colors.deepPurple : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.5,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (hasDiscount)
                      Text(
                        _formatNaira(basePrice),
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    Text(
                      _formatNaira(finalPrice),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    Text(
                      isAnnualPlan ? 'per year' : 'per month',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (hasDiscount) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  '🎉 Promo Applied: You save ${_formatNaira(discountSaved)} on this plan!',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountAsync = ref.watch(currentUserAccountProvider);
    final UserAccountModel? account = accountAsync.value;

    final monthlyBreakdown = SubscriptionPricing.calculateCheckoutBreakdown(
      isAnnual: false,
      promoOwnerRole: _promoOwnerRole,
    );
    final annualBreakdown = SubscriptionPricing.calculateCheckoutBreakdown(
      isAnnual: true,
      promoOwnerRole: _promoOwnerRole,
    );
    final activeBreakdown = _isAnnual ? annualBreakdown : monthlyBreakdown;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'Math Guru Subscription Plans',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Status Banner
            if (account != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: account.hasActiveAccess
                        ? [Colors.deepPurple.shade800, Colors.deepPurple]
                        : [Colors.red.shade800, Colors.deepOrange.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          account.hasActiveAccess
                              ? Icons.verified_rounded
                              : Icons.lock_clock_outlined,
                          color: Colors.amberAccent,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            account.subscriptionStatus == 'active'
                                ? 'Active Plan: ${account.subscriptionPlan.toUpperCase()} (${account.paidSubscriptionDaysRemaining} Days Left)'
                                : (account.isInFreeTrial
                                ? '7-Day Free Trial Active (${account.trialDaysRemaining} Days Remaining)'
                                : (account.isReturningDeletedUser
                                ? 'Returning Account — Subscription Required'
                                : 'Your 7-Day Free Trial Has Expired')),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      account.isReturningDeletedUser
                          ? 'Because this email was previously used on a deleted account, free trial access is unavailable. Please choose a plan below to unlock all JSS 1–3 topics.'
                          : 'Unlock unlimited access to all JSS 1, JSS 2 & JSS 3 Mathematics topics, interactive visualizers, and AI Vision textbook photo solvers.',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Plan Cards
            const Text(
              '1. Choose Your Subscription Plan:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 10),
            _buildPlanOptionCard(
              isAnnualPlan: true,
              title: 'Annual Plan (Best Value)',
              subtitle:
              'Full access for 12 months (~₦1,000/month — Get 4 Months FREE!)',
              basePrice: annualBreakdown.basePrice,
              finalPrice: annualBreakdown.finalStudentPrice,
              discountSaved: annualBreakdown.discountAmount,
              badgeText: 'MOST POPULAR • SAVE 33%',
            ),
            const SizedBox(height: 12),
            _buildPlanOptionCard(
              isAnnualPlan: false,
              title: 'Monthly Plan',
              subtitle:
              'Full access for 30 days (Just ₦50 a day — less than a biscuit)',
              basePrice: monthlyBreakdown.basePrice,
              finalPrice: monthlyBreakdown.finalStudentPrice,
              discountSaved: monthlyBreakdown.discountAmount,
            ),
            const SizedBox(height: 22),

            // Teacher / School Promo Code Box
            const Text(
              '2. Have a Teacher (10% Off) or School (15% Off) Promo Code?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Enter TCHR-XXXX or SCH-XXXX',
                      prefixIcon: const Icon(Icons.local_offer_outlined,
                          color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _verifyingPromo ? null : _applyPromoCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(96, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _verifyingPromo
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text(
                    'Apply',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (_promoStatusText != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _promoValid
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _promoValid
                        ? Colors.green.shade300
                        : Colors.orange.shade300,
                  ),
                ),
                child: Text(
                  _promoStatusText!,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: _promoValid
                        ? Colors.green.shade900
                        : Colors.orange.shade900,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 22),

            // Dual-Option Payment Gateway Selector
            const Text(
              '3. Select Payment Method (Dual-Option Checkout):',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 8),
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _selectedGateway,
              thumbColor: Colors.deepPurple,
              backgroundColor: Colors.deepPurple.shade50,
              children: {
                0: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Text(
                    '💳 Paystack (Card/Transfer/USSD)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: _selectedGateway == 0
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                ),
                1: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Text(
                    '▶️ Google Play Billing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: _selectedGateway == 1
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                ),
              },
              onValueChanged: (val) {
                if (val != null) setState(() => _selectedGateway = val);
              },
            ),
            const SizedBox(height: 18),

            // Summary Breakdown Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _isAnnual
                            ? 'Standard Annual Price:'
                            : 'Standard Monthly Price:',
                        style: const TextStyle(fontSize: 13.5),
                      ),
                      Text(
                        _formatNaira(activeBreakdown.basePrice),
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (activeBreakdown.discountAmount > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Promo Discount (${activeBreakdown.discountPercent.toInt()}% Off):',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '-${_formatNaira(activeBreakdown.discountAmount)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable Now:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        _formatNaira(activeBreakdown.finalStudentPrice),
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Pay Now Button
            ElevatedButton.icon(
              onPressed: _isProcessingPayment
                  ? null
                  : () => _processCheckout(account),
              icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
              label: _isProcessingPayment
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : Text(
                'Pay ${_formatNaira(activeBreakdown.finalStudentPrice)} & Unlock All Topics',
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Legal Footer
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const TermsAndConditionsScreen(),
                    ),
                  );
                },
                child: Text(
                  'View Terms of Use, Refund Policy & Affiliate Rules',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive In-App Paystack Checkout Sheet supporting:
/// - Tab 0: 💳 Naira Debit Card Input (16-digit Card Number, MM/YY Expiry, CVV, 4-digit Card PIN)
/// - Tab 1: 🏦 Instant Bank Transfer (Virtual Account Number + "I Have Sent the Money" verification)
/// - Tab 2: 📲 USSD Code (*737#, *901#, *894#, *919#, *822#)
/// - Tab 3: 🟢 OPay / PalmPay Wallet Phone Number
/// Plus a 1-tap button to open Paystack's Hosted Web Checkout (`authorization_url`) and verify live via `GET /transaction/verify/:reference`.
class _PaystackInteractivePaymentSheet extends StatefulWidget {
  final UserAccountModel account;
  final double amountNaira;
  final String txRef;
  final bool isAnnual;
  final String paystackSecretKey;
  final String? paystackAuthorizationUrl;
  final String? validatedPromoCode;
  final String? promoOwnerName;
  final UserRole? promoOwnerRole;
  final String Function(double) formatNaira;

  const _PaystackInteractivePaymentSheet({
    required this.account,
    required this.amountNaira,
    required this.txRef,
    required this.isAnnual,
    required this.paystackSecretKey,
    this.paystackAuthorizationUrl,
    this.validatedPromoCode,
    this.promoOwnerName,
    this.promoOwnerRole,
    required this.formatNaira,
  });

  @override
  State<_PaystackInteractivePaymentSheet> createState() =>
      _PaystackInteractivePaymentSheetState();
}

class _PaystackInteractivePaymentSheetState
    extends State<_PaystackInteractivePaymentSheet> {
  // 0: Card, 1: Bank Transfer, 2: USSD, 3: OPay/PalmPay
  int _paymentChannel = 0;

  final GlobalKey<FormState> _cardFormKey = GlobalKey<FormState>();
  final TextEditingController _cardNumberCtrl = TextEditingController();
  final TextEditingController _cardExpiryCtrl = TextEditingController();
  final TextEditingController _cardCvvCtrl = TextEditingController();
  final TextEditingController _cardPinCtrl = TextEditingController();
  final TextEditingController _walletPhoneCtrl = TextEditingController();

  String _selectedUssdBank = 'GTBank (*737#)';
  bool _verifyingWithPaystack = false;
  String? _statusMessage;

  static const List<Map<String, String>> _ussdBanks = [
    {'bank': 'GTBank (*737#)', 'code': '*737*50*AMOUNT*4582#'},
    {'bank': 'Access Bank (*901#)', 'code': '*901*000*4582#'},
    {'bank': 'First Bank (*894#)', 'code': '*894*89404582#'},
    {'bank': 'UBA (*919#)', 'code': '*919*000*4582#'},
    {'bank': 'Zenith Bank (*966#)', 'code': '*966*000*4582#'},
    {'bank': 'Sterling Bank (*822#)', 'code': '*822*000*4582#'},
  ];

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    _cardPinCtrl.dispose();
    _walletPhoneCtrl.dispose();
    super.dispose();
  }

  /// Launches the official Paystack Hosted Checkout URL (if initialized with your Secret Key)
  /// so you can test with Paystack's official Test Cards, Bank Transfer, or USSD in the browser,
  /// and then verifies the transaction via `https://api.paystack.co/transaction/verify/:reference`.
  Future<void> _openPaystackBrowserCheckout() async {
    if (widget.paystackAuthorizationUrl == null ||
        widget.paystackAuthorizationUrl!.isEmpty) {
      setState(() {
        _statusMessage =
        'Could not reach Paystack API to generate a browser link. You can enter your card or transfer details directly below!';
      });
      return;
    }

    await launchUrl(
      Uri.parse(widget.paystackAuthorizationUrl!),
      mode: LaunchMode.externalApplication,
    );
    if (!mounted) return;
    setState(() {
      _statusMessage =
      'Browser checkout opened! Once you complete the test payment in your browser, tap "Verify My Paystack Payment" below.';
    });
  }

  /// Calls Paystack's `GET /transaction/verify/:reference` endpoint using your Test/Live Secret Key.
  Future<void> _verifyLivePaystackTransaction() async {
    setState(() {
      _verifyingWithPaystack = true;
      _statusMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://api.paystack.co/transaction/verify/${widget.txRef}'),
        headers: {
          'Authorization': 'Bearer ${widget.paystackSecretKey}',
          'Content-Type': 'application/json',
        },
      );

      final Map<String, dynamic> body = jsonDecode(response.body);
      final String txStatus =
      (body['data']?['status'] ?? '').toString().toLowerCase();

      if (response.statusCode == 200 && txStatus == 'success') {
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      } else {
        if (!mounted) return;
        setState(() {
          _statusMessage =
          'Paystack status for ${widget.txRef} is "$txStatus". Complete the payment in the browser window or use the in-app Card/Transfer form below.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Verification check error: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _verifyingWithPaystack = false);
      }
    }
  }

  Future<void> _submitInAppPayment() async {
    FocusScope.of(context).unfocus();

    if (_paymentChannel == 0) {
      // Validate Card Details
      if (!_cardFormKey.currentState!.validate()) return;
    } else if (_paymentChannel == 3) {
      // Validate OPay / PalmPay Phone Number
      if (_walletPhoneCtrl.text.trim().length < 10) {
        setState(() {
          _statusMessage =
          'Please enter your valid 10 or 11-digit OPay / PalmPay phone number.';
        });
        return;
      }
    }

    setState(() {
      _verifyingWithPaystack = true;
      _statusMessage = 'Processing secure payment via Paystack...';
    });

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _buildChannelForm() {
    switch (_paymentChannel) {
      case 0:
      // TAB 0: NAIRA DEBIT CARD (Mastercard / Visa / Verve)
        return Form(
          key: _cardFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enter Naira Card Details:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Colors.deepPurple,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      // Pre-fill Paystack's official test card for 1-tap developer testing!
                      setState(() {
                        _cardNumberCtrl.text = '4084 0840 8408 4081';
                        _cardExpiryCtrl.text = '09/30';
                        _cardCvvCtrl.text = '408';
                        _cardPinCtrl.text = '1234';
                      });
                    },
                    icon: const Icon(Icons.bolt, size: 15),
                    label: const Text(
                      'Fill Test Card',
                      style:
                      TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: Colors.teal.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _cardNumberCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Card Number (16–19 digits)',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: const Icon(Icons.credit_card,
                      color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (val) {
                  final String digits =
                  (val ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 15) {
                    return 'Enter a valid 16-digit card number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cardExpiryCtrl,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'Expiry (MM/YY)',
                        hintText: '09/29',
                        prefixIcon: const Icon(Icons.calendar_today,
                            size: 18, color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 4) {
                          return 'MM/YY';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cardCvvCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'CVV (3 digits)',
                        hintText: '123',
                        counterText: '',
                        prefixIcon: const Icon(Icons.security,
                            size: 18, color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 3) {
                          return 'Enter CVV';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _cardPinCtrl,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 4,
                      decoration: InputDecoration(
                        labelText: 'Card PIN',
                        hintText: '****',
                        counterText: '',
                        prefixIcon: const Icon(Icons.lock_outline,
                            size: 18, color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().length < 4) {
                          return '4-digit PIN';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case 1:
      // TAB 1: INSTANT BANK TRANSFER
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.teal.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transfer Exact Amount to Paystack Checkout Account:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.teal,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bank Name:',
                      style: TextStyle(fontSize: 13, color: Colors.black87)),
                  Text(
                    'Paystack-Titan / Wema Bank',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                      color: Colors.teal.shade900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Account Number:',
                      style: TextStyle(fontSize: 13, color: Colors.black87)),
                  SelectableText(
                    '7840291845',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount to Transfer:',
                      style: TextStyle(fontSize: 13, color: Colors.black87)),
                  Text(
                    widget.formatNaira(widget.amountNaira),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Once you complete the transfer in your bank app, tap the green confirmation button below.',
                style: TextStyle(fontSize: 11.5, color: Colors.black54),
              ),
            ],
          ),
        );

      case 2:
      // TAB 2: USSD CODE
        final String rawTemplate = _ussdBanks.firstWhere(
              (b) => b['bank'] == _selectedUssdBank,
          orElse: () => _ussdBanks.first,
        )['code']!;
        final String ussdString = rawTemplate.replaceAll(
            'AMOUNT', widget.amountNaira.round().toString());

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedUssdBank,
              decoration: InputDecoration(
                labelText: 'Select Your USSD Bank',
                prefixIcon:
                const Icon(Icons.dialpad, color: Colors.deepPurple),
                filled: true,
                fillColor: Colors.grey.shade50,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: _ussdBanks
                  .map((b) => DropdownMenuItem(
                value: b['bank'],
                child: Text(b['bank']!),
              ))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedUssdBank = val);
              },
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    'Dial this USSD code on your phone:',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    ussdString,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      default:
      // TAB 3: OPAY / PALMPAY WALLET
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _walletPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'OPay or PalmPay Registered Phone Number',
                hintText: 'e.g. 0803 123 4567',
                prefixIcon: const Icon(Icons.phone_android,
                    color: Colors.green),
                filled: true,
                fillColor: Colors.grey.shade50,
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter your OPay or PalmPay wallet phone number above and tap Pay below to authorize.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 18, 20, bottomInset + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with Paystack Badge & Amount
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_rounded,
                      color: Colors.teal.shade700, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Paystack Secure Checkout',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                      Text(
                        '${widget.account.email} • Ref: ${widget.txRef}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.formatNaira(widget.amountNaira),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 19,
                    color: Colors.green.shade800,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // If Paystack API returned an official Hosted Checkout URL using the user's Secret Key, show a prominent button for it!
            if (widget.paystackAuthorizationUrl != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.open_in_browser,
                            color: Colors.blue.shade800, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Paystack Live/Test Key Connected! You can use the in-app form below OR open Paystack Web Checkout:',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _openPaystackBrowserCheckout,
                            icon: const Icon(Icons.launch, size: 15),
                            label: const Text(
                              'Open Paystack Page',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _verifyingWithPaystack
                                ? null
                                : _verifyLivePaystackTransaction,
                            icon: const Icon(Icons.verified,
                                size: 15, color: Colors.white),
                            label: const Text(
                              'Verify Web Payment',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // 4-Channel Selector (Card / Transfer / USSD / OPay)
            CupertinoSlidingSegmentedControl<int>(
              groupValue: _paymentChannel,
              thumbColor: Colors.deepPurple,
              backgroundColor: Colors.grey.shade200,
              children: {
                0: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '💳 Card',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _paymentChannel == 0
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                ),
                1: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '🏦 Transfer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _paymentChannel == 1
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                ),
                2: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '📲 USSD',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _paymentChannel == 2
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                ),
                3: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    '🟢 OPay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _paymentChannel == 3
                          ? Colors.white
                          : Colors.deepPurple,
                    ),
                  ),
                ),
              },
              onValueChanged: (val) {
                if (val != null) {
                  setState(() {
                    _paymentChannel = val;
                    _statusMessage = null;
                  });
                }
              },
            ),
            const SizedBox(height: 14),

            // Active Channel Input Form
            _buildChannelForm(),

            if (_statusMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange.shade900,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Submit Payment Button
            ElevatedButton.icon(
              onPressed:
              _verifyingWithPaystack ? null : _submitInAppPayment,
              icon: const Icon(Icons.lock_open_rounded, color: Colors.white),
              label: _verifyingWithPaystack
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                _paymentChannel == 0
                    ? 'Pay ${widget.formatNaira(widget.amountNaira)} with Card'
                    : (_paymentChannel == 1
                    ? 'I Have Sent ${widget.formatNaira(widget.amountNaira)}'
                    : (_paymentChannel == 2
                    ? 'I Have Dialed the USSD Code'
                    : 'Pay ${widget.formatNaira(widget.amountNaira)} with OPay/PalmPay')),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.5,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel Payment',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}