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

void main() {
  late MockAuthService mockAuthService;
  late MockPetService mockPetService;
  late MockUserService mockUserService;

  setUp(() {
    mockAuthService = MockAuthService();
    mockPetService = MockPetService();
    mockUserService = MockUserService();
  });

  testWidgets('AddPetPage adds personal pet', (WidgetTester tester) async {
    // Stub the user service to return a default user with location.
    when(() => mockUserService.user).thenReturn(
        AppUser(uid: '123', name: 'TestUser', defaultLocation: 'Singapore'));

    // Build the widget with mocked providers
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AuthenticationService>(create: (_) => mockAuthService),
          Provider<PetService>(create: (_) => mockPetService),
          Provider<UserService>(create: (_) => mockUserService),
        ],
        child: const MaterialApp(home: AddPetPage()),
      ),
    );

    // Find the personal pet type card and tap it
    await tester.tap(find.text('Personal\nPet'));
    await tester.pump();

    // Fill in the pet information (replace with actual test data)
    await tester.enterText(find.byType(TextFormField).at(0), 'Fluffy'); // Name
    await tester.enterText(
        find.byType(TextFormField).at(1), 'Golden Retriever'); // Breed
    await tester.enterText(
        find.byType(TextFormField).at(2), '123456789'); // Chip
    // ... (Fill in the rest of the required fields)

    // Tap the 'Set Birthday' button
    await tester.tap(find.text('Set Birthday'));
    await tester.pumpAndSettle();

    // Select a birthday date (implement logic to choose a date on the picker)
    // ...

    // Tap the "Add Pet" button
    await tester.tap(find.text('Add Pet'));
    await tester.pumpAndSettle();

    // Verify that the petService's `addPet` method is called with the correct Pet object and image (null in this case)
    final expectedPet = Pet(
        // ... fill in details for expectedPet object based on test input
        );
    verify(() => mockPetService.addPet(pet: expectedPet, img: null, uid: '123'))
        .called(1); // Assuming uid '123' for this example
  });
  // ... (Add more tests to cover different scenarios, e.g., adding community pets, caretaker mode, etc.)
}
