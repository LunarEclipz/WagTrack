import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/services/auth.dart';

class LoginSocial extends StatefulWidget {
  const LoginSocial({super.key});

  @override
  State<LoginSocial> createState() => _LoginSocialState();
}

class _LoginSocialState extends State<LoginSocial> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text("or login with"),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () async {
                    debugPrint("DEBUG aaaa");
                    String? result = await context
                        .read<AuthenticationService>()
                        .signInWithGoogle();
                    // TODO
                    debugPrint('DEBUG $result');

                    if (result != "Success") {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(result!),
                            content: Text(result),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Try again'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Image.asset(
                      'assets/icons/google.png',
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Image.asset(
                  'assets/icons/facebook.png',
                  width: 40,
                  height: 40,
                ),
              ],
            )
          ],
        ));
  }
}
