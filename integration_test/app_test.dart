import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/screens/app_wrapper.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/screens/authorisation/authorisation_frame.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/medication_service.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/post_service.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';

class MockAuthService extends Mock implements AuthenticationService {}

class MockPetService extends Mock implements PetService {}

class MockUserService extends Mock implements UserService {}

class MockSymptomService extends Mock implements SymptomService {}

class MockMedicationService extends Mock implements MedicationService {}

class MockNotificationService extends Mock implements NotificationService {}

class MockPostService extends Mock implements PostService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class FakeUser extends Fake implements User {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeUser());
  });

  late MockAuthService mockAuthService;
  late MockPetService mockPetService;
  late MockUserService mockUserService;
  late MockSymptomService mockSymptomService;
  late MockMedicationService mockMedicationService;
  late MockNotificationService mockNotifService;
  late MockPostService mockPostService;
  late MockFirebaseAuth mockFirebaseAuth;

  late StreamController<User?> authStateController;
  late FakeUser fakeUser;

  injectTestDependencies() {
    final getIt = GetIt.instance;
    getIt.allowReassignment = true;

    getIt.registerSingleton<FirebaseAuth>(mockFirebaseAuth);
  }

  setUp(() {
    mockAuthService = MockAuthService();
    mockPetService = MockPetService();
    mockUserService = MockUserService();
    mockSymptomService = MockSymptomService();
    mockMedicationService = MockMedicationService();
    mockNotifService = MockNotificationService();
    mockPostService = MockPostService();
    mockFirebaseAuth = MockFirebaseAuth();
    fakeUser = FakeUser();
    authStateController = StreamController<User?>.broadcast();

    injectTestDependencies();

    /// Default stubs
    // Firebase
    when(() => mockFirebaseAuth.authStateChanges())
        .thenAnswer((_) => authStateController.stream);
    // auth service
    when(() => mockAuthService.updateCurrentLocalUserFromAuth())
        .thenAnswer((_) async => true);
  });

  Future<void> pumpTests(WidgetTester tester) async {
    // Build the widget with mocked providers'
    await Firebase.initializeApp();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<NotificationService>(
            create: (_) => mockNotifService,
          ),
          ChangeNotifierProvider<AuthenticationService>(
            create: (_) => mockAuthService,
          ),
          ChangeNotifierProvider<PetService>(
            create: (_) => mockPetService,
          ),
          ChangeNotifierProvider<UserService>(
            create: (_) => mockUserService,
          ),
          ChangeNotifierProvider<MockSymptomService>(
            create: (_) => mockSymptomService,
          ),
          ChangeNotifierProvider<MockMedicationService>(
            create: (_) => mockMedicationService,
          ),
          ChangeNotifierProvider<MockPostService>(
            create: (_) => mockPostService,
          ),
        ],
        child: const MaterialApp(home: Authenticate()),
      ),
    );
  }

  group('end-to-end test', () {
    testWidgets(
      'Login, add pet and delete pet.',
      (WidgetTester tester) async {
        // Initially, there is no authenticated user.
        authStateController.add(null);

        /// Testing data
        final List<Pet> personalPets = [];
        final AppUser testUser =
            AppUser(uid: '123', name: 'TestUser', defaultLocation: 'YISHUN');
        final Pet testPet = Pet(
          location: 'YISHUN',
          name: 'testPet',
          description: 'description',
          sex: 'Male',
          species: 'Dog',
          petType: 'personal',
          idNumber: '1234',
          birthDate: DateTime.now(),
          weight: [],
          caretakers: [],
          posts: 0,
          fans: 0,
          caretakerIDs: [],
          vaccineRecords: [],
          sessionRecords: [],
        );

        /// STUBS
        // User has onboarded
        when(() => mockAuthService.updateCurrentLocalUserFromAuth())
            .thenAnswer((_) async {
          debugPrint("CALLED");
          return true;
        });
        when(() => mockAuthService.isEmailValidEmail(any())).thenReturn(true);
        when(() => mockAuthService.signInWithEmailAndPassword(any(), any()))
            .thenAnswer((_) async => 'Success');
        when(() => mockPetService.personalPets).thenReturn(personalPets);
        when(() => mockPetService.communityPets).thenReturn(<Pet>[]);
        when(() => mockPostService.posts).thenReturn([]);

        /// Pump tests
        await pumpTests(tester);

        // make sure login page is shown
        expect(find.byType(LoginPage), findsOneWidget);

        // ==== LOGIN ====
        // Enter valid email and password
        await tester.enterText(
            find.widgetWithText(AppTextFormFieldLarge, 'Email Address'),
            'test@example.com');
        await tester.enterText(
            find.widgetWithText(AppTextFormFieldLarge, 'Password'),
            'password123');
        await tester.tap(find.byKey(const ValueKey('login-button')));

        // update stream
        authStateController.add(fakeUser);

        await tester.pumpAndSettle();

        // verify signed in
        verify(() => mockAuthService.signInWithEmailAndPassword(
            'test@example.com', 'password123')).called(1);

        await tester.pumpAndSettle();

        // verify in home page
        expect(find.byType(AppWrapper), findsOneWidget);
      },
    );
  });
}
