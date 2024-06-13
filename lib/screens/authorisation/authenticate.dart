import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/screens/app_wrapper.dart';
import 'package:wagtrack/screens/authorisation/authorisation_frame.dart';
import 'package:wagtrack/screens/settings/onboarding.dart';
import 'package:wagtrack/services/user_service.dart';

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
          // no longer need all these but keeping anyway :D

          // return FutureBuilder(
          //     future: _checkUserOnboarded(),
          //     builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          //       debugPrint(
          //           'DEBUG: Authentication: $snapshot.hasData; $hasUserOnboarded');
          //       if (snapshot.hasData) {
          //         if (!hasUserOnboarded) {
          //           // Onboarding screen if not yet onboarded
          //           return const OnboardingScreen();
          //         }
          //
          //       } else {
          //         return const Scaffold(
          //             body: Center(child: CircularProgressIndicator()));
          //       }
          //     });

          // loading complete - now check for onboarding status

          if (context.watch<UserService>().user.hasOnboarded) {
            // Home Screen if Onboarded
            return const AppWrapper();
          }

          // Onboarding screen if not yet onboarded
          return const OnboardingScreen();
        }
      },
    );
  }
}
