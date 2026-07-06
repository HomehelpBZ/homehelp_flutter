import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'hk_dashboard_screen.dart';
import 'hk_signup_screen.dart';
import 'forgot_password_screen.dart';
import '../welcome_screen.dart';

class HkSigninScreen extends StatefulWidget {
  const HkSigninScreen({super.key});

  @override
  State<HkSigninScreen> createState() => _HkSigninScreenState();
}

class _HkSigninScreenState extends State<HkSigninScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn(context) async {
    if (_phoneController.text.length < 10 || _passwordController.text.isEmpty) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HkDashboardScreen()),
        (route) => false,
      );
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
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 18),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(alignment: Alignment.topRight, child: const LangToggleButton()),
                  const SizedBox(height: 4),
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.home_outlined, size: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(s.signInWelcomeBack,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 3),
                  const Text('HomeHelp · Addis Ababa',
                      style: TextStyle(color: Color(0xAAFFFFFF), fontSize: 12)),
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
                  const SizedBox(height: 8),
                  Text(s.signInTitle,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
                  const SizedBox(height: 4),
                  Text(s.signInSubtitle,
                      style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
                  const SizedBox(height: 20),
                  SectionLabel(s.phoneNumber),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLength: 10,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(hintText: s.phoneHint, counterText: ''),
                  ),
                  const SizedBox(height: 14),
                  SectionLabel(s.password),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPassword,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: s.password,
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility,
                            size: 18, color: AppTheme.grey400),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: EdgeInsets.zero),
                      child: Text(s.forgotPassword,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  PrimaryButton(
                    label: s.signInBtn,
                    onPressed: _phoneController.text.length == 10 && _passwordController.text.isNotEmpty
                        ? () => _signIn(context) : null,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(s.noAccount,
                          style: const TextStyle(fontSize: 11, color: AppTheme.grey600)),
                    ),
                    const Expanded(child: Divider()),
                  ]),
                  const SizedBox(height: 12),
                  SecondaryButton(
                    label: s.createNewProfile,
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HkSignupScreen())),
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                        (route) => false,
                      ),
                      style: TextButton.styleFrom(foregroundColor: AppTheme.grey600),
                      child: Text(s.backHome, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
