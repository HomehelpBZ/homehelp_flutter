import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/auth_service.dart';
import '../welcome_screen.dart';
import '../shared/otp_screen.dart';
import 'hk_dashboard_screen.dart';
import 'forgot_password_screen.dart';
import 'registration/step1_personal.dart';

// ── Landing screen ────────────────────────────────────────────────────────────
class HkAuthScreen extends StatelessWidget {
  const HkAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppTheme.primary,
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.white70, size: 16),
                      label: Text(s.home,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WelcomeScreen()),
                        (r) => false,
                      ),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    ),
                    const LangToggleButton(),
                  ],
                ),
              ),

              const Spacer(),

              // Icon and title
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.person_outline,
                    size: 32, color: Colors.white),
              ),
              const SizedBox(height: 14),
              Text(s.hkSignupTitle,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              Text(s.hkSignupSubtitle,
                  style: const TextStyle(
                      color: Color(0xAAFFFFFF), fontSize: 13),
                  textAlign: TextAlign.center),

              const Spacer(),

              // Action cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Create account — most prominent for HK
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _HkSignUpScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.person_add_outlined,
                                color: AppTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.createAccount,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.grey800)),
                                const SizedBox(height: 2),
                                Text('Create your housekeeper profile',
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.grey600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppTheme.grey400, size: 20),
                        ]),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Sign in
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const _HkSignInScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: Row(children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.login,
                                color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s.signInBtn,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white)),
                                const SizedBox(height: 2),
                                Text('Already have an account',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.65))),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.white.withOpacity(0.5), size: 20),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sign Up Screen ────────────────────────────────────────────────────────────
class _HkSignUpScreen extends StatefulWidget {
  const _HkSignUpScreen();

  @override
  State<_HkSignUpScreen> createState() => _HkSignUpScreenState();
}

class _HkSignUpScreenState extends State<_HkSignUpScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showPw = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _phoneController.text.length == 9 &&
      _passwordController.text.length >= 8 &&
      _passwordController.text == _confirmController.text;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _signUp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final phone = _phoneController.text;
    final formattedPhone = '+251$phone';

    await _authService.sendPhoneOtp(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => OtpScreen(
                phoneNumber: phone,
                verificationId: verificationId,
                password: _passwordController.text,
                fullName: _nameController.text.trim(),
                isHousekeeper: true,
                onSuccess: () => Step1Personal(
                  fullName: _nameController.text.trim(),
                  phone: phone,
                ),
              ),
            ),
          );
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = error;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final pwMatch = _confirmController.text.isNotEmpty &&
        _passwordController.text == _confirmController.text;
    final pwMismatch = _confirmController.text.isNotEmpty &&
        _passwordController.text != _confirmController.text;

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(children: const [
                          Icon(Icons.arrow_back,
                              color: Colors.white70, size: 18),
                          SizedBox(width: 4),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      const LangToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(s.createAccount,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text('Create your housekeeper profile',
                      style: const TextStyle(
                          color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.redLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.red.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: AppTheme.red),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.red))),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  SectionLabel(s.fullName),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z\s\u1200-\u137F]'))
                    ],
                    decoration:
                        InputDecoration(hintText: s.fullNameHint),
                  ),
                  const SizedBox(height: 14),

                  SectionLabel(s.phoneNumber),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '912 345 678',
                      counterText: '',
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: const Text('+251',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey800,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('This is your login ID — remember it.',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.grey400)),
                  const SizedBox(height: 14),

                  SectionLabel(s.password),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPw,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: s.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _showPw
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                            color: AppTheme.grey400),
                        onPressed: () =>
                            setState(() => _showPw = !_showPw),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(
                      _passwordController.text.isEmpty
                          ? Icons.info_outline
                          : _passwordController.text.length >= 8
                              ? Icons.check_circle
                              : Icons.cancel,
                      size: 13,
                      color: _passwordController.text.isEmpty
                          ? AppTheme.grey400
                          : _passwordController.text.length >= 8
                              ? AppTheme.primary
                              : AppTheme.red,
                    ),
                    const SizedBox(width: 4),
                    Text('Minimum 8 characters',
                        style: TextStyle(
                          fontSize: 11,
                          color: _passwordController.text.isEmpty
                              ? AppTheme.grey400
                              : _passwordController.text.length >= 8
                                  ? AppTheme.primary
                                  : AppTheme.red,
                        )),
                  ]),
                  const SizedBox(height: 14),

                  SectionLabel(s.confirmPassword),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: !_showConfirm,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: s.confirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _showConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                            color: AppTheme.grey400),
                        onPressed: () =>
                            setState(() => _showConfirm = !_showConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (pwMatch)
                    Row(children: [
                      const Icon(Icons.check_circle,
                          size: 13, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(s.passwordsMatch,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.primary)),
                    ]),
                  if (pwMismatch)
                    Row(children: [
                      const Icon(Icons.cancel,
                          size: 13, color: AppTheme.red),
                      const SizedBox(width: 4),
                      Text(s.passwordsMismatch,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.red)),
                    ]),
                  const SizedBox(height: 24),

                  PrimaryButton(
                    label: s.createAccount,
                    onPressed: _isValid ? _signUp : null,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(s.backBtn,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.grey600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sign In Screen ────────────────────────────────────────────────────────────
class _HkSignInScreen extends StatefulWidget {
  const _HkSignInScreen();

  @override
  State<_HkSignInScreen> createState() => _HkSignInScreenState();
}

class _HkSignInScreenState extends State<_HkSignInScreen> {
  final AuthService _authService = AuthService();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPw = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fakeEmail =
          _authService.phoneToEmail(_phoneController.text);
      await _authService.signInWithEmail(
        email: fakeEmail,
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const HkDashboardScreen()),
          (r) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Phone number or password is incorrect. Please try again.';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(children: const [
                          Icon(Icons.arrow_back,
                              color: Colors.white70, size: 18),
                          SizedBox(width: 4),
                          Text('Back',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ]),
                      ),
                      const LangToggleButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(s.signInBtn,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  Text('Welcome back to HomeHelp',
                      style: const TextStyle(
                          color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.redLight,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.red.withOpacity(0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: AppTheme.red),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(_errorMessage!,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.red))),
                      ]),
                    ),
                    const SizedBox(height: 14),
                  ],

                  SectionLabel(s.phoneNumber),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '912 345 678',
                      counterText: '',
                      prefixIcon: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: const Text('+251',
                            style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.grey800,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SectionLabel(s.password),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPw,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: s.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                            _showPw
                                ? Icons.visibility_off
                                : Icons.visibility,
                            size: 18,
                            color: AppTheme.grey400),
                        onPressed: () =>
                            setState(() => _showPw = !_showPw),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  const ForgotPasswordScreen())),
                      style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          padding: EdgeInsets.zero),
                      child: Text(s.forgotPassword,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  PrimaryButton(
                    label: s.signInBtn,
                    onPressed: _phoneController.text.length == 9 &&
                            _passwordController.text.isNotEmpty
                        ? _signIn
                        : null,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(s.backBtn,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.grey600)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}