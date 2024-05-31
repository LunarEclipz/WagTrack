// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

// import '../models/user.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  // auth change user stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Signs into current Firebase Auth instance with email and password.
  ///
  /// https://pub.dev/documentation/firebase_auth/latest/firebase_auth/FirebaseAuth/signInWithEmailAndPassword.html
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

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

      final String userId = userCredential.user!.uid;

      // await addUser(TreknTrackUser(
      //   id: userId,
      //   name: name,
      //   email: email,
      //   followers: [],
      //   following: [],
      //   journeysID: [],
      //   sightingsID: [],
      // ));

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

        return "Success";
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("[AUTH_ERROR] $e");
      return '${e.code}:  \n ${e.message}';
    }
  }

  //sign out user
  Future<void> signOutUser() async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      await FirebaseAuth.instance.signOut();
    }
  }

  // Future<void> addUser(TreknTrackUser user) async {
  //   var db = await Db.create(
  //       'mongodb+srv://zyonwee:Qwerty123@cluster0.5z7a9.mongodb.net/TrekNTrack?retryWrites=true&w=majority');
  //   await db.open();
  //   var collection = db.collection('users');
  //   await collection.insert(user.toMap());
  //   await db.close();
  // }
}
