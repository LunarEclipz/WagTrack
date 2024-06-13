import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/models/user_model.dart';

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
    if (_user.isEmpty()) {
      // user does not exist
      debugPrint("[INFO]: User, DB: Local user does not exist");
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
    } catch (e) {
      debugPrint("[ERROR]: User, DB: $e");
    }
  }

  /// Updates local preferences.
  Future<void> updateLocalPrefs() async {
    if (_user.isEmpty()) {
      // user does not exist
      debugPrint("[INFO]: User, DB: Local user does not exist");
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
    } catch (e) {
      debugPrint("[ERROR]: User, DB: $e");
    }
  }

  /// Sets current user from an `AppUser` object.
  void setUser({required AppUser user}) {
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
            {debugPrint("[ERROR]: User, DB: Error getting document: $e")});

    // get local prefs
    SharedPreferences.getInstance().then((prefs) {
      _user.allowCamera = prefs.getBool('device_allow_camera') ?? false;
      _user.allowGallery = prefs.getBool('device_allow_gallery') ?? false;
    });
  }

  /// Resets user data.
  ///
  /// Retains name and email.
  ///
  /// Does not delete user from FireStore.
  Future<void> resetUserData() async {
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
        (e, _) => debugPrint("[ERROR]: User, DB: Error overwriting data: $e"));

    notifyListeners();
  }

  /// Checks firestore db if a document exists under the given uid.
  Future<bool> doesUserExist(String uid) async {
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
    await db.collection("users").doc(_user.uid).delete().then(
        (doc) => debugPrint("[INFO]: User $_user.uid deleted from Firestore."),
        onError: (e, _) =>
            debugPrint("[ERROR]: User, DB: Error deleting user: $e"));

    _user = AppUser.createEmptyUser();
  }
}
