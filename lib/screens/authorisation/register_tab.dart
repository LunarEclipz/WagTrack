import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/login_social_account.dart';
import 'package:wagtrack/services/auth.dart';
import 'package:wagtrack/shared/components/dialogs.dart';
import 'package:wagtrack/shared/components/input_components.dart';

class RegisterTab extends StatefulWidget {
  const RegisterTab({super.key});

  @override
  State<RegisterTab> createState() => _RegisterTabState();
}

class _RegisterTabState extends State<RegisterTab> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  // Form key for login form
  final _registerFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        child: Column(
          children: <Widget>[
            Form(
              key: _registerFormKey,
              child: Column(
                children: <Widget>[
                  AppTextFormFieldLarge(
                    controller: usernameController,
                    labelText: 'Username',
                    validator: (value) =>
                        value!.isEmpty ? 'Invalid username' : null,
                  ),
                  AppTextFormFieldLarge(
                    controller: emailController,
                    labelText: 'Email Address',
                    validator: (value) => !context
                            .read<AuthenticationService>()
                            .isEmailValidEmail(value!)
                        ? 'Invalid email'
                        : null,
                  ),
                  AppTextFormFieldLarge(
                    controller: passwordController,
                    labelText: 'Password',
                    isObscurable: true,
                    validator: (value) =>
                        value!.length < 6 ? 'Minimum of 6 characters' : null,
                  ),
                  AppTextFormFieldLarge(
                    controller: confirmPasswordController,
                    labelText: 'Confirm Password',
                    isObscurable: true,
                    validator: (value) {
                      if (confirmPasswordController.text !=
                          passwordController.text) {
                        // checks for similarity before length

                        return 'Passwords not the same';
                      } else if (value!.length < 6) {
                        return 'Minimum of 6 characters';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () async {
                // first validate
                if (!_registerFormKey.currentState!.validate()) {
                  // if it doesn't validate, returns and doesn't send to API
                  return;
                }

                // sign in with API???
                // fix the code after this pleeeassee

                // email can be checked from verification , so skip

                if (3 < 2) {
                  // TODO: FIX
                  // check username
                } else if (context
                    .read<AuthenticationService>()
                    .passwordDontMatchConfirmPassword(passwordController.text,
                        confirmPasswordController.text)) {
                  // check password != confirmPassword
                  showAppErrorAlertDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      titleString: 'Registration Failed',
                      contentString:
                          'Passwords not the same. Please re-enter password.');
                } else {
                  //after username and password checks, register the user
                  String? result = await context
                      .read<AuthenticationService>()
                      .registerWithEmailAndPassword(
                        usernameController.text,
                        emailController.text,
                        passwordController.text,
                      );

                  if (result == 'invalid-email') {
                    showAppErrorAlertDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        titleString: 'Registration Failed',
                        contentString: 'Invalid email.');
                  } else if (result == 'email-already-in-use') {
                    showAppErrorAlertDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        titleString: 'Registration Failed',
                        contentString:
                            'An account already exists for that email.');
                  } else if (result == 'weak-password') {
                    showAppErrorAlertDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        titleString: 'Registration Failed',
                        contentString: 'Password is too short.');
                  } else if (result == 'network-request-failed') {
                    showAppErrorAlertDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        titleString: 'Registration Failed',
                        contentString:
                            'Network error. Please check your internet connection.');
                  } else {
                    showAppErrorAlertDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        titleString: 'Registration Failed',
                        contentString: 'Please check your inputs.');
                  }
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
                    'Register',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const LoginSocial(),
            // const SizedBox(height: 40),
            // SvgPicture.asset(
            //   'assets/images/trekntrek.svg',
            //   width: 90,
            //   height: 90,
            // )
          ],
        ),
      ),
    );
  }
}
