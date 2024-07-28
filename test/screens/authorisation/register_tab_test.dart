import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/register_tab.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';

class MockAuthService extends Mock implements AuthenticationService {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  group('RegisterTab Widget Tests', () {
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
    });

    Future<void> pumpRegisterTab(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthenticationService>(
            create: (_) => mockAuthService,
            child: const Scaffold(
              body: RegisterTab(),
            ),
          ),
        ),
      );
    }

    testWidgets(
        'displays username, email, password, and confirm password fields',
        (WidgetTester tester) async {
      await pumpRegisterTab(tester);

      expect(find.byType(AppTextFormFieldLarge), findsNWidgets(4));
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets(
        'validates and attempt registration when Register button is tapped',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() =>
              mockAuthService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => 'Success');
      when(() => mockAuthService.passwordDontMatchConfirmPassword(any(), any()))
          .thenReturn(false);

      await pumpRegisterTab(tester);

      // Enter valid username, email, password, and confirm password
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Username'), 'testuser');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Confirm Password'),
          'password123');
      await tester.tap(find.text('Register'));

      await tester.pump();

      verify(() => mockAuthService.registerWithEmailAndPassword(
          'testuser', 'test@example.com', 'password123')).called(1);
    });

    testWidgets('shows error dialog on invalid email format',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(false);

      await pumpRegisterTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'invalid-email');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Confirm Password'),
          'password123');
      await tester.tap(find.text('Register'));

      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('shows error dialog on passwords not matching',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);

      await pumpRegisterTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Confirm Password'),
          'differentPassword');
      await tester.tap(find.text('Register'));

      await tester.pump();

      expect(find.text('Passwords not the same'), findsOneWidget);
    });

    testWidgets('shows error dialog on network failure',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() =>
              mockAuthService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => 'network-request-failed');
      when(() => mockAuthService.passwordDontMatchConfirmPassword(any(), any()))
          .thenReturn(false);

      await pumpRegisterTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Username'), 'testuser');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Confirm Password'),
          'password123');
      await tester.tap(find.text('Register'));

      await tester.pump();

      expect(find.text('Network error. Please check your internet connection.'),
          findsOneWidget);
    });

    testWidgets('shows error dialog on email already in use',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() =>
              mockAuthService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => 'email-already-in-use');
      when(() => mockAuthService.passwordDontMatchConfirmPassword(any(), any()))
          .thenReturn(false);

      await pumpRegisterTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Username'), 'testuser');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Confirm Password'),
          'password123');
      await tester.tap(find.text('Register'));

      await tester.pump();

      expect(find.text('An account already exists for that email.'),
          findsOneWidget);
    });

    testWidgets('shows error text on weak password',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() =>
              mockAuthService.registerWithEmailAndPassword(any(), any(), any()))
          .thenAnswer((_) async => 'weak-password');

      await pumpRegisterTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Username'), 'testuser');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'), 'short');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Confirm Password'),
          'short');
      await tester.tap(find.text('Register'));

      await tester.pump();

      expect(find.text('Minimum of 6 characters'), findsAny);
    });
  });
}
