import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import 'hk_signin_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0;
  final _phoneController = TextEditingController();
  final List<TextEditingController> _otpControllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(4, (_) => FocusNode());
  final _pw1Controller = TextEditingController();
  final _pw2Controller = TextEditingController();
  bool _showPw1 = false;
  bool _showPw2 = false;
  int _resendSeconds = 30;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) t.cancel();
      else setState(() => _resendSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
    _pw1Controller.dispose();
    _pw2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Column(
        children: [
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 0),
            child: SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70, size: 18),
                    label: Text(s.backBtn, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    onPressed: () {
                      if (_step > 0) setState(() => _step--);
                      else Navigator.pop(context);
                    },
                  ),
                  const LangToggleButton(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: List.generate(3, (i) => Container(
                      width: 8, height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: i <= _step ? AppTheme.primary : AppTheme.grey200,
                        shape: BoxShape.circle,
                      ),
                    ))),
                    const SizedBox(height: 20),
                    if (_step == 0) _buildPhoneStep(s),
                    if (_step == 1) _buildOtpStep(s),
                    if (_step == 2) _buildResetStep(s),
                    if (_step == 3) _buildDoneStep(s),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneStep(s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.phone_outlined, size: 24, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text(s.forgotTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
        const SizedBox(height: 6),
        Text(s.forgotSubtitle, style: const TextStyle(fontSize: 13, color: AppTheme.grey600, height: 1.5)),
        const SizedBox(height: 22),
        SectionLabel(s.phoneNumber),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: 10,
          decoration: InputDecoration(hintText: s.phoneHint, counterText: ''),
        ),
        const SizedBox(height: 20),
        PrimaryButton(
          label: s.sendVerificationCode,
          onPressed: () {
            if (_phoneController.text.length < 10) return;
            setState(() => _step = 1);
            _startTimer();
          },
        ),
        const SizedBox(height: 10),
        SecondaryButton(label: s.backToSignIn, onPressed: () => Navigator.pop(context)),
      ],
    );
  }

  Widget _buildOtpStep(s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.message_outlined, size: 24, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text(s.enterCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
        const SizedBox(height: 6),
        Text('${s.resendIn}: ${_phoneController.text}',
            style: const TextStyle(fontSize: 13, color: AppTheme.grey600)),
        const SizedBox(height: 24),
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              margin: EdgeInsets.only(right: i < 3 ? 10 : 0),
              child: TextFormField(
                controller: _otpControllers[i],
                focusNode: _otpFocusNodes[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                decoration: const InputDecoration(counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 14)),
                onChanged: (v) {
                  setState(() {});
                  if (v.isNotEmpty && i < 3) _otpFocusNodes[i + 1].requestFocus();
                },
              ),
            ),
          )),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_resendSeconds > 0 ? '${s.resendIn} ${_resendSeconds}s' : '',
                style: const TextStyle(fontSize: 12, color: AppTheme.grey600)),
            if (_resendSeconds == 0)
              TextButton(
                onPressed: _startTimer,
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary, padding: EdgeInsets.zero),
                child: Text(s.resendCode, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          label: s.verify,
          onPressed: () {
            final code = _otpControllers.map((c) => c.text).join();
            if (code.length < 4) return;
            setState(() => _step = 2);
          },
        ),
        const SizedBox(height: 10),
        SecondaryButton(label: s.changePhone, onPressed: () => setState(() => _step = 0)),
      ],
    );
  }

  Widget _buildResetStep(s) {
    final match = _pw1Controller.text.isNotEmpty && _pw1Controller.text == _pw2Controller.text;
    final mismatch = _pw2Controller.text.isNotEmpty && _pw1Controller.text != _pw2Controller.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
          child: const Icon(Icons.lock_outline, size: 24, color: AppTheme.primary)),
        const SizedBox(height: 16),
        Text(s.setNewPassword, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
        const SizedBox(height: 22),
        SectionLabel(s.newPassword),
        TextFormField(
          controller: _pw1Controller,
          obscureText: !_showPw1,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: s.newPassword,
            suffixIcon: IconButton(
              icon: Icon(_showPw1 ? Icons.visibility_off : Icons.visibility, size: 18, color: AppTheme.grey400),
              onPressed: () => setState(() => _showPw1 = !_showPw1),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SectionLabel(s.confirmPassword),
        TextFormField(
          controller: _pw2Controller,
          obscureText: !_showPw2,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: s.confirmPassword,
            suffixIcon: IconButton(
              icon: Icon(_showPw2 ? Icons.visibility_off : Icons.visibility, size: 18, color: AppTheme.grey400),
              onPressed: () => setState(() => _showPw2 = !_showPw2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (match) Row(children: [
          const Icon(Icons.check_circle, size: 13, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(s.passwordsMatch, style: const TextStyle(fontSize: 11, color: AppTheme.primary)),
        ]),
        if (mismatch) Row(children: [
          const Icon(Icons.cancel, size: 13, color: AppTheme.red),
          const SizedBox(width: 5),
          Text(s.passwordsMismatch, style: const TextStyle(fontSize: 11, color: AppTheme.red)),
        ]),
        const SizedBox(height: 20),
        PrimaryButton(
          label: s.saveNewPassword,
          onPressed: match && _pw1Controller.text.length >= 8 ? () => setState(() => _step = 3) : null,
        ),
      ],
    );
  }

  Widget _buildDoneStep(s) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(width: 68, height: 68,
            decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
            child: const Icon(Icons.lock_open_outlined, size: 34, color: AppTheme.primary)),
          const SizedBox(height: 18),
          Text(s.passwordUpdated,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppTheme.grey800)),
          const SizedBox(height: 28),
          PrimaryButton(
            label: s.goToSignIn,
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HkSigninScreen()),
              (r) => false,
            ),
          ),
        ],
      ),
    );
  }
}
