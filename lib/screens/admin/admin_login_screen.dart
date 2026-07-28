import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/shared_widgets.dart';
import '../../../l10n/language_provider.dart';
import '../welcome_screen.dart';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _showPw = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (_) => const AdminDashboardScreen()),
          (r) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        switch (e.code) {
          case 'user-not-found':
          case 'wrong-password':
          case 'invalid-credential':
            _errorMessage = 'Email or password is incorrect.';
            break;
          case 'user-disabled':
            _errorMessage = 'This admin account has been disabled.';
            break;
          case 'network-request-failed':
            _errorMessage = 'No internet connection.';
            break;
          default:
            _errorMessage = 'Sign in failed. Please try again.';
        }
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WelcomeScreen()),
                          (r) => false,
                        ),
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
                  const SizedBox(height: 20),
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.admin_panel_settings_outlined,
                        size: 30, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text('Admin Portal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  const Text('HomeHelp · Addis Ababa',
                      style: TextStyle(
                          color: Color(0xAAFFFFFF), fontSize: 12)),
                ],
              ),
            ),
          ),

          // Form
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Error
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
                    const SizedBox(height: 16),
                  ],

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.amberLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_outlined,
                            size: 15, color: AppTheme.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Admin access only. This portal is restricted to HomeHelp staff.',
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF633806),
                                height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  const SectionLabel('Email address'),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'admin@homehelp.app',
                      prefixIcon: Icon(Icons.email_outlined,
                          size: 18, color: AppTheme.grey400),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const SectionLabel('Password'),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_showPw,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline,
                          size: 18, color: AppTheme.grey400),
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
                  const SizedBox(height: 28),

                  PrimaryButton(
                    label: 'Sign in to Admin Portal',
                    isLoading: _isLoading,
                    onPressed:
                        _emailController.text.isNotEmpty &&
                                _passwordController.text.isNotEmpty
                            ? _signIn
                            : null,
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
