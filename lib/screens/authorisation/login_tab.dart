import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/forgot_password.dart';
import 'package:wagtrack/services/auth.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({Key? key}) : super(key: key);

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  // bool _rememberMeIsChecked = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // final CustomColors customColors =
    //     Theme.of(context).extension<CustomColors>()!;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter your email address',
              ),
            ),
            TextFormField(
              obscureText: _obscureText,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    // color: colorScheme.tertiary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    // Handle forgot password tap
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Forgot Password?',
                    style: textStyles.bodyLarge
                        ?.copyWith(color: colorScheme.tertiary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () async {
                String? result = await context
                    .read<AuthenticationService>()
                    .signInWithEmailAndPassword(
                      emailController.text,
                      passwordController.text,
                    );
                if (result == 'invalid-email') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Login Failed'),
                        content: const Text('Invalid email , user not found'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Try again'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (result == 'wrong-password') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Login Failed'),
                        content: const Text('Invalid password'),
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
              child: Container(
                width: 300,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                const Text("or login with"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icons/google.png',
                      width: 40,
                      height: 40,
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
            ),
            // const SizedBox(height: 40),
            // SvgPicture.asset(
            //   'assets/icons/trekntrek.svg',
            //   width: 90,
            //   height: 90,
            // )
          ],
        ),
      ),
    );
  }
}
