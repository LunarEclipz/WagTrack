import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/screens/pet_details/add_pet.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
// ... other imports

class MockAuthService extends Mock implements AuthenticationService {}

class MockPetService extends Mock implements PetService {}

class MockUserService extends Mock implements UserService {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
  });

  late MockAuthService mockAuthService;
  late MockPetService mockPetService;
  late MockUserService mockUserService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockPetService = MockPetService();
    mockUserService = MockUserService();
  });

  Future<void> pumpAddPet(WidgetTester tester) async {
    // Build the widget with mocked providers'
    await tester.binding.setSurfaceSize(const Size(2000, 600));

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

  testWidgets('adds pet with correct fields when Add Pet button is tapped',
      (WidgetTester tester) async {
    // Stub the user service to return a default user with location.
    when(() => mockUserService.user).thenReturn(
        AppUser(uid: '123', name: 'TestUser', defaultLocation: 'YISHUN'));

    // Pet fields
    const name = 'Test pet';
    const desc = 'Test description';
    const breed = 'Test breed';
    const idNum = '1234Test';
    const location = 'PAYA LEBAR';

    await pumpAddPet(tester);

    // // get page scroll
    final pageScrollFinder = find.byType(SingleChildScrollView).last;
    expect(pageScrollFinder, findsOneWidget);

    // // Find the personal pet type card and tap it
    await tester.dragUntilVisible(
      find.text('Personal\nPet').at(0),
      pageScrollFinder,
      const Offset(0.0, -100.0),
    );
    await tester.tap(find.text('Personal\nPet').at(0));
    await tester.pumpAndSettle();

    // Select location
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('location_dropdown')),
      pageScrollFinder,
      const Offset(0.0, -100.0),
    );
    await tester.tap(find.byKey(const ValueKey('location_dropdown')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(location));
    await tester.pumpAndSettle();

    // Fill in the pet information (replace with actual test data)
    // scroll first
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('name_field')),
      pageScrollFinder,
      const Offset(0.0, -100.0),
    );

    await tester.enterText(find.byKey(const ValueKey('name_field')), name);
    await tester.enterText(
        find.byKey(const ValueKey('description_field')), desc);
    await tester.enterText(find.byKey(const ValueKey('breed_field')), breed);

    // Scroll down
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('microchip_field')),
      pageScrollFinder,
      const Offset(0.0, -100.0),
    );
    await tester.enterText(
        find.byKey(const ValueKey('microchip_field')), idNum);

    // Tap the 'Set Birthday' button
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Set Birthday'));
    await tester.pumpAndSettle();

    // Select a birthday date
    // Just choose the first date
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // Tap the "Add Pet" button
    await tester.dragUntilVisible(
      find.byKey(const ValueKey('add_pet_button')),
      pageScrollFinder,
      const Offset(0.0, -100.0),
    );
    await tester.tap(find.byKey(const Key('add_pet_button')));
    await tester.pumpAndSettle();

    // Verify that the petService's `addPet` method is called with the correct Pet object and image (null in this case)
    final expectedPet = Pet(
      location: location,
      name: name,
      description: desc,
      sex: 'Male',
      species: 'Dog',
      petType: 'personal',
      idNumber: idNum,
      breed: breed,
      birthDate: DateTime.now(),
      weight: [],
      caretakers: [],
      posts: 0,
      fans: 0,
      caretakerIDs: [],
      vaccineRecords: [],
      sessionRecords: [],
    );
    verify(() => mockPetService.addPet(pet: expectedPet, img: null, uid: '123'))
        .called(1); // Assuming uid '123' for this example
  });
  // ... (Add more tests to cover different scenarios, e.g., adding community pets, caretaker mode, etc.)
}
