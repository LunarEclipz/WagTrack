import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/forgot_password.dart';
import 'package:wagtrack/screens/authorisation/login_social_account.dart';
import 'package:wagtrack/services/auth.dart';
import 'package:wagtrack/shared/components/dialogs.dart';
import 'package:wagtrack/shared/components/input_components.dart';

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // Form key for login form
  final _loginFormKey = GlobalKey<FormState>();

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
            Form(
              key: _loginFormKey,
              child: Column(
                children: <Widget>[
                  AppTextFormFieldLarge(
                    labelText: 'Email Address',
                    controller: emailController,
                    validator: (value) => !context
                            .read<AuthenticationService>()
                            .isEmailValidEmail(value!)
                        ? 'Invalid email'
                        : null,
                  ),
                  AppTextFormFieldLarge(
                    labelText: 'Password',
                    controller: passwordController,
                    isObscurable: true,
                  ),
                ],
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
                // first validate
                if (!_loginFormKey.currentState!.validate()) {
                  // if it doesn't validate, returns and doesn't send to API
                  return;
                }

                // sign in with API
                String? result = await context
                    .read<AuthenticationService>()
                    .signInWithEmailAndPassword(
                      emailController.text,
                      passwordController.text,
                    );
                // debugPrint('DEBUG $result');
                if (result == 'invalid-email') {
                  // This shouldn't show up because invalid emails are pre-validated.
                  // But still, in case I guess.
                  showAppErrorAlertDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      titleString: 'Login Failed',
                      contentString: 'Invalid email.');
                } else if (result == 'invalid-credential') {
                  // Since FirebaseAuth throws a 'channel-error' in such situations.
                  showAppErrorAlertDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      titleString: 'Login Failed',
                      contentString: 'Incorrect email or password.');
                } else if (result == 'network-request-failed') {
                  showAppErrorAlertDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      titleString: 'Login Failed',
                      contentString:
                          'Network error. Please check your internet connection.');
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
            const LoginSocial(),
          ],
        ),
      ),
    );
  }
}
