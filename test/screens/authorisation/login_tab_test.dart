import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/forgot_password.dart';
import 'package:wagtrack/screens/authorisation/login_tab.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  group('LoginTab Widget Tests', () {
    late MockAuthenticationService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthenticationService();
    });

    Future<void> pumpLoginTab(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthenticationService>(
            create: (_) => mockAuthService,
            child: const Scaffold(
              body: LoginTab(),
            ),
          ),
        ),
      );
    }

    testWidgets('displays email and password fields',
        (WidgetTester tester) async {
      await pumpLoginTab(tester);

      expect(find.byType(AppTextFormFieldLarge), findsNWidgets(2));
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays Forgot Password text and navigate on tap',
        (WidgetTester tester) async {
      await pumpLoginTab(tester);

      expect(find.text('Forgot Password?'), findsOneWidget);
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.byType(ForgotPasswordPage), findsOneWidget);
    });

    testWidgets('validates and attempt login when Login button is tapped',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() => mockAuthService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => 'success');

      await pumpLoginTab(tester);

      // Enter valid email and password
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.tap(find.text('Login'));

      await tester.pump();

      verify(() => mockAuthService.signInWithEmailAndPassword(
          'test@example.com', 'password123')).called(1);
    });

    testWidgets('shows error dialog on invalid email format',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(false);

      await pumpLoginTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'invalid-email');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.tap(find.text('Login'));

      await tester.pump();

      expect(find.text('Invalid email'), findsOneWidget);
    });

    testWidgets('shows error dialog on invalid credentials',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() => mockAuthService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => 'invalid-credential');

      await pumpLoginTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.tap(find.text('Login'));

      await tester.pump();

      expect(find.text('Incorrect email or password.'), findsOneWidget);
    });

    testWidgets('shows network error dialog on network failure',
        (WidgetTester tester) async {
      when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
      when(() => mockAuthService.signInWithEmailAndPassword(any(), any()))
          .thenAnswer((_) async => 'network-request-failed');

      await pumpLoginTab(tester);

      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
          'test@example.com');
      await tester.enterText(
          find.widgetWithText(AppTextFormFieldLarge, 'Password'),
          'password123');
      await tester.tap(find.text('Login'));

      await tester.pump();

      expect(find.text('Network error. Please check your internet connection.'),
          findsOneWidget);
    });
  });
}
