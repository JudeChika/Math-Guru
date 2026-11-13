import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/auth_controller.dart';
import '../../models/user_account_model.dart';
import 'terms_and_conditions_screen.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  List<SavedDeviceCredential> _savedDeviceAccounts = [];
  bool _loadingSavedCredentials = true;

  @override
  void initState() {
    super.initState();
    _restoreRememberedDeviceCredentials();
  }

  /// Automatically loads the user's remembered email & password on this device
  /// (even after logging out, or if they typed their email in Sign-Up and switched to Sign-In).
  Future<void> _restoreRememberedDeviceCredentials() async {
    final authCtrl = ref.read(authControllerProvider.notifier);
    final List<SavedDeviceCredential> accounts =
    await authCtrl.getSavedDeviceAccounts();
    final SavedDeviceCredential? lastCred =
    await authCtrl.getLastRememberedCredential();

    if (!mounted) return;
    setState(() {
      _savedDeviceAccounts = accounts;
      if (lastCred != null) {
        _emailController.text = lastCred.email;
        if (lastCred.password.isNotEmpty) {
          _passwordController.text = lastCred.password;
        }
      }
      _loadingSavedCredentials = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _selectSavedAccount(SavedDeviceCredential account) {
    setState(() {
      _emailController.text = account.email;
      _passwordController.text = account.password;
      _rememberMe = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Credentials loaded for ${account.email}. Tap Sign In to continue!'),
        backgroundColor: Colors.deepPurple,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removeSavedAccount(String email) async {
    await ref
        .read(authControllerProvider.notifier)
        .removeSavedDeviceAccount(email);
    final updated = await ref
        .read(authControllerProvider.notifier)
        .getSavedDeviceAccounts();
    if (!mounted) return;
    setState(() {
      _savedDeviceAccounts = updated;
      if (_emailController.text.trim().toLowerCase() ==
          email.trim().toLowerCase()) {
        _passwordController.clear();
      }
    });
  }

  Future<void> _submitSignIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // Keep cross-screen draft updated
    ref.read(authDraftMemoryProvider.notifier).setDraft(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    await ref.read(authControllerProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );
  }

  Future<void> _showForgotPasswordSheet() async {
    final TextEditingController resetEmailCtrl =
    TextEditingController(text: _emailController.text.trim());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Reset Your Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your registered email address and we will send you a password reset link.',
                style: TextStyle(fontSize: 13.5, color: Colors.black87),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: resetEmailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon:
                  const Icon(Icons.email_outlined, color: Colors.deepPurple),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final String email = resetEmailCtrl.text.trim();
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter a valid email address.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  Navigator.of(ctx).pop();
                  try {
                    await FirebaseAuth.instance
                        .sendPasswordResetEmail(email: email);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Password reset link sent to $email. Please check your inbox.'),
                          backgroundColor: Colors.green.shade700,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not send reset email: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedAccountsBar() {
    if (_savedDeviceAccounts.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepPurple.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key_rounded,
                  size: 18, color: Colors.deepPurple),
              const SizedBox(width: 6),
              Text(
                'Saved Accounts on This Device (1-Tap Fill):',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _savedDeviceAccounts.map((acc) {
                final bool isSelected =
                    _emailController.text.trim().toLowerCase() ==
                        acc.email.toLowerCase();
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InputChip(
                    avatar: CircleAvatar(
                      backgroundColor: isSelected
                          ? Colors.white
                          : Colors.deepPurple.shade100,
                      child: Icon(
                        acc.role == 'teacher'
                            ? Icons.school
                            : (acc.role == 'school'
                            ? Icons.account_balance
                            : Icons.person),
                        size: 14,
                        color: Colors.deepPurple,
                      ),
                    ),
                    label: Text(
                      acc.displayName.isNotEmpty
                          ? '${acc.displayName} (${acc.email})'
                          : acc.email,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                        isSelected ? Colors.white : Colors.deepPurple.shade900,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Colors.deepPurple,
                    backgroundColor: Colors.white,
                    checkmarkColor: Colors.white,
                    onPressed: () => _selectSavedAccount(acc),
                    onDeleted: () => _removeSavedAccount(acc.email),
                    deleteIconColor:
                    isSelected ? Colors.white70 : Colors.grey.shade600,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(
      authControllerProvider,
          (_, state) {
        state.whenOrNull(
          error: (error, _) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.toString()),
                backgroundColor: Colors.red.shade700,
              ),
            );
          },
          data: (_) {
            if (FirebaseAuth.instance.currentUser != null) {
              context.go('/home');
            }
          },
        );
      },
    );

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: AutofillGroup(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Image.asset(
                      "assets/images/math_guru_logo.png",
                      width: 100,
                    ),
                  ),
                  const Text(
                    'Welcome Back to Math Guru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to access your JSS 1–3 step-by-step solvers & affiliate dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Saved Device Accounts Bar (1-Tap Login after Logout!)
                  if (!_loadingSavedCredentials) _buildSavedAccountsBar(),

                  // Email Field with Autocomplete & Autofill
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [
                      AutofillHints.email,
                      AutofillHints.username,
                    ],
                    onChanged: (val) {
                      ref.read(authDraftMemoryProvider.notifier).setDraft(
                        email: val,
                        password: _passwordController.text,
                      );
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter your email address',
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.deepPurple),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.deepPurple.shade200),
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
                  const SizedBox(height: 16),

                  // Password Field with Show/Hide Toggle & Device Memory
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    autofillHints: const [AutofillHints.password],
                    onFieldSubmitted: (_) => _submitSignIn(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: Colors.deepPurple),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                        BorderSide(color: Colors.deepPurple.shade200),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  // Remember Me Checkbox & Forgot Password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () =>
                              setState(() => _rememberMe = !_rememberMe),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                activeColor: Colors.deepPurple,
                                visualDensity: VisualDensity.compact,
                                onChanged: (val) {
                                  setState(() => _rememberMe = val ?? true);
                                },
                              ),
                              const Expanded(
                                child: Text(
                                  'Remember email & password on this device',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _showForgotPasswordSheet,
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Primary Sign In Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _submitSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
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
                        : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR CONTINUE WITH',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Social Login Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () => ref
                              .read(authControllerProvider.notifier)
                              .signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata,
                              size: 28, color: Colors.red),
                          label: const Text(
                            'Google',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: authState.isLoading
                              ? null
                              : () => ref
                              .read(authControllerProvider.notifier)
                              .signInWithFacebook(),
                          icon: const Icon(Icons.facebook,
                              size: 22, color: Colors.blue),
                          label: const Text(
                            'Facebook',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Navigate to Sign Up (passes typed email along automatically)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(fontSize: 14),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(authDraftMemoryProvider.notifier).setDraft(
                            email: _emailController.text.trim(),
                            password: _passwordController.text,
                          );
                          context.go('/sign-up');
                        },
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Terms & Conditions Link
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsAndConditionsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.policy_outlined,
                          size: 16, color: Colors.grey),
                      label: Text(
                        'Terms & Conditions • Affiliate Policy',
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
          ),
        ),
      ),
    );
  }
}