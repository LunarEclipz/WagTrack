import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/app_wrapper.dart';
import 'package:wagtrack/screens/authorisation/authorisation_frame.dart';
import 'package:wagtrack/screens/misc_pages.dart';
import 'package:wagtrack/screens/settings/onboarding.dart';
import 'package:wagtrack/services/auth_service.dart';

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

  // @override
  // void initState() {
  //   super.initState();
  //   // _checkUserOnboarded();
  // }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoginPage(toggleView: toggleView);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        } else {
          // loading complete - now check for onboarding status

          return FutureBuilder<bool>(
              // future: _checkUserOnboarded(context),
              future: Provider.of<AuthenticationService>(context, listen: false)
                  .updateCurrentLocalUserFromAuth(),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  // final temp = snapshot.data;
                  // AppLogger.i("HAS USER ONBOARDED [2]: $temp");
                  if (!snapshot.data!) {
                    // Onboarding screen if not yet onboarded
                    return const OnboardingScreen();
                  } else {
                    // Has onboarded:
                    return const AppWrapper();
                  }
                } else {
                  return const LoadingPage();
                }
              });

          // if (context.watch<UserService>().user.hasOnboarded) {
          //   // Home Screen if Onboarded
          //   return const AppWrapper();
          // }

          // // Onboarding screen if not yet onboarded
          // return const OnboardingScreen();
        }
      },
    );
  }
}
