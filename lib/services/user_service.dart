import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();
  final SharedPreferences _prefs = GetIt.I<SharedPreferences>();

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
    AppLogger.d("[USER] Updating local user in db");
    if (_user.isEmpty()) {
      // user does not exist
      AppLogger.w("[USER] Local user does not exist");
      return;
    }

    try {
      // first get uid to be used as document id
      String uid = _user.uid;

      _prefs.setBool('device_allow_camera', _user.allowCamera);
      _prefs.setBool('device_allow_gallery', _user.allowGallery);

      await _db.collection("users").doc(uid).set(_user.toJson());
      AppLogger.i("[USER] Successfully updated local user params in Firestore");
    } catch (e) {
      AppLogger.e("[USER] Error updating local user in db: $e", e);
    }
  }

  /// Updates local preferences.
  Future<void> updateLocalPrefs() async {
    AppLogger.d("[USER] Updating local preferences");
    if (_user.isEmpty()) {
      // user does not exist
      AppLogger.w("[USER] Local user does not exist");
      return;
    }

    try {
      // first get uid to be used as document id
      String uid = _user.uid;

      _prefs.setBool('device_allow_camera', _user.allowCamera);
      _prefs.setBool('device_allow_gallery', _user.allowGallery);

      await _db.collection("users").doc(uid).set(_user.toJson());
      AppLogger.i("[USER] Successfully updated local preferences");
    } catch (e) {
      AppLogger.e("[USER] Error updating local preferences: $e", e);
    }
  }

  /// Sets current user from an `AppUser` object.
  void setUser({required AppUser user}) {
    AppLogger.d("[USER] Setting current user");
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
    AppLogger.d("[USER] Setting parameters of current user");
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
    AppLogger.d("[USER] Getting user from Firestore");

    final docRef = _db.collection("users").doc(uid);
    await docRef.get().then((DocumentSnapshot doc) {
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
            {AppLogger.e("[USER] Error getting user from Firestore: $e", e)});

    // get local _prefs
    AppLogger.t("[USER] Getting local preferences");
    _user.allowCamera = _prefs.getBool('device_allow_camera') ?? false;
    _user.allowGallery = _prefs.getBool('device_allow_gallery') ?? false;

    AppLogger.i("[USER] User data obtained successfully");
  }

  /// Resets user data.
  ///
  /// Retains name and email.
  ///
  /// Does not delete user from FireStore.
  Future<void> resetUserData() async {
    AppLogger.d("[USER] resetting user data");
    _user.resetData();
    String uid = _user.uid;

    final docRef = _db.collection("users").doc(uid);

    final overwriteData = {
      "phoneNumber": null,
      "defaultLocation": null,
      "allowShareContact": false,
      "allowShareData": false,
      "hasOnboarded": false,
    };

    _prefs.setBool('device_allow_camera', false);
    _prefs.setBool('device_allow_gallery', false);

    docRef.set(overwriteData).onError((e, _) =>
        AppLogger.e("[USER] Error resetting user data in Firestore: $e", e));

    notifyListeners();
    AppLogger.i("[USER] User data reset successfully");
  }

  /// Checks firestore db if a document exists under the given uid.
  Future<bool> doesUserExist(String uid) async {
    AppLogger.t("[USER] Checking if user exists");
    final docRef = _db.collection("users").doc(uid);
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
    AppLogger.d("[USER] Deleting user");
    await _db.collection("users").doc(_user.uid).delete().then(
        (doc) => AppLogger.i("[USER] User deleted from Firestore"),
        onError: (e, _) =>
            AppLogger.e("[USER] Error deleting user from Firestore: $e", e));

    _user = AppUser.createEmptyUser();
  }

  /// Get user from user id by User's name, ignores current user's doc. Gets data from Firestore.
  ///
  /// Does nothing if there is an error.
  ///
  /// https://firebase.google.com/docs/firestore/query-data/get-data
  Future<List<AppUser>> getUsersFromDbByName(
      {required uid, required String email}) async {
    AppLogger.d("[USER] Getting users from Firestore");

    try {
      final querySnapshot =
          await _db.collection("users").where("email", isEqualTo: email).get();

      final List<AppUser> users = [];
      for (final docSnapshot in querySnapshot.docs) {
        final userData = docSnapshot.data();
        final user = AppUser.createFromJson(docSnapshot.id, userData);
        if (docSnapshot.id != uid) {
          users.add(user);
        }
      }
      AppLogger.i("[USER] Users fetched (by uid) successfully");
      return users;
    } catch (e) {
      AppLogger.e("[USER] Error fetching users for email $email: $e", e);
      return []; // Return an empty list on error
    }
  }

  /// Resets userService
  ///
  /// Sets current user to an empty user
  void resetService() {
    _user = AppUser.createEmptyUser();
  }
}
