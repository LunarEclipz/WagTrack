import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/user_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserService extends Mock implements UserService {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class MockFacebookAuth extends Mock implements FacebookAuth {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserService mockUserService;
  late AuthenticationService authService;

  late MockUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserService = MockUserService();
    authService = AuthenticationService(mockUserService);
    mockUser = MockUser();
  });

  group('AuthenticationService', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('signInWithEmailAndPassword returns "Success" on successful sign in',
        () async {
      final mockUserCredential = MockUserCredential();

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid');

      when(() => mockUserService.getUserFromDb(uid: 'uid'))
          .thenAnswer((_) async {});

      final result =
          await authService.signInWithEmailAndPassword(email, password);

      expect(result, 'Success');
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: email, password: password)).called(1);
    });

    test(
        'signInWithEmailAndPassword returns error code on FirebaseAuthException',
        () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final result =
          await authService.signInWithEmailAndPassword(email, password);

      expect(result, 'user-not-found');
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: email, password: password)).called(1);
    });

    test('resetPassword returns "Success" on successful password reset',
        () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: any(named: 'email'))).thenAnswer((_) async {});

      final result = await authService.resetPassword(email);

      expect(result, 'Success');
      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .called(1);
    });

    test('resetPassword returns error code on FirebaseAuthException', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email')))
          .thenThrow(FirebaseAuthException(code: 'user-not-found'));

      final result = await authService.resetPassword(email);

      expect(result, 'user-not-found');
      verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: email))
          .called(1);
    });

    test(
        'registerWithEmailAndPassword returns "Success" on successful registration',
        () async {
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid');

      final result = await authService.registerWithEmailAndPassword(
          'Test User', email, password);

      expect(result, 'Success');
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password)).called(1);
    });

    test(
        'registerWithEmailAndPassword returns error code on FirebaseAuthException',
        () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await authService.registerWithEmailAndPassword(
          'Test User', email, password);

      expect(result, 'email-already-in-use');
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password)).called(1);
    });

    test('isEmailValidEmail returns true for valid email', () {
      final result = authService.isEmailValidEmail('test@example.com');

      expect(result, true);
    });

    test('isEmailValidEmail returns false for invalid email', () {
      final result = authService.isEmailValidEmail('invalid-email');

      expect(result, false);
    });

    test(
        'passwordDontMatchConfirmPassword returns true for non-matching passwords',
        () {
      final result = authService.passwordDontMatchConfirmPassword(
          'password123', 'password456');

      expect(result, true);
    });

    test(
        'passwordDontMatchConfirmPassword returns false for matching passwords',
        () {
      final result = authService.passwordDontMatchConfirmPassword(
          'password123', 'password123');

      expect(result, false);
    });
  });
}
