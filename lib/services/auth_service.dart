// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wagtrack/models/user_model.dart';
import 'package:wagtrack/services/user_service.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth;
  final UserService _userService;

  AuthenticationService(this._firebaseAuth, this._userService);
  // AuthenticationService(this._firebaseAuth);

  // auth change user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs into current Firebase Auth instance with email and password.
  ///
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      // final String userId = userCredential.user!.uid;

      // // Add user data to local storage (for now)
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // // await prefs.setString('user_name', name);
      // await prefs.setString('user_email', email);
      // await prefs.setString('uid', userId);

      await checkAndCreateUser(userCredential: userCredential);

      return "Success";
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH_ERROR] Code: ${e.code}');
      debugPrint('[AUTH_ERROR] Message: ${e.message}');
      return e.code;
    }
  }

  /// Send password reset emails to provided email.
  ///
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/sendPasswordResetEmail.html
  Future<String?> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      // Password reset email sent
      return "Success";
    } on FirebaseAuthException catch (e) {
      debugPrint('[AUTH_ERROR] Code: ${e.code}');
      debugPrint('[AUTH_ERROR] Message: ${e.message}');
      return e.code;
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

      return "Success";
    } on FirebaseAuthException catch (e) {
      // e.code == 'invalid-email'
      // e.code == 'weak-password'
      // e.code == 'email-already-in-use'
      debugPrint('[AUTH_ERROR] Code: ${e.code}');
      debugPrint('[AUTH_ERROR] Message: ${e.message}');

      return e.code;
    }
  }

  //Google auths
  Future<dynamic> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

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

      return "Success";
    } on FirebaseAuthException catch (e) {
      debugPrint("[AUTH_ERROR] $e");
      return '${e.code}:  \n ${e.message}';
    }
  }

  Future<dynamic> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(result.accessToken!.tokenString);
        // ^ I think????

        final UserCredential userCredential =
            await _firebaseAuth.signInWithCredential(facebookAuthCredential);

        await checkAndCreateUser(userCredential: userCredential);

        return "Success";
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("[AUTH_ERROR] $e");
      return '${e.code}:  \n ${e.message}';
    }
  }

  /// Checks if uid exists in db and creates new user if it doesn't exist.
  /// Then creates new local user.
  ///
  /// if `name` is empty, will check the Firebase user instance and Firestore
  /// for a display name.
  Future<void> checkAndCreateUser(
      {required UserCredential userCredential, String name = ""}) async {
    if (name.isEmpty) {
      name = userCredential.user!.displayName ?? "";
    }

    String uid = userCredential.user!.uid;
    String? email = userCredential.user!.email;

    // check if uid exists in firestore
    // create user; if user created is blank, then does not exis
    await _userService.getUserFromDb(uid: uid);

    if (_userService.user.isEmpty()) {
      // user does not exist - create initial user for onboarding process
      _userService.setUser(
          user: AppUser.createInitialUser(uid: uid, name: name, email: email!));
      return;
    }
  }

  /// TODO: Update user email in FirebaseAuth

  /// Sign out user
  Future<void> signOutUser() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  /// Delete user account from Firebase Auth and Firestore.
  Future<dynamic> deleteUser() async {
    await _userService.deleteUser();

    try {
      final User? firebaseUser = FirebaseAuth.instance.currentUser;

      await firebaseUser!.delete();

      return "Success";
    } on FirebaseAuthException catch (e) {
      // e.code == 'requires-recent-login'
      debugPrint('[AUTH_ERROR] Code: ${e.code}');
      debugPrint('[AUTH_ERROR] Message: ${e.message}');

      return e.code;
    }
  }
}
