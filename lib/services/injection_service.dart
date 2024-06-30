import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Handles injecting dependencies
class InjectionService {
  static final locator = GetIt.instance;

  /// Dependency injection for main app code.
  ///
  /// To be called in `main()`
  static injectAll() async {
    locator.registerSingletonAsync<SharedPreferences>(
        () async => SharedPreferences.getInstance());

    locator.registerSingleton<FlutterLocalNotificationsPlugin>(
        FlutterLocalNotificationsPlugin());

    locator.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
    locator.registerSingleton<FirebaseStorage>(FirebaseStorage.instance);
    locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

    // auth providers
    locator.registerSingleton<FacebookAuth>(FacebookAuth.instance);
    locator.registerSingleton<GoogleSignIn>(GoogleSignIn());

    // make sure all dependencies are loaded.
    await locator.allReady();
  }
}
