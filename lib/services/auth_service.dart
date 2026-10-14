import 'package:firebase_auth/firebase_auth.dart';
import '../l10n/app_strings.dart';

class AuthService {
  final FirebaseAuth _auth;

  // `auth` is injectable for tests; the app uses the default instance.
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  // ── Current user ──────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;

  // Tests only: pretend someone is (or isn't) signed in.
  static bool? debugSignedInOverride;

  // Whether someone is signed in (false for guests, or if Firebase isn't set
  // up, e.g. in widget tests).
  static bool get isSignedIn {
    if (debugSignedInOverride != null) return debugSignedInOverride!;
    try {
      return FirebaseAuth.instance.currentUser != null;
    } catch (_) {
      return false;
    }
  }
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Helper: normalize phone to local 0XXXXXXXXX form ──────────────────────
  // Accepts 911000001, 0911000001, +251911000001, 251 911 000 001, ...
  String normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('251') && digits.length == 12) {
      digits = digits.substring(3);
    }
    return digits.startsWith('0') ? digits : '0$digits';
  }

  // ── Helper: phone in international format for SMS ─────────────────────────
  // 911000001 → +251911000001
  String toE164(String phone) => '+251${normalizePhone(phone).substring(1)}';

  // ── Helper: convert phone to fake email ───────────────────────────────────
  // Always store with leading 0 for consistency
  // User enters 9 digits: 911000001 → 0911000001@homehelp.app
  String phoneToEmail(String phone) => '${normalizePhone(phone)}@homehelp.app';

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
    required AppStrings strings,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-verification on Android — not used for signup flow
      },
      verificationFailed: (FirebaseAuthException e) {
        onError(_friendlyPhoneError(e.code, strings));
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
      // Don't leave a half-created, password-less account signed in.
      await _discardSignIn(phoneResult);
      // This phone number already has a password account. Treating it as
      // success would ignore the new password and overwrite the profile.
      if (e.code == 'provider-already-linked' ||
          e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: accountExistsCode,
          message: 'An account with this phone number already exists.',
        );
      }
      rethrow;
    }

    return phoneResult;
  }

  // Thrown by verifyOtpAndSignUp when the phone number is already registered.
  static const accountExistsCode = 'account-already-exists';

  // Thrown by verifyOtpForPasswordReset when the phone number has no account.
  static const noAccountCode = 'no-account-for-phone';

  // ── Password reset — Step 1: verify OTP for an existing account ──────────
  Future<UserCredential> verifyOtpForPasswordReset({
    required String verificationId,
    required String smsCode,
  }) async {
    final result = await verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    // Signing in with an unregistered phone silently creates a new account.
    if (result.additionalUserInfo?.isNewUser ?? false) {
      await _discardSignIn(result);
      throw FirebaseAuthException(
        code: noAccountCode,
        message: 'No account found for this phone number.',
      );
    }
    return result;
  }

  // ── Password reset — Step 2: set the new password, then sign out ─────────
  Future<void> resetPassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'session-expired',
        message: 'Your verification expired. Please start again.',
      );
    }
    await user.updatePassword(newPassword);
    await _auth.signOut();
  }

  // Signs out, and deletes the account if this sign-in just created it.
  Future<void> _discardSignIn(UserCredential result) async {
    if (result.additionalUserInfo?.isNewUser ?? false) {
      try {
        await result.user?.delete();
      } on FirebaseAuthException {
        // Best effort — signing out below still ends the session.
      }
    }
    await _auth.signOut();
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
  // For failures while verifying a code, signing up, or resetting a password.
  String friendlyVerifyError(Object error, AppStrings s) {
    final code = error is FirebaseAuthException ? error.code : '';
    switch (code) {
      case 'invalid-verification-code':
        return s.errIncorrectCode;
      case 'session-expired':
      case 'code-expired':
        return s.errCodeExpired;
      case accountExistsCode:
        return s.errAccountExists;
      case noAccountCode:
        return s.errNoAccount;
      case 'weak-password':
        return s.errWeakPassword;
      case 'too-many-requests':
        return s.errTooManyAttempts;
      case 'network-request-failed':
        return s.errNoInternet;
      default:
        return s.errGeneric;
    }
  }

  String _friendlyPhoneError(String code, AppStrings s) {
    switch (code) {
      case 'invalid-phone-number':
        return s.errInvalidPhone;
      case 'too-many-requests':
        return s.errTooManyAttempts;
      case 'network-request-failed':
        return s.errNoInternet;
      case 'quota-exceeded':
        return s.errSmsQuota;
      default:
        return s.errSendCodeFailed;
    }
  }
}
