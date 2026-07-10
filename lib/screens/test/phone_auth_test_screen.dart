import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class PhoneAuthTestScreen extends StatefulWidget {
  const PhoneAuthTestScreen({super.key});

  @override
  State<PhoneAuthTestScreen> createState() => _PhoneAuthTestScreenState();
}

class _PhoneAuthTestScreenState extends State<PhoneAuthTestScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _verificationId;
  String _message = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    await _authService.sendPhoneOtp(
      phoneNumber: _phoneController.text.trim(),
      onCodeSent: (verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false;
          _message = 'OTP sent successfully.';
        });
      },
      onError: (errorMessage) {
        setState(() {
          _isLoading = false;
          _message = errorMessage;
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) {
      setState(() => _message = 'Please send OTP first.');
      return;
    }

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      await _authService.verifyPhoneOtp(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      setState(() {
        _isLoading = false;
        _message = 'Phone verified successfully.';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Auth Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+251911234567',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendOtp,
              child: const Text('Send OTP'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'OTP Code',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: const Text('Verify OTP'),
            ),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (_message.isNotEmpty)
              Text(
                _message,
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}