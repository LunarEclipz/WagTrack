import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/services/logging.dart';

/// Communication to Firestore and local preferences for user-related data.
///
/// ---
///
/// ## How To Use
/// In all widgets under `WagTrackApp` (main):
///
/// ### Initialise
/// ```dart
/// UserService userService = context.watch<UserService>();
/// ```
///
/// Overwrite with new `AppUser` object:
/// ```dart
/// userService.setUser(AppUser.createEmptyUser());
/// ```
///
/// Update from firestore with given uid (if no user found, nothing happens)
/// ```dart
/// await userService.getUserFromDb("");
/// ```
///
/// ---
///
/// ### Read
/// ```dart
/// // watch() subscribes to changes.
/// AppUser user = context.watch<UserService>().user;
/// ```
/// Access fields accordingly:
/// ```dart
/// String uid = user.uid;
/// bool allowShareData = user.allowShareData;
/// // ...
/// ```
/// Note that all fields will not be null.
///
/// ---
///
/// ### Write
/// ```dart
/// // read() only gets info once.
/// UserService userService = context.read<UserService>();
/// ```
///
/// Change individual params of **local** user object:
/// While you can modify the `AppUser` fields directly, using `setParams()`
/// updates attached listeners.
/// ```dart
/// _userService.setParams(name: "", allowCamera: false);
/// ```
///
/// Then, after all changes are complete, call `updateUserInDb()` to push changes
/// to local cache and Firestore database:
/// ```dart
/// await userService.updateUserInDb();
/// ```
///
class UserService with ChangeNotifier {
  static FirebaseFirestore db = FirebaseFirestore.instance;
  static Reference storageRef = FirebaseStorage.instance.ref();

  /// Current user.
  ///
  /// user is always an `AppUser` object. May be an empty user.
  AppUser _user = AppUser.createEmptyUser();

  /// Get current user.
  ///
  /// user is always an `AppUser` object. May be an empty user.
  AppUser get user => _user;

  /// Adds or updates current user in Firestore.
  ///
  /// (And local preferences for local settings)
  Future<void> updateUserInDb() async {
    AppLogger.d("Updating local user in db");
    if (_user.isEmpty()) {
      // user does not exist
      AppLogger.w("Local user does not exist");
      return;
    }

    try {
      // first get uid to be used as document id
      String uid = _user.uid;

      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('device_allow_camera', _user.allowCamera);
        prefs.setBool('device_allow_gallery', _user.allowGallery);
      });

      await db.collection("users").doc(uid).set(_user.toJson());
      AppLogger.i("Successfully updated local user params in Firestore");
    } catch (e) {
      AppLogger.e("Error updating local user in db: $e", e);
    }
  }

  /// Updates local preferences.
  Future<void> updateLocalPrefs() async {
    AppLogger.d("Updating local preferences");
    if (_user.isEmpty()) {
      // user does not exist
      AppLogger.w("Local user does not exist");
      return;
    }

    try {
      // first get uid to be used as document id
      String uid = _user.uid;

      SharedPreferences.getInstance().then((prefs) {
        prefs.setBool('device_allow_camera', _user.allowCamera);
        prefs.setBool('device_allow_gallery', _user.allowGallery);
      });

      await db.collection("users").doc(uid).set(_user.toJson());
      AppLogger.i("Successfully updated local preferences");
    } catch (e) {
      AppLogger.e("Error updating local preferences: $e", e);
    }
  }

  /// Sets current user from an `AppUser` object.
  void setUser({required AppUser user}) {
    AppLogger.d("Setting current user");
    _user = user;
    notifyListeners();
  }

  /// change paramaters of current user
  void setParams({
    String? uid,
    String? name,
    String? email,
    String? defaultLocation,
    String? phoneNumber,
    bool? allowShareContact,
    bool? allowShareData,
    bool? allowCamera,
    bool? allowGallery,
  }) {
    AppLogger.d("Setting parameters of current user");
    _user.updateParams(
      uid: uid,
      name: name,
      email: email,
      defaultLocation: defaultLocation,
      phoneNumber: phoneNumber,
      allowShareData: allowShareData,
      allowShareContact: allowShareContact,
      allowCamera: allowCamera,
      allowGallery: allowGallery,
    );
    notifyListeners();
  }

  /// Get user from user id and sets as `user`. Gets data from Firestore and local
  /// preferences.
  ///
  /// Does nothing if there is an error.
  ///
  /// https://firebase.google.com/docs/firestore/query-data/get-data
  Future<void> getUserFromDb({required String uid}) async {
    AppLogger.d("Getting user from Firestore");

    final docRef = db.collection("users").doc(uid);
    docRef.get().then((DocumentSnapshot doc) {
      if (!doc.exists) {
        // doc does not exist - no changes
        return;
      }

      final data = doc.data() as Map<String, dynamic>;

      _user.uid = uid;
      _user.updateFromJson(data);
      notifyListeners();
    },
        onError: (e) =>
            {AppLogger.e("Error getting user from Firestore: $e", e)});

    // get local prefs
    AppLogger.t("Getting local preferences");
    SharedPreferences.getInstance().then((prefs) {
      _user.allowCamera = prefs.getBool('device_allow_camera') ?? false;
      _user.allowGallery = prefs.getBool('device_allow_gallery') ?? false;
    });

    AppLogger.i("User data obtained successfully");
  }

  /// Resets user data.
  ///
  /// Retains name and email.
  ///
  /// Does not delete user from FireStore.
  Future<void> resetUserData() async {
    AppLogger.d("resetting user data");
    _user.resetData();
    String uid = _user.uid;

    final docRef = db.collection("users").doc(uid);

    final overwriteData = {
      "phoneNumber": null,
      "defaultLocation": null,
      "allowShareContact": false,
      "allowShareData": false,
      "hasOnboarded": false,
    };

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('device_allow_camera', false);
      prefs.setBool('device_allow_gallery', false);
    });

    docRef.set(overwriteData).onError(
        (e, _) => AppLogger.e("Error resetting user data in Firestore: $e", e));

    notifyListeners();
    AppLogger.i("User data reset successfully");
  }

  /// Checks firestore db if a document exists under the given uid.
  Future<bool> doesUserExist(String uid) async {
    AppLogger.t("Checking if user exists");
    final docRef = db.collection("users").doc(uid);
    DocumentSnapshot doc = await docRef.get();

    return doc.exists;
  }

  /// Deletes **current** user from Firestore and resets local user object.
  ///
  /// Use with caution.
  ///
  /// Make sure the user is still authenticated when deleting!
  ///
  /// https://firebase.google.com/docs/firestore/manage-data/delete-data
  Future<void> deleteUser() async {
    AppLogger.d("Deleting user");
    await db.collection("users").doc(_user.uid).delete().then(
        (doc) => AppLogger.i("User deleted from Firestore"),
        onError: (e, _) =>
            AppLogger.e("Error deleting user from Firestore: $e", e));

    _user = AppUser.createEmptyUser();
  }
}
