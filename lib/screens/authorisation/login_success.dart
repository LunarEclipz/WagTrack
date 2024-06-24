import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// temporary page to allow for logging out after a successful login
class LoginSuccess extends StatefulWidget {
  const LoginSuccess({super.key});

  @override
  State<LoginSuccess> createState() => _LoginSuccessState();
}

class _LoginSuccessState extends State<LoginSuccess> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
        body: Center(
            child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Signed In as"),
          const SizedBox(height: 8),
          Text(user.email!),
          // const Text("Signed In"),
          const SizedBox(height: 40),
          InkWell(
            onTap: () => FirebaseAuth.instance.signOut(),
            child: Container(
              width: 300,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Log Out',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    )));
  }
}
