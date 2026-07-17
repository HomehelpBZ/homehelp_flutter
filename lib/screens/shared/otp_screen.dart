import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../widgets/shared_widgets.dart';
import '../../l10n/language_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final String password;
  final String fullName;
  final bool isHousekeeper;
  final Widget Function() onSuccess;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.verificationId,
    required this.password,
    required this.fullName,
    required this.isHousekeeper,
    required this.onSuccess,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  
  // Single text field approach — more reliable on web
  final _otpController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isResending = false;
  String? _errorMessage;
  int _resendSeconds = 60;
  Timer? _timer;
  late String _currentVerificationId;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _startTimer();
    // Auto focus
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _resendSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        if (mounted) setState(() => _resendSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canVerify => _otpController.text.length == 6;

  void _verify() async {
    if (!_canVerify) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Step 1: Verify OTP and create Firebase Auth account
      final result = await _authService.verifyOtpAndSignUp(
        verificationId: _currentVerificationId,
        smsCode: _otpController.text,
        phone: widget.phoneNumber,
        password: widget.password,
      );

      final uid = result.user?.uid;

      if (uid != null) {
        // Step 2: Save user document to Firestore
        await _userService.createUserDocument(
          uid: uid,
          phone: widget.phoneNumber,
          fullName: widget.fullName,
          role: widget.isHousekeeper ? 'housekeeper' : 'family',
        );

        // Step 3: Create role-specific profile
        if (widget.isHousekeeper) {
          await _userService.createHousekeeperProfile(
            uid: uid,
            phone: widget.phoneNumber,
            fullName: widget.fullName,
          );
        } else {
          await _userService.createFamilyProfile(
            uid: uid,
            fullName: widget.fullName,
            phone: widget.phoneNumber,
          );
        }
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => widget.onSuccess()),
          (r) => false,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Incorrect code. Please check and try again.';
        _otpController.clear();
      });
      _focusNode.requestFocus();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _resend() async {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _otpController.clear();
    });
    _focusNode.requestFocus();

    await _authService.sendPhoneOtp(
      phoneNumber: '+251${widget.phoneNumber.substring(1)}',
      onCodeSent: (verificationId) {
        setState(() {
          _currentVerificationId = verificationId;
          _isResending = false;
        });
        _startTimer();
      },
      onError: (error) {
        setState(() {
          _errorMessage = error;
          _isResending = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = LanguageProvider.strings(context);
    final maskedPhone =
        '${widget.phoneNumber.substring(0, 4)}****${widget.phoneNumber.substring(8)}';

    return Scaffold(
      body: Column(
        children: [
          // Navy header
          Container(
            color: AppTheme.primary,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            child: SafeArea(
              bottom: false,
              child: Column(
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
                  const SizedBox(height: 16),
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.message_outlined,
                        size: 28, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text(s.enterCode,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    'We sent a 6-digit code to $maskedPhone',
                    style: const TextStyle(
                        color: Color(0xAAFFFFFF), fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          // Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Error message
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
                                    fontSize: 12,
                                    color: AppTheme.red))),
                      ]),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // OTP input — single field, large text
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _canVerify
                            ? AppTheme.primary
                            : AppTheme.grey200,
                        width: _canVerify ? 2 : 0.5,
                      ),
                    ),
                    child: TextFormField(
                      controller: _otpController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 14,
                          color: AppTheme.grey800),
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '------',
                        hintStyle: TextStyle(
                            fontSize: 28,
                            letterSpacing: 14,
                            color: AppTheme.grey200,
                            fontWeight: FontWeight.w600),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 18, horizontal: 16),
                      ),
                      onChanged: (v) {
                        setState(() {});
                        if (v.length == 6) _verify();
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Type all 6 digits — verification is automatic',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.grey400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Resend
                  _isResending
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2))
                      : _resendSeconds > 0
                          ? Text(
                              '${s.resendIn} ${_resendSeconds}s',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.grey600),
                            )
                          : TextButton(
                              onPressed: _resend,
                              style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.primary,
                                  padding: EdgeInsets.zero),
                              child: Text(s.resendCode,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          FontWeight.w500)),
                            ),
                  const SizedBox(height: 28),

                  // Verify button
                  PrimaryButton(
                    label: s.verify,
                    onPressed: _canVerify && !_isLoading
                        ? _verify
                        : null,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: 20),

                  // Privacy note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.shield_outlined,
                            size: 14, color: AppTheme.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your phone is verified once at signup only. No SMS will be sent when you sign in.',
                            style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.primaryText,
                                height: 1.5),
                          ),
                        ),
                      ],
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