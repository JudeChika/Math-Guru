import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_account_model.dart';
import 'terms_and_conditions_screen.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  UserRole _selectedRole = UserRole.student;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

  String _selectedClassLevel = 'JSS 3';
  String _selectedState = 'Lagos';
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _acceptedTerms = false;

  // Live Promo Code Validation State
  bool _validatingPromo = false;
  String? _promoValidationMessage;
  bool _promoIsValid = false;

  static const List<String> _classLevels = [
    'JSS 1',
    'JSS 2',
    'JSS 3',
  ];

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

  @override
  void initState() {
    super.initState();
    final draft = ref.read(authDraftMemoryProvider);
    if (draft != null && draft.email.isNotEmpty) {
      _emailController.text = draft.email;
      if (draft.password.isNotEmpty) {
        _passwordController.text = draft.password;
      }
      if (draft.displayName.isNotEmpty) {
        _nameController.text = draft.displayName;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolNameController.dispose();
    _passwordController.dispose();
    _promoCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyPromoCodeLive() async {
    final String raw = _promoCodeController.text.trim().toUpperCase();
    if (raw.isEmpty) {
      setState(() {
        _promoValidationMessage = null;
        _promoIsValid = false;
      });
      return;
    }

    setState(() => _validatingPromo = true);
    final Map<String, dynamic>? promoDoc = await ref
        .read(authControllerProvider.notifier)
        .validatePromoCode(raw);

    if (!mounted) return;
    setState(() {
      _validatingPromo = false;
      if (promoDoc != null) {
        final String ownerName = (promoDoc['ownerName'] ?? 'Partner').toString();
        final num pct = (promoDoc['discountPercent'] as num?) ?? 10;
        _promoIsValid = true;
        _promoValidationMessage =
        '✓ Valid code from $ownerName! You get ${pct.toInt()}% off your subscription.';
      } else {
        _promoIsValid = false;
        _promoValidationMessage =
        'Code not found. Check the spelling or leave blank.';
      }
    });
  }

  Future<void> _submitSignUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Please accept the Terms & Conditions and Privacy Policy to continue.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final bool isReturningDeletedUser =
      await ref.read(authControllerProvider.notifier).signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
        phoneNumber: _phoneController.text.trim(),
        classLevel: _selectedClassLevel,
        schoolName: _schoolNameController.text.trim(),
        stateOfResidence: _selectedState,
        referralPromoCode: _promoCodeController.text.trim(),
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      if (isReturningDeletedUser) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Returning Account Detected',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ],
            ),
            content: const Text(
              'Welcome back! Because this email address was previously associated with a deleted Math Guru account, the 7-day free trial has already been used.\n\nPlease activate a Monthly (₦1,500) or Annual (₦12,000) subscription to unlock full curriculum access.',
              style: TextStyle(fontSize: 14, height: 1.45),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.go('/paywall?expired=true');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Proceed to Subscription'),
              ),
            ],
          ),
        );
      } else {
        context.go('/verify-email');
      }
    } catch (_) {
      // Error is handled by ref.listen SnackBar
    }
  }

  Widget _buildRoleBannerCard() {
    if (_selectedRole == UserRole.student) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_outlined, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🎒 Student Account: Includes a 7-Day Free Trial (for first-time users). After trial, subscribe for ₦1,500/month or ₦12,000/year (save 10%–15% with a Teacher or School code!).',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else if (_selectedRole == UserRole.teacher) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.deepPurple.shade300),
        ),
        child: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.deepPurple),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '👨‍🏫 Teacher Affiliate Account: You will receive a unique "TCHR-XXXX" promo code! Every student who uses your code gets 10% OFF, and you earn 10% commission (₦150/month or ₦1,200/year per student). Withdraw to your bank once you reach ₦20,000!',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade700),
        ),
        child: const Row(
          children: [
            Icon(Icons.account_balance, color: Colors.deepOrange),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '🏫 School Partner Account: Your school receives a unique "SCH-XXXX" promo code! Students using your code get 15% OFF, and your school earns 15% commission (₦225/month or ₦1,800/year per student). Withdraw to your school bank account once you reach ₦50,000!',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (_, state) {
        state.whenOrNull(
          error: (error, _) {
            final String msg = error.toString();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red.shade700,
                action: msg.toLowerCase().contains('already registered')
                    ? SnackBarAction(
                  label: 'SIGN IN',
                  textColor: Colors.amberAccent,
                  onPressed: () => context.go('/sign-in'),
                )
                    : null,
              ),
            );
          },
        );
      },
    );

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Math Guru Account',
          style: TextStyle(
            color: Colors.deepPurple,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '1. Select Your Account Type:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CupertinoSlidingSegmentedControl<UserRole>(
                    groupValue: _selectedRole,
                    thumbColor: Colors.deepPurple,
                    backgroundColor: Colors.deepPurple.shade50,
                    children: {
                      UserRole.student: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '🎒 Student',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: _selectedRole == UserRole.student
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      UserRole.teacher: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '👨‍🏫 Teacher (10%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: _selectedRole == UserRole.teacher
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                      UserRole.school: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          '🏫 School (15%)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: _selectedRole == UserRole.school
                                ? Colors.white
                                : Colors.deepPurple,
                          ),
                        ),
                      ),
                    },
                    onValueChanged: (UserRole? val) {
                      if (val != null) setState(() => _selectedRole = val);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildRoleBannerCard(),
                  const SizedBox(height: 18),

                  // Full Name or School Name
                  TextFormField(
                    controller: _nameController,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(
                      labelText: _selectedRole == UserRole.school
                          ? 'Official School Name'
                          : (_selectedRole == UserRole.teacher
                          ? 'Teacher Full Name (e.g. Mr. Adewale)'
                          : 'Student Full Name'),
                      prefixIcon: Icon(
                        _selectedRole == UserRole.school
                            ? Icons.account_balance_outlined
                            : Icons.person_outline,
                        color: Colors.deepPurple,
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().length < 2) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Email Address
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    onChanged: (val) {
                      ref.read(authDraftMemoryProvider.notifier).setDraft(
                        email: val,
                        password: _passwordController.text,
                        displayName: _nameController.text,
                        role: _selectedRole.value,
                      );
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Phone Number & State Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          decoration: InputDecoration(
                            labelText: _selectedRole == UserRole.student
                                ? 'Phone (Optional)'
                                : 'Phone Number',
                            prefixIcon: const Icon(Icons.phone_outlined,
                                color: Colors.deepPurple),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (_selectedRole != UserRole.student &&
                                (value == null || value.trim().length < 10)) {
                              return 'Enter valid phone';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedState,
                          decoration: InputDecoration(
                            labelText: 'State',
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: _nigerianStates
                              .map((st) => DropdownMenuItem(
                            value: st,
                            child: Text(
                              st,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13.5),
                            ),
                          ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedState = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Student Class Level & School Name
                  if (_selectedRole == UserRole.student) ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _selectedClassLevel,
                            decoration: InputDecoration(
                              labelText: 'Class',
                              prefixIcon: const Icon(Icons.class_outlined,
                                  color: Colors.deepPurple),
                              filled: true,
                              fillColor: Colors.grey.shade50,
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
                              if (val != null) {
                                setState(() => _selectedClassLevel = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _schoolNameController,
                            decoration: InputDecoration(
                              labelText: 'Your School (Optional)',
                              prefixIcon: const Icon(Icons.school_outlined,
                                  color: Colors.deepPurple),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ] else if (_selectedRole == UserRole.teacher) ...[
                    TextFormField(
                      controller: _schoolNameController,
                      decoration: InputDecoration(
                        labelText: 'School Where You Teach (Optional)',
                        prefixIcon: const Icon(Icons.school_outlined,
                            color: Colors.deepPurple),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Password (min. 6 characters)',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Colors.deepPurple),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Optional Promo Code Field for Students
                  if (_selectedRole == UserRole.student) ...[
                    TextFormField(
                      controller: _promoCodeController,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: (_) => _verifyPromoCodeLive(),
                      decoration: InputDecoration(
                        labelText:
                        'Teacher / School Promo Code (Optional — 10% to 15% Off)',
                        hintText: 'e.g. TCHR-ADEWALE48 or SCH-QUEENS92',
                        prefixIcon: const Icon(Icons.local_offer_outlined,
                            color: Colors.deepPurple),
                        suffixIcon: _validatingPromo
                            ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2),
                          ),
                        )
                            : IconButton(
                          icon: const Icon(Icons.check_circle_outline,
                              color: Colors.deepPurple),
                          tooltip: 'Verify Code',
                          onPressed: _verifyPromoCodeLive,
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (_promoValidationMessage != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        _promoValidationMessage!,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: _promoIsValid
                              ? Colors.green.shade800
                              : Colors.orange.shade900,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                  ],

                  // Remember Credentials Checkbox
                  CheckboxListTile(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    activeColor: Colors.deepPurple,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    title: const Text(
                      'Remember my email & password on this device for easy login after logout',
                      style: TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),

                  // Mandatory Terms & Conditions Checkbox
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _acceptedTerms
                            ? Colors.deepPurple.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _acceptedTerms,
                          activeColor: Colors.deepPurple,
                          onChanged: (val) {
                            setState(() => _acceptedTerms = val ?? false);
                          },
                        ),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'I agree to the ',
                                style: TextStyle(fontSize: 12.5),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final bool? accepted =
                                  await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const TermsAndConditionsScreen(
                                          initialTabIndex: 0),
                                    ),
                                  );
                                  if (accepted == true && mounted) {
                                    setState(() => _acceptedTerms = true);
                                  }
                                },
                                child: const Text(
                                  'Terms & Conditions, No-Repeat-Trial Policy & Affiliate Rules',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Submit Sign Up Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submitSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : Text(
                      _selectedRole == UserRole.student
                          ? 'Create Student Account'
                          : (_selectedRole == UserRole.teacher
                          ? 'Register as Teacher & Get Promo Code'
                          : 'Register School & Get Promo Code'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Already have an account? Sign In (carries typed email automatically!)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account? '),
                      TextButton(
                        onPressed: () {
                          ref.read(authDraftMemoryProvider.notifier).setDraft(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                            displayName: _nameController.text.trim(),
                            role: _selectedRole.value,
                          );
                          context.go('/sign-in');
                        },
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}