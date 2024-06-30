import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:wagtrack/models/user_model.dart';
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

/// inputs for authentication
class Inputs {
  static const emailValid = 'test@example.com';
  static const emailInvalid = 'invalid';
  static const passwordValid = 'password123!';
  static const passwordInvalid = 'short';
  static const nameValid = 'new user';
  static const blank = '';
}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserService mockUserService;
  late AuthenticationService authService;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockFacebookAuth mockFacebookAuth;

  late MockUser mockUser;
  late MockUserCredential mockUserCredential;

  // test AppUsers
  final emptyAppUser = AppUser.createEmptyUser();
  final testAppUser = AppUser(uid: "uid");

  /// Reinjects dependency instances into `GetIt`
  Future<void> reInjectDepedencyInstances() async {
    final getIt = GetIt.instance;
    getIt.allowReassignment = true;

    getIt.registerSingleton<GoogleSignIn>(mockGoogleSignIn);
    getIt.registerSingleton<FacebookAuth>(mockFacebookAuth);
    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
  }

  /// Sets dependency instances to be used for mocking/stubbing and to be referenced
  /// in the main code
  void setDependencyInstances() {
    mockGoogleSignIn = MockGoogleSignIn();
    mockFacebookAuth = MockFacebookAuth();
    mockFirebaseAuth = MockFirebaseAuth();
  }

  // MAIN TESTING CODE

  /// Initial first-time test setup
  ///
  /// Including setting `FallbackValue`s
  setUpAll(() {
    registerFallbackValue(AppUser(uid: "uid"));
  });

  setUp(() async {
    setDependencyInstances();
    await reInjectDepedencyInstances();

    mockUserService = MockUserService();
    authService = AuthenticationService(mockUserService);
    mockUser = MockUser();
  });

  group('checkAndCreateUser', () {
    setUp(() {
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();
    });

    test('creates new user if user is not in Firebase', () async {
      // inputs
      const name = 'display name';
      const uid = 'uid';
      const email = 'test@test.com';

      // stubs
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.displayName).thenReturn(name);
      when(() => mockUser.uid).thenReturn(uid);
      // user exists
      when(() => mockUserService.getUserFromDb(uid: uid))
          .thenAnswer((_) async => emptyAppUser);
      when(() => mockUserService.user).thenReturn(emptyAppUser);

      // call
      authService.checkAndCreateUser(userCredential: mockUserCredential);

      verifyNever(() => mockUserService.setUser(user: any(named: "user")));
    });

    test('does not create new user if user is in Firebase', () async {
      // inputs
      const name = 'display name';
      const uid = 'uid';
      const email = 'test@test.com';

      // stubs
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.displayName).thenReturn(name);
      when(() => mockUser.uid).thenReturn(uid);
      when(() => mockUser.email).thenReturn(email);
      // user exists
      when(() => mockUserService.getUserFromDb(uid: uid))
          .thenAnswer((_) async => testAppUser);
      when(() => mockUserService.user).thenReturn(testAppUser);

      // call
      authService.checkAndCreateUser(userCredential: mockUserCredential);

      verifyNever(() => mockUserService.setUser(user: any(named: "user")));
    });
  });

  group('signInWithEmailAndPassword', () {
    setUp(() {
      // we assume that the user exists - but this is not checked, only to determine
      // the stubs
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();

      // stubs
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.displayName).thenReturn('name');
      when(() => mockUser.uid).thenReturn('uid');
      when(() => mockUser.email).thenReturn('email');
      // user exists
      when(() => mockUserService.getUserFromDb(uid: 'uid'))
          .thenAnswer((_) async => testAppUser);
      when(() => mockUserService.user).thenReturn(testAppUser);
    });

    test('returns "Success" on successful sign in', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenAnswer((_) async => mockUserCredential);

      final result = await authService.signInWithEmailAndPassword(
          Inputs.emailValid, Inputs.passwordValid);

      expect(result, 'Success');
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: Inputs.emailValid, password: Inputs.passwordValid)).called(1);
    });
    test('returns error code for invalid credentials', () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      final result = await authService.signInWithEmailAndPassword(
          Inputs.emailValid, Inputs.passwordValid);

      expect(result, 'invalid-credential');
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: Inputs.emailValid, password: Inputs.passwordValid)).called(1);
    });
  });

  group('registerWithEmailAndPassword', () {
    setUp(() {
      // we assume that the user does not exist
      mockUserCredential = MockUserCredential();
      mockUser = MockUser();

      // stubs
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUser.displayName).thenReturn('name');
      when(() => mockUser.uid).thenReturn('uid');
      when(() => mockUser.email).thenReturn('email');
      // user exists
      when(() => mockUserService.getUserFromDb(uid: 'uid'))
          .thenAnswer((_) async => emptyAppUser);
      when(() => mockUserService.user).thenReturn(emptyAppUser);
      // return mockUserCredential
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
            email: any(named: "email"),
            password: any(named: "password"),
          )).thenAnswer((_) async => mockUserCredential);
    });

    test('returns "Success" on successful registration', () async {
      final result = await authService.registerWithEmailAndPassword(
          'Test User', Inputs.emailValid, Inputs.passwordValid);

      expect(result, 'Success');
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: Inputs.emailValid, password: Inputs.passwordValid)).called(1);
    });

    test('returns error code on FirebaseAuthException', () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      final result = await authService.registerWithEmailAndPassword(
          'Test User', Inputs.emailValid, Inputs.passwordValid);

      expect(result, 'email-already-in-use');
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: Inputs.emailValid, password: Inputs.passwordValid)).called(1);
    });
  });

  group('resetPassword', () {
    setUp(() {});

    test('returns "Success" on successful password reset', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
          email: any(named: 'email'))).thenAnswer((_) async {});

      final result = await authService.resetPassword(Inputs.emailValid);

      expect(result, 'Success');
      verify(() =>
              mockFirebaseAuth.sendPasswordResetEmail(email: Inputs.emailValid))
          .called(1);
    });

    test('returns error code on FirebaseAuthException', () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
              email: any(named: 'email')))
          .thenThrow(FirebaseAuthException(code: 'invalid-email'));

      final result = await authService.resetPassword(Inputs.emailValid);

      expect(result, 'invalid-email');
      verify(() =>
              mockFirebaseAuth.sendPasswordResetEmail(email: Inputs.emailValid))
          .called(1);
    });
  });

  group('isEmailValidEmail', () {
    test('should return true for valid email', () {
      final result = authService.isEmailValidEmail(Inputs.emailValid);

      expect(result, true);
    });

    test('should return false for invalid email', () {
      final result = authService.isEmailValidEmail(Inputs.emailInvalid);

      expect(result, false);
    });

    test('should return false for blank email', () {
      final result = authService.isEmailValidEmail(Inputs.blank);

      expect(result, false);
    });
  });

  group('passwordDontMatchConfirmPassword', () {
    test('should return true for non-matching passwords', () {
      final result = authService.passwordDontMatchConfirmPassword(
          'password123', 'password456');

      expect(result, true);
    });

    test('should return false for matching passwords', () {
      final result = authService.passwordDontMatchConfirmPassword(
          'password123', 'password123');

      expect(result, false);
    });
  });
}
