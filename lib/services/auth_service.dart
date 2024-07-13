// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/user_service.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = GetIt.I<FirebaseAuth>();
  final UserService _userService;
  final GoogleSignIn _googleSignIn = GetIt.I<GoogleSignIn>();
  final FacebookAuth _facebookAuth = GetIt.I<FacebookAuth>();

  AuthenticationService(this._userService);
  // AuthenticationService(this._firebaseAuth);

  // Get Auth change user stream.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Get uid of current user.
  String get uid => _firebaseAuth.currentUser!.uid;

  /// Updates local user based on current uid
  ///
  /// Does nothing if uid is not available.
  ///
  /// returns whether the user has onboarded.
  Future<bool> updateCurrentLocalUserFromAuth() async {
    AppLogger.d("[AUTH] Updating local user from Firebase Auth");
    String? uid = this.uid;

    AppLogger.t(uid);

    if (uid.isEmpty) {
      AppLogger.i("[AUTH] Local auth user does not exist");
      return false;
    }

    await _userService.getUserFromDb(uid: uid);

    final user = _userService.user;
    // AppLogger.i("$user");

    AppLogger.i("[AUTH] Local user updated successfully.");
    return user.hasOnboarded;
  }

  /// Signs into current Firebase Auth instance with email and password.
  ///
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    AppLogger.d("[AUTH] Signing in with email and password");
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      await checkAndCreateUser(userCredential: userCredential);

      AppLogger.i("[AUTH] Sign in successful");

      return "Success";
    } on FirebaseAuthException catch (e) {
      AppLogger.i("[AUTH] Sign in FirebaseAuthException $e.code", e);
      return e.code;
    } on Exception catch (e, stackTrace) {
      AppLogger.e("[AUTH] Sign in: non-FirebaseAuth exception", e, stackTrace);
      return null;
    }
  }

  /// Send password reset emails to provided email.
  ///
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/sendPasswordResetEmail.html
  Future<String?> resetPassword(String email) async {
    AppLogger.d("[AUTH] Sending password reset email");

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      // Password reset email sent

      AppLogger.i("[AUTH] Password reset email sent successfully");

      return "Success";
    } on FirebaseAuthException catch (e) {
      AppLogger.i("[AUTH] Password reset FirebaseAuthException $e.code", e);
      return e.code;
    } on Exception catch (e, stackTrace) {
      AppLogger.e("[AUTH] reset pw: non-FirebaseAuth exception", e, stackTrace);
      return null;
    }
  }

  /// Uses regex to check if provided string is a valid email address.
  bool isEmailValidEmail(String email) {
    return RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email);
  }

  bool passwordDontMatchConfirmPassword(
      String password, String confirmPassword) {
    return password != confirmPassword;
  }

  /// Registers with provided email and password.
  ///
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/createUserWithEmailAndPassword.html
  Future<String?> registerWithEmailAndPassword(
      String name, String email, String password) async {
    AppLogger.d("[AUTH] Registering with email and password");

    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // final String userId = userCredential.user!.uid;

      // Add user data to local storage (for now)
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('user_name', name);
      // await prefs.setString('user_email', email);
      // await prefs.setString('uid', userId);

      await checkAndCreateUser(userCredential: userCredential, name: name);

      AppLogger.i("[AUTH] Registration successful");

      return "Success";
    } on FirebaseAuthException catch (e) {
      // e.code == 'invalid-email'
      // e.code == 'weak-password'
      // e.code == 'email-already-in-use'
      AppLogger.i("[AUTH] Registration FirebaseAuthException $e.code", e);

      return e.code;
    } on Exception catch (e, stackTrace) {
      AppLogger.e("[AUTH] register: non-FirebaseAuth exception", e, stackTrace);
      return null;
    }
  }

  //Google auths
  Future<dynamic> signInWithGoogle() async {
    AppLogger.d("[AUTH] Signing in with Google");

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      await checkAndCreateUser(userCredential: userCredential);

      AppLogger.i("[AUTH] Google sign in successful");

      return "Success";
    } on FirebaseAuthException catch (e) {
      AppLogger.i("[AUTH] Google sign in FirebaseAuthException $e.code", e);
      return '${e.code}:  \n ${e.message}';
    } on Exception catch (e, stackTrace) {
      AppLogger.e(
          "[AUTH] Google signin: non-FirebaseAuth exception", e, stackTrace);
    }
  }

  Future<dynamic> signInWithFacebook() async {
    AppLogger.d("[AUTH] Signing in with Facebook");
    try {
      // Trigger the sign-in flow
      final LoginResult result = await _facebookAuth.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        // ^ I think????

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(facebookAuthCredential);

        await checkAndCreateUser(userCredential: userCredential);

        AppLogger.i("[AUTH] Facebook sign in successful");

        return "Success";
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.i("[AUTH] Facebook sign in FirebaseAuthException $e.code", e);
      return '${e.code}:  \n ${e.message}';
    } on Exception catch (e, stackTrace) {
      AppLogger.e(
          "[AUTH] FB signin: non-FirebaseAuth exception", e, stackTrace);
    }
  }

  /// Checks if uid exists in db and creates new user if it doesn't exist.
  /// Then creates new local user.
  ///
  /// if `name` is empty, will check the Firebase user instance and Firestore
  /// for a display name.
  Future<void> checkAndCreateUser(
      {required UserCredential userCredential, String name = ""}) async {
    AppLogger.d("[AUTH] Checking user against Firestore db");

    if (name.isEmpty) {
      name = userCredential.user!.displayName ?? "";
    }

    String uid = userCredential.user!.uid;
    String? email = userCredential.user!.email;

    // check if uid exists in firestore
    // create user; if user created is blank, then does not exis
    await _userService.getUserFromDb(uid: uid);

    if (_userService.user.isEmpty()) {
      AppLogger.i("[AUTH] User does not exist in Firestore");
      // user does not exist - create initial user for onboarding process
      _userService.setUser(
          user: AppUser.createInitialUser(
              uid: uid, name: name, email: email ?? ''));
      return;
    }
  }

  /// TODO: Add option to update user email in FirebaseAuth

  /// Sign out user
  Future<void> signOutUser() async {
    AppLogger.d("[AUTH] Signing out user");
    try {
      final User? firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser != null) {
        // signout from FBA
        await _firebaseAuth.signOut();
      }
      AppLogger.i("[AUTH] User sign out successful");
    } on FirebaseAuthException catch (e) {
      AppLogger.i("[AUTH] Sign out FirebaseAuthException $e.code", e);
    } on Exception catch (e, stackTrace) {
      AppLogger.e("[AUTH] Sign out: non-FirebaseAuth exception", e, stackTrace);
    }
  }

  /// Delete user account from Firebase Auth and Firestore.
  Future<dynamic> deleteUser() async {
    AppLogger.d("[AUTH] Deleting user");
    await _userService.deleteUser();

    try {
      final User? firebaseUser = _firebaseAuth.currentUser;

      await firebaseUser!.delete();
      AppLogger.i("[AUTH] User deletion successful");

      return "Success";
    } on FirebaseAuthException catch (e) {
      // e.code == 'requires-recent-login'
      AppLogger.i("[AUTH] User delete FirebaseAuthException $e.code", e);

      return e.code;
    } on Exception catch (e, stackTrace) {
      AppLogger.e(
          "[AUTH] user delete: non-FirebaseAuth exception", e, stackTrace);
    }
  }
}
