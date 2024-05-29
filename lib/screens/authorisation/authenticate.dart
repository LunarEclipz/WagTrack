import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wagtrack/screens/authorisation/authorisation_frame.dart';
import 'package:wagtrack/screens/authorisation/login_success.dart';
// import 'package:wagtrack/screens/mainTemplate.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    // final firebaseUser = context.watch<User?>();
    // if (firebaseUser == null) {
    //   return LoginPage(toggleView: toggleView);
    // } else {
    //   // return const mainTemplate();
    //   // return Container();
    //   return const LoginSuccess();
    // }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginPage(toggleView: toggleView);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          return const LoginSuccess();
        }
      },
    );
  }
}
