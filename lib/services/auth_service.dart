import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Helper: convert phone to fake email ───────────────────────────────────
  String phoneToEmail(String phone) {
    final cleaned = phone.trim().replaceAll(' ', '');
    return '$cleaned@homehelp.app';
  }

  // ── Email / Password ──────────────────────────────────────────────────────
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ── Phone OTP — Step 1: Send OTP ─────────────────────────────────────────
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String errorMessage) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android — not used for signup flow
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(_friendlyPhoneError(e.code));
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // ── Phone OTP — Step 2: Verify OTP then create account ───────────────────
  Future<UserCredential> verifyOtpAndSignUp({
    required String verificationId,
    required String smsCode,
    required String phone,
    required String password,
  }) async {
    // Step 1: Verify OTP
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final phoneResult = await _auth.signInWithCredential(credential);

    // Step 2: Link with email/password so future logins use phone+password
    final fakeEmail = phoneToEmail(phone);
    final emailCredential = EmailAuthProvider.credential(
      email: fakeEmail,
      password: password,
    );

    try {
      await phoneResult.user?.linkWithCredential(emailCredential);
    } on FirebaseAuthException catch (e) {
      // If already linked, that's fine
      if (e.code != 'provider-already-linked' &&
          e.code != 'email-already-in-use') {
        rethrow;
      }
    }

    return phoneResult;
  }

  // ── Phone OTP — Verify only (for sign in with OTP if needed) ─────────────
  Future<UserCredential> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  // ── Sign out ──────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Friendly error messages ───────────────────────────────────────────────
  String _friendlyPhoneError(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Invalid phone number. Please enter a valid Ethiopian number.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 'network-request-failed':
        return 'No internet connection. Please check your network.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      default:
        return 'Failed to send verification code. Please try again.';
    }
  }
}
