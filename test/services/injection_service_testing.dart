import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/services/user_service.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFacebookAuth extends Mock implements FacebookAuth {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockUserService extends Mock implements UserService {}

class MockNotificationService extends Mock implements NotificationService {}

/// Handles injecting dependencies
class InjectionServiceTesting {
  static final locator = GetIt.instance;

  /// Dependency injection for testing, with mock classes.
  ///
  /// To be called in `main()`
  static injectAll() async {
    locator.allowReassignment;

    locator.registerSingletonAsync<SharedPreferences>(
        () async => MockSharedPreferences());

    locator.registerSingleton<FlutterLocalNotificationsPlugin>(
        MockFlutterLocalNotificationsPlugin());

    locator.registerSingleton<FirebaseFirestore>(MockFirebaseFirestore());
    locator.registerSingleton<FirebaseStorage>(MockFirebaseStorage());
    locator.registerSingleton<FirebaseAuth>(MockFirebaseAuth());

    // auth providers
    locator.registerSingleton<FacebookAuth>(MockFacebookAuth());
    locator.registerSingleton<GoogleSignIn>(MockGoogleSignIn());

    // WagTrack providers
    locator.registerSingleton(MockUserService());
    locator.registerSingleton(MockNotificationService());

    // make sure all dependencies are loaded.
    await locator.allReady();
  }
}
