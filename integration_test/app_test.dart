import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/pet_details/add_pet.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';

class MockAuthService extends Mock implements AuthenticationService {}

class MockPetService extends Mock implements PetService {}

class MockUserService extends Mock implements UserService {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockAuthService mockAuthService;
  late MockPetService mockPetService;
  late MockUserService mockUserService;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockPetService = MockPetService();
    mockUserService = MockUserService();
  });

  Future<void> pumpTests(WidgetTester tester) async {
    // Build the widget with mocked providers'

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthenticationService>(
            create: (_) => mockAuthService,
          ),
          ChangeNotifierProvider<PetService>(
            create: (_) => mockPetService,
          ),
          ChangeNotifierProvider<UserService>(
            create: (_) => mockUserService,
          ),
        ],
        child: const MaterialApp(home: AddPetPage()),
      ),
    );
  }

  group('end-to-end test', () {
    testWidgets(
      'Login, add pet and delete pet.',
      (WidgetTester tester) async {
        /// STUBS
        when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
        when(() => mockAuthService.signInWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => 'success');

        await pumpTests(tester);

        // ==== LOGIN ====
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
      },
    );
  });
}
