import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/screens/authorisation/authorisation_frame.dart';
import 'package:wagtrack/screens/home/home.dart';
import 'package:wagtrack/screens/settings/onboarding.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;
  bool hasUserOnboarded = false;

  void toggleView() {
    setState(() {
      showSignIn = !showSignIn;
    });
  }

  /// Checks for onboarding status
  Future<bool> _checkUserOnboarded() async {
    // local data for now
    SharedPreferences prefs = await SharedPreferences.getInstance();
    hasUserOnboarded = prefs.getBool('user_has_onboarded') ?? false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    _checkUserOnboarded();
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
              // not currently shown
              body: Center(child: CircularProgressIndicator()));
        } else {
          return FutureBuilder(
              future: _checkUserOnboarded(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                debugPrint('DEBUG: $snapshot.hasData');
                if (snapshot.hasData) {
                  if (!hasUserOnboarded) {
                    // Onboarding screen if not yet onboarded
                    return const OnboardingScreen();
                  }
                  // Home Screen if Onboarded
                  return const Home();
                } else {
                  return const Scaffold(
                      body: Center(child: CircularProgressIndicator()));
                }
              });
        }
      },
    );
  }
}
