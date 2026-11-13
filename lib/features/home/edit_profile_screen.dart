import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_account_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _schoolCtrl;
  late TextEditingController _accountNumberCtrl;
  late TextEditingController _accountNameCtrl;

  String _selectedClass = 'JSS 3';
  String _selectedState = 'Lagos';
  String _selectedBankName = 'Guaranty Trust Bank (GTBank)';
  String _selectedBankCode = '058';
  bool _saving = false;

  static const List<String> _classLevels = ['JSS 1', 'JSS 2', 'JSS 3'];

  static const List<String> _nigerianStates = [
    'Abia',
    'Abuja (FCT)',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  static const List<Map<String, String>> _nigerianBanks = [
    {'name': 'Access Bank', 'code': '044'},
    {'name': 'Citibank Nigeria', 'code': '023'},
    {'name': 'Ecobank Nigeria', 'code': '050'},
    {'name': 'Fidelity Bank', 'code': '070'},
    {'name': 'First Bank of Nigeria', 'code': '011'},
    {'name': 'First City Monument Bank (FCMB)', 'code': '214'},
    {'name': 'Globus Bank', 'code': '00103'},
    {'name': 'Guaranty Trust Bank (GTBank)', 'code': '058'},
    {'name': 'Keystone Bank', 'code': '082'},
    {'name': 'Kuda Bank', 'code': '50211'},
    {'name': 'Moniepoint MFB', 'code': '50515'},
    {'name': 'OPay Digital Services', 'code': '999992'},
    {'name': 'PalmPay', 'code': '999991'},
    {'name': 'Polaris Bank', 'code': '076'},
    {'name': 'Providus Bank', 'code': '101'},
    {'name': 'Stanbic IBTC Bank', 'code': '221'},
    {'name': 'Standard Chartered Bank', 'code': '068'},
    {'name': 'Sterling Bank', 'code': '232'},
    {'name': 'Union Bank of Nigeria', 'code': '032'},
    {'name': 'United Bank for Africa (UBA)', 'code': '033'},
    {'name': 'Unity Bank', 'code': '215'},
    {'name': 'Wema Bank', 'code': '035'},
    {'name': 'Zenith Bank', 'code': '057'},
  ];

  @override
  void initState() {
    super.initState();
    final UserAccountModel? acc = ref.read(currentUserAccountProvider).value;
    _nameCtrl = TextEditingController(text: acc?.name ?? '');
    _phoneCtrl = TextEditingController(text: acc?.phoneNumber ?? '');
    _schoolCtrl = TextEditingController(text: acc?.schoolName ?? '');
    _accountNumberCtrl = TextEditingController(text: acc?.accountNumber ?? '');
    _accountNameCtrl = TextEditingController(text: acc?.accountName ?? '');

    if (acc != null) {
      if (_classLevels.contains(acc.classLevel)) {
        _selectedClass = acc.classLevel;
      }
      if (_nigerianStates.contains(acc.stateOfResidence)) {
        _selectedState = acc.stateOfResidence;
      }
      if (acc.bankName.isNotEmpty) {
        final match = _nigerianBanks.where((b) => b['name'] == acc.bankName);
        if (match.isNotEmpty) {
          _selectedBankName = match.first['name']!;
          _selectedBankCode = match.first['code']!;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _schoolCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveChanges(UserAccountModel? account) async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final authCtrl = ref.read(authControllerProvider.notifier);
      await authCtrl.updateProfile(
        name: _nameCtrl.text.trim(),
        phoneNumber: _phoneCtrl.text.trim(),
        classLevel: _selectedClass,
        schoolName: _schoolCtrl.text.trim(),
        stateOfResidence: _selectedState,
      );

      if (account != null && account.role != UserRole.student) {
        await authCtrl.updateAffiliateBankDetails(
          bankName: _selectedBankName,
          bankCode: _selectedBankCode,
          accountNumber: _accountNumberCtrl.text.trim(),
          accountName: _accountNameCtrl.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile & Bank details saved successfully!'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserAccountModel? account =
        ref.watch(currentUserAccountProvider).value;
    final bool isAffiliate =
        account != null && account.role != UserRole.student;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: Text(
          isAffiliate
              ? 'Edit Profile & Payout Bank'
              : 'Edit Student Profile',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '1. Personal & Academic Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: account?.role == UserRole.school
                      ? 'Official School Name'
                      : 'Full Name',
                  prefixIcon:
                  const Icon(Icons.person_outline, color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Please enter a valid name'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon:
                  const Icon(Icons.phone_outlined, color: Colors.deepPurple),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (account?.role == UserRole.student) ...[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedClass,
                        decoration: InputDecoration(
                          labelText: 'Class Level',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _classLevels
                            .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedClass = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedState,
                      decoration: InputDecoration(
                        labelText: 'State of Residence',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _nigerianStates
                          .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s, overflow: TextOverflow.ellipsis),
                      ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedState = val);
                      },
                    ),
                  ),
                ],
              ),
              if (account?.role != UserRole.school) ...[
                const SizedBox(height: 14),
                TextFormField(
                  controller: _schoolCtrl,
                  decoration: InputDecoration(
                    labelText: account?.role == UserRole.teacher
                        ? 'School Where You Teach'
                        : 'Your School Name',
                    prefixIcon: const Icon(Icons.school_outlined,
                        color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              // Nigerian Bank Account Linking for Teachers & Schools
              if (isAffiliate) ...[
                const SizedBox(height: 26),
                const Text(
                  '2. Nigerian Bank Account for Automated Commission Payouts',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  account.role == UserRole.school
                      ? 'When your School Wallet reaches ₦50,000, your 15% commissions are transferred straight into this bank account.'
                      : 'When your Teacher Wallet reaches ₦20,000, your 10% commissions are transferred straight into this bank account.',
                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedBankName,
                  decoration: InputDecoration(
                    labelText: 'Select Nigerian Bank',
                    prefixIcon: const Icon(Icons.account_balance_outlined,
                        color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _nigerianBanks
                      .map((b) => DropdownMenuItem<String>(
                    value: b['name'],
                    child: Text(
                      b['name']!,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final bank = _nigerianBanks
                          .firstWhere((element) => element['name'] == val);
                      setState(() {
                        _selectedBankName = bank['name']!;
                        _selectedBankCode = bank['code']!;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _accountNumberCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                  decoration: InputDecoration(
                    labelText: '10-Digit NUBAN Account Number',
                    hintText: 'e.g. 0123456789',
                    prefixIcon:
                    const Icon(Icons.pin_outlined, color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (val) {
                    if (val != null &&
                        val.trim().isNotEmpty &&
                        val.trim().length != 10) {
                      return 'Please enter a valid 10-digit NUBAN account number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _accountNameCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Verified Account Name',
                    hintText: 'Exact name on your bank account',
                    prefixIcon: const Icon(Icons.badge_outlined,
                        color: Colors.deepPurple),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _saving ? null : () => _saveChanges(account),
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: _saving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Text(
                  'Save Profile & Bank Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}