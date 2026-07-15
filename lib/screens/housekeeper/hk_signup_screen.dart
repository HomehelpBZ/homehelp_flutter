import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/auth_service.dart';
import '../shared/otp_screen.dart';
import 'hk_signin_screen.dart';
import 'registration/step1_personal.dart';
import '../welcome_screen.dart';

class HkSignupScreen extends StatefulWidget {
  const HkSignupScreen({super.key});

  @override
  State<HkSignupScreen> createState() => _HkSignupScreenState();
}

class _HkSignupScreenState extends State<HkSignupScreen> {
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

  void _continue() async {
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
                  phone: _phoneController.text,
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

    final steps = [
      (Icons.person_outline, s.stepPersonal),
      (Icons.school_outlined, s.stepBackground),
      (Icons.build_outlined, s.stepSkills),
      (Icons.work_outline, s.stepJobPrefs),
      (Icons.badge_outlined, s.stepIdVerify),
      (Icons.people_outline, s.stepGuarantor),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        color: AppTheme.primary,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: const LangToggleButton()),
                const SizedBox(height: 8),
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.person_add_outlined,
                      size: 26, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(s.hkSignupTitle,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(s.hkSignupSubtitle,
                    style: const TextStyle(
                        color: Color(0xAAFFFFFF), fontSize: 12),
                    textAlign: TextAlign.center),
                const SizedBox(height: 22),

                // Steps list
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: steps
                        .map((step) => Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10),
                              child: Row(children: [
                                Container(
                                  width: 26, height: 26,
                                  decoration: BoxDecoration(
                                      color: Colors.white
                                          .withOpacity(0.18),
                                      shape: BoxShape.circle),
                                  child: Icon(step.$1,
                                      size: 13, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Text(step.$2,
                                    style: const TextStyle(
                                        color: Color(0xCCFFFFFF),
                                        fontSize: 12)),
                              ]),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 22),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_errorMessage!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white))),
                    ]),
                  ),
                  const SizedBox(height: 14),
                ],

                // Full name
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.fullName,
                      style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[a-zA-Z\s\u1200-\u137F]'))
                  ],
                  style: const TextStyle(color: AppTheme.grey800),
                  decoration: InputDecoration(
                    hintText: s.fullNameHint,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                ),
                const SizedBox(height: 14),

                // Phone number
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.phoneNumber,
                      style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 9,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppTheme.grey800),
                  decoration: InputDecoration(
                    hintText: '912 345 678',
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('This is your login ID — remember it.',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 11)),
                ),
                const SizedBox(height: 14),

                // Password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.password,
                      style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPw,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppTheme.grey800),
                  decoration: InputDecoration(
                    hintText: s.password,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
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
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(children: [
                    Icon(
                      _passwordController.text.isEmpty
                          ? Icons.info_outline
                          : _passwordController.text.length >= 8
                              ? Icons.check_circle
                              : Icons.cancel,
                      size: 13,
                      color: _passwordController.text.isEmpty
                          ? Colors.white54
                          : _passwordController.text.length >= 8
                              ? Colors.greenAccent
                              : Colors.redAccent,
                    ),
                    const SizedBox(width: 4),
                    Text('Minimum 8 characters',
                        style: TextStyle(
                          fontSize: 11,
                          color: _passwordController.text.isEmpty
                              ? Colors.white54
                              : _passwordController.text.length >= 8
                                  ? Colors.greenAccent
                                  : Colors.redAccent,
                        )),
                  ]),
                ),
                const SizedBox(height: 14),

                // Confirm password
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s.confirmPassword,
                      style: const TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4)),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmController,
                  obscureText: !_showConfirm,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(color: AppTheme.grey800),
                  decoration: InputDecoration(
                    hintText: s.confirmPassword,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
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
                if (_confirmController.text.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(children: [
                      Icon(
                        _passwordController.text ==
                                _confirmController.text
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 13,
                        color: _passwordController.text ==
                                _confirmController.text
                            ? Colors.greenAccent
                            : Colors.redAccent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _passwordController.text ==
                                _confirmController.text
                            ? s.passwordsMatch
                            : s.passwordsMismatch,
                        style: TextStyle(
                          fontSize: 11,
                          color: _passwordController.text ==
                                  _confirmController.text
                              ? Colors.greenAccent
                              : Colors.redAccent,
                        ),
                      ),
                    ]),
                  ),
                const SizedBox(height: 20),

                // Create profile button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isValid && !_isLoading
                        ? _continue
                        : null,
                    child: _isLoading
                        ? const SizedBox(
                            height: 18, width: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    AppTheme.primary)))
                        : Text(s.hkSignupCreateBtn,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 14),

                Row(children: [
                  Expanded(
                      child: Divider(
                          color: Colors.white.withOpacity(0.2),
                          thickness: 0.5)),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(s.hkSignupAlreadyHave,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 11)),
                  ),
                  Expanded(
                      child: Divider(
                          color: Colors.white.withOpacity(0.2),
                          thickness: 0.5)),
                ]),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.white.withOpacity(0.35),
                          width: 1.5),
                      padding:
                          const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HkSigninScreen())),
                    child: Text(s.hkSignupSignIn),
                  ),
                ),
                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(s.backHome,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}