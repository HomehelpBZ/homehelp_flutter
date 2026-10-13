import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:homehelp/l10n/app_strings.dart';
import 'package:homehelp/services/auth_service.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAdditionalUserInfo extends Mock implements AdditionalUserInfo {}

// A sign-in result for `user`, flagged as a new or returning account.
MockUserCredential signInResult(User? user, {required bool isNewUser}) {
  final info = MockAdditionalUserInfo();
  when(() => info.isNewUser).thenReturn(isNewUser);
  final result = MockUserCredential();
  when(() => result.user).thenReturn(user);
  when(() => result.additionalUserInfo).thenReturn(info);
  return result;
}

final en = AppStrings('en');
final am = AppStrings('am');

FirebaseAuthException authError(String code) =>
    FirebaseAuthException(code: code, message: 'firebase: $code');

void main() {
  late MockFirebaseAuth auth;
  late AuthService service;

  setUpAll(() {
    registerFallbackValue(
      PhoneAuthProvider.credential(verificationId: 'x', smsCode: 'x'),
    );
    registerFallbackValue((PhoneAuthCredential _) {});
    registerFallbackValue((FirebaseAuthException _) {});
    registerFallbackValue((String _, int? __) {});
    registerFallbackValue((String _) {});
  });

  setUp(() {
    auth = MockFirebaseAuth();
    service = AuthService(auth: auth);
  });

  // Stubs verifyPhoneNumber so that it invokes whichever Firebase callback
  // `trigger` chooses, mimicking what the SDK does after contacting Firebase.
  void stubVerifyPhoneNumber(void Function(Invocation inv) trigger) {
    when(() => auth.verifyPhoneNumber(
          phoneNumber: any(named: 'phoneNumber'),
          verificationCompleted: any(named: 'verificationCompleted'),
          verificationFailed: any(named: 'verificationFailed'),
          codeSent: any(named: 'codeSent'),
          codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
        )).thenAnswer((inv) async => trigger(inv));
  }

  // ════════════════════════════════════════════════════════════════════════
  group('phoneToEmail', () {
    test('adds a leading 0 to a 9-digit number', () {
      expect(service.phoneToEmail('911000001'), '0911000001@homehelp.app');
    });

    test('keeps an existing leading 0', () {
      expect(service.phoneToEmail('0911000001'), '0911000001@homehelp.app');
    });

    test('trims whitespace and removes inner spaces', () {
      expect(service.phoneToEmail('  911 000 001 '), '0911000001@homehelp.app');
    });

    test('signup and login map the same phone to the same account email', () {
      // Signup stores the 9-digit form; a user may log in typing the 0.
      expect(service.phoneToEmail('911000001'),
          service.phoneToEmail('0911000001'));
    });

    for (final input in [
      '+251911000001',
      '251911000001',
      '+251 91 100 0001',
      '091-100-0001',
    ]) {
      test('maps international/formatted "$input" to the same account', () {
        expect(service.phoneToEmail(input), '0911000001@homehelp.app');
      });
    }
  });

  group('toE164', () {
    for (final input in ['911000001', '0911000001', '+251911000001']) {
      test('formats "$input" as +251911000001', () {
        expect(service.toE164(input), '+251911000001');
      });
    }
  });

  // ════════════════════════════════════════════════════════════════════════
  group('signup — step 1: sendPhoneOtp', () {
    test('sends the number to Firebase and reports the verification id', () async {
      stubVerifyPhoneNumber((inv) {
        (inv.namedArguments[#codeSent] as PhoneCodeSent)('verif-123', 42);
      });

      String? sentId;
      String? error;
      await service.sendPhoneOtp(
        phoneNumber: '+251911000001',
        onCodeSent: (id) => sentId = id,
        onError: (e) => error = e,
        strings: en,
      );

      expect(sentId, 'verif-123');
      expect(error, isNull);
      verify(() => auth.verifyPhoneNumber(
            phoneNumber: '+251911000001',
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).called(1);
    });

    const friendlyErrors = {
      'invalid-phone-number':
          'Invalid phone number. Please enter a valid Ethiopian number.',
      'too-many-requests':
          'Too many attempts. Please wait a few minutes and try again.',
      'network-request-failed':
          'No internet connection. Please check your network.',
      'quota-exceeded': 'SMS quota exceeded. Please try again later.',
      'some-unknown-code':
          'Failed to send verification code. Please try again.',
    };

    friendlyErrors.forEach((code, message) {
      test('maps verification failure "$code" to a friendly message', () async {
        stubVerifyPhoneNumber((inv) {
          (inv.namedArguments[#verificationFailed]
              as PhoneVerificationFailed)(authError(code));
        });

        String? sentId;
        String? error;
        await service.sendPhoneOtp(
          phoneNumber: '+251911000001',
          onCodeSent: (id) => sentId = id,
          onError: (e) => error = e,
          strings: en,
        );

        expect(error, message);
        expect(sentId, isNull);
      });
    });

    test('reports send failures in Amharic when the app is in Amharic',
        () async {
      stubVerifyPhoneNumber((inv) {
        (inv.namedArguments[#verificationFailed]
            as PhoneVerificationFailed)(authError('invalid-phone-number'));
      });

      String? error;
      await service.sendPhoneOtp(
        phoneNumber: '+251911000001',
        onCodeSent: (_) {},
        onError: (e) => error = e,
        strings: am,
      );

      expect(error, am.errInvalidPhone);
      expect(error, isNot(en.errInvalidPhone));
    });

    test('auto-verification and auto-retrieval timeout trigger no callbacks',
        () async {
      stubVerifyPhoneNumber((inv) {
        (inv.namedArguments[#verificationCompleted]
                as PhoneVerificationCompleted)(
            PhoneAuthProvider.credential(verificationId: 'v', smsCode: '1'));
        (inv.namedArguments[#codeAutoRetrievalTimeout]
            as PhoneCodeAutoRetrievalTimeout)('v');
      });

      var calls = 0;
      await service.sendPhoneOtp(
        phoneNumber: '+251911000001',
        onCodeSent: (_) => calls++,
        onError: (_) => calls++,
        strings: en,
      );

      expect(calls, 0);
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  group('signup — step 2: verifyOtpAndSignUp', () {
    late MockUser user;
    late MockUserCredential phoneResult;

    setUp(() {
      user = MockUser();
      phoneResult = signInResult(user, isNewUser: true);
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => phoneResult);
      when(() => user.linkWithCredential(any()))
          .thenAnswer((_) async => MockUserCredential());
      when(() => user.delete()).thenAnswer((_) async {});
      when(() => auth.signOut()).thenAnswer((_) async {});
    });

    Future<UserCredential> signUp() => service.verifyOtpAndSignUp(
          verificationId: 'verif-123',
          smsCode: '654321',
          phone: '911000001',
          password: 'secret123',
        );

    test('signs in with the OTP credential', () async {
      await signUp();

      final cred = verify(() => auth.signInWithCredential(captureAny()))
          .captured
          .single as PhoneAuthCredential;
      expect(cred.verificationId, 'verif-123');
      expect(cred.smsCode, '654321');
    });

    test('links a phone-derived email + password for future logins', () async {
      await signUp();

      final cred = verify(() => user.linkWithCredential(captureAny()))
          .captured
          .single as EmailAuthCredential;
      expect(cred.email, '0911000001@homehelp.app');
      expect(cred.password, 'secret123');
    });

    test('returns the phone sign-in result and stays signed in', () async {
      expect(await signUp(), same(phoneResult));
      verifyNever(() => auth.signOut());
      verifyNever(() => user.delete());
    });

    test('phone already has a password: reports account exists, keeps it',
        () async {
      phoneResult = signInResult(user, isNewUser: false);
      when(() => user.linkWithCredential(any()))
          .thenThrow(authError('provider-already-linked'));

      await expectLater(
        signUp(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', AuthService.accountExistsCode)),
      );
      verify(() => auth.signOut()).called(1);
      verifyNever(() => user.delete()); // never delete an existing account
    });

    test('email owned by another account: reports account exists and '
        'deletes the orphaned phone-only account', () async {
      when(() => user.linkWithCredential(any()))
          .thenThrow(authError('email-already-in-use'));

      await expectLater(
        signUp(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', AuthService.accountExistsCode)),
      );
      verify(() => user.delete()).called(1);
      verify(() => auth.signOut()).called(1);
    });

    for (final code in [
      'weak-password',
      'network-request-failed',
      'credential-already-in-use',
    ]) {
      test('rethrows "$code" and cleans up the new account', () async {
        when(() => user.linkWithCredential(any())).thenThrow(authError(code));

        await expectLater(
          signUp(),
          throwsA(isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', code)),
        );
        verify(() => user.delete()).called(1);
        verify(() => auth.signOut()).called(1);
      });
    }

    test('still signs out if deleting the orphaned account fails', () async {
      when(() => user.linkWithCredential(any()))
          .thenThrow(authError('weak-password'));
      when(() => user.delete())
          .thenThrow(authError('network-request-failed'));

      await expectLater(
        signUp(),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'weak-password')),
      );
      verify(() => auth.signOut()).called(1);
    });

    for (final code in ['invalid-verification-code', 'session-expired']) {
      test('fails with "$code" and never links a password', () async {
        when(() => auth.signInWithCredential(any()))
            .thenThrow(authError(code));

        await expectLater(
          signUp(),
          throwsA(isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', code)),
        );
        verifyNever(() => user.linkWithCredential(any()));
      });
    }

    test('skips linking when Firebase returns no user', () async {
      phoneResult = signInResult(null, isNewUser: true);

      expect(await signUp(), same(phoneResult));
      verifyNever(() => user.linkWithCredential(any()));
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  group('signUpWithEmail', () {
    test('creates the account with the given credentials', () async {
      final result = MockUserCredential();
      when(() => auth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => result);

      expect(
        await service.signUpWithEmail(email: 'a@b.com', password: 'pw123456'),
        same(result),
      );
      verify(() => auth.createUserWithEmailAndPassword(
          email: 'a@b.com', password: 'pw123456')).called(1);
    });

    for (final code in [
      'email-already-in-use',
      'weak-password',
      'invalid-email',
    ]) {
      test('propagates "$code"', () async {
        when(() => auth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(authError(code));

        await expectLater(
          service.signUpWithEmail(email: 'a@b.com', password: 'pw'),
          throwsA(isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', code)),
        );
      });
    }
  });

  // ════════════════════════════════════════════════════════════════════════
  group('login — signInWithEmail', () {
    test('signs in with the phone-derived email used at signup', () async {
      final result = MockUserCredential();
      when(() => auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => result);

      // Mirrors the family/HK sign-in screens.
      final returned = await service.signInWithEmail(
        email: service.phoneToEmail('0911000001'),
        password: 'secret123',
      );

      expect(returned, same(result));
      verify(() => auth.signInWithEmailAndPassword(
            email: '0911000001@homehelp.app',
            password: 'secret123',
          )).called(1);
    });

    for (final code in [
      'invalid-credential',
      'wrong-password',
      'user-not-found',
      'user-disabled',
      'too-many-requests',
      'network-request-failed',
    ]) {
      test('propagates "$code"', () async {
        when(() => auth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(authError(code));

        await expectLater(
          service.signInWithEmail(email: 'x@homehelp.app', password: 'pw'),
          throwsA(isA<FirebaseAuthException>()
              .having((e) => e.code, 'code', code)),
        );
      });
    }
  });

  // ════════════════════════════════════════════════════════════════════════
  group('verifyPhoneOtp', () {
    test('signs in with the OTP credential', () async {
      final result = MockUserCredential();
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => result);

      expect(
        await service.verifyPhoneOtp(verificationId: 'v1', smsCode: '111222'),
        same(result),
      );
      final cred = verify(() => auth.signInWithCredential(captureAny()))
          .captured
          .single as PhoneAuthCredential;
      expect(cred.verificationId, 'v1');
      expect(cred.smsCode, '111222');
    });

    test('propagates an invalid code', () async {
      when(() => auth.signInWithCredential(any()))
          .thenThrow(authError('invalid-verification-code'));

      await expectLater(
        service.verifyPhoneOtp(verificationId: 'v1', smsCode: '000000'),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  group('password reset', () {
    late MockUser user;

    setUp(() {
      user = MockUser();
      when(() => user.delete()).thenAnswer((_) async {});
      when(() => user.updatePassword(any())).thenAnswer((_) async {});
      when(() => auth.signOut()).thenAnswer((_) async {});
    });

    test('verifies the code for a registered phone', () async {
      final result = signInResult(user, isNewUser: false);
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => result);

      expect(
        await service.verifyOtpForPasswordReset(
            verificationId: 'v1', smsCode: '123456'),
        same(result),
      );
      verifyNever(() => auth.signOut());
    });

    test('rejects an unregistered phone and deletes the account Firebase '
        'just created for it', () async {
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => signInResult(user, isNewUser: true));

      await expectLater(
        service.verifyOtpForPasswordReset(
            verificationId: 'v1', smsCode: '123456'),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', AuthService.noAccountCode)),
      );
      verify(() => user.delete()).called(1);
      verify(() => auth.signOut()).called(1);
    });

    test('propagates an incorrect code', () async {
      when(() => auth.signInWithCredential(any()))
          .thenThrow(authError('invalid-verification-code'));

      await expectLater(
        service.verifyOtpForPasswordReset(
            verificationId: 'v1', smsCode: '000000'),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'invalid-verification-code')),
      );
    });

    test('sets the new password, then signs out', () async {
      when(() => auth.currentUser).thenReturn(user);

      await service.resetPassword('newSecret1');

      verifyInOrder([
        () => user.updatePassword('newSecret1'),
        () => auth.signOut(),
      ]);
    });

    test('fails with session-expired when no one is verified', () async {
      when(() => auth.currentUser).thenReturn(null);

      await expectLater(
        service.resetPassword('newSecret1'),
        throwsA(isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'session-expired')),
      );
    });

    test('stays signed in when the password update fails', () async {
      when(() => auth.currentUser).thenReturn(user);
      when(() => user.updatePassword(any()))
          .thenThrow(authError('weak-password'));

      await expectLater(service.resetPassword('x'),
          throwsA(isA<FirebaseAuthException>()));
      verifyNever(() => auth.signOut()); // so the user can try again
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  group('friendlyVerifyError', () {
    const messages = {
      'invalid-verification-code':
          'Incorrect code. Please check and try again.',
      'session-expired': 'This code has expired. Please request a new one.',
      'code-expired': 'This code has expired. Please request a new one.',
      AuthService.accountExistsCode:
          'An account with this phone number already exists. Please sign in instead.',
      AuthService.noAccountCode:
          'No account found for this phone number. Please sign up instead.',
      'weak-password': 'Password is too weak. Please choose a stronger one.',
      'too-many-requests':
          'Too many attempts. Please wait a few minutes and try again.',
      'network-request-failed':
          'No internet connection. Please check your network.',
      'something-new': 'Something went wrong. Please try again.',
    };

    messages.forEach((code, message) {
      test('"$code"', () {
        expect(service.friendlyVerifyError(authError(code), en), message);
      });
    });

    test('non-Firebase errors get the generic message', () {
      expect(service.friendlyVerifyError(StateError('boom'), en),
          'Something went wrong. Please try again.');
    });

    final amharic = {
      'invalid-verification-code': am.errIncorrectCode,
      'session-expired': am.errCodeExpired,
      AuthService.accountExistsCode: am.errAccountExists,
      AuthService.noAccountCode: am.errNoAccount,
      'weak-password': am.errWeakPassword,
      'too-many-requests': am.errTooManyAttempts,
      'network-request-failed': am.errNoInternet,
      'something-new': am.errGeneric,
    };

    amharic.forEach((code, message) {
      test('"$code" in Amharic', () {
        final result = service.friendlyVerifyError(authError(code), am);
        expect(result, message);
        expect(result, isNot(messages[code])); // actually translated
      });
    });
  });

  // ════════════════════════════════════════════════════════════════════════
  group('session', () {
    test('currentUser delegates to Firebase', () {
      final user = MockUser();
      when(() => auth.currentUser).thenReturn(user);
      expect(service.currentUser, same(user));

      when(() => auth.currentUser).thenReturn(null);
      expect(service.currentUser, isNull);
    });

    test('authStateChanges reports sign-in, then sign-out', () async {
      final controller = StreamController<User?>();
      when(() => auth.authStateChanges()).thenAnswer((_) => controller.stream);
      final user = MockUser();

      final events = expectLater(
        service.authStateChanges,
        emitsInOrder([same(user), isNull, emitsDone]),
      );
      controller
        ..add(user)
        ..add(null);
      await controller.close();
      await events;
    });

    test('signOut signs out of Firebase', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});

      await service.signOut();

      verify(() => auth.signOut()).called(1);
    });

    test('signOut propagates failures', () async {
      when(() => auth.signOut()).thenThrow(authError('network-request-failed'));

      await expectLater(service.signOut(), throwsA(isA<FirebaseAuthException>()));
    });
  });
}
