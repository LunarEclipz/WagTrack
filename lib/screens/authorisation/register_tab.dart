import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/login_social_account.dart';
import 'package:wagtrack/services/auth.dart';
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
  final bool _isUsernameValid = true;
  final bool _isEmailValid = true;
  final bool _isPasswordTooShort = true;
  final bool _isConfirmPasswordTooShort = true;
  final bool _obscureTextPassword = true;
  final bool _obscureTextConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    // final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        child: Column(
          children: <Widget>[
            AppTextFormField(
              controller: usernameController,
              labelText: 'Username',
              validator: (value) => value!.isEmpty ? 'Invalid username' : null,
            ),
            AppTextFormField(
              controller: emailController,
              labelText: 'Email Address',
              validator: (value) => !context
                      .read<AuthenticationService>()
                      .isEmailValidEmail(value!)
                  ? 'Invalid email'
                  : null,
            ),
            AppTextFormField(
              controller: passwordController,
              labelText: 'Password',
              isObscurable: true,
              validator: (value) =>
                  value!.length < 6 ? 'Minimum of 6 characters' : null,
            ),
            AppTextFormField(
              controller: confirmPasswordController,
              labelText: 'Confirm Password',
              isObscurable: true,
              validator: (value) =>
                  value!.length < 6 ? 'Minimum of 6 characters' : null,
            ),
            const SizedBox(height: 16.0),
            InkWell(
              onTap: () async {
                // email can be checked from verification , so skip

                if (3 < 2) {
                  // check username
                } else if (context
                    .read<AuthenticationService>()
                    .passwordDontMatchConfirmPassword(passwordController.text,
                        confirmPasswordController.text)) {
                  // check password != confirmPassword
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            const Text('Re-enter password or confirm password'),
                        content:
                            const Text('Password not same as confirm password'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Try again'),
                          ),
                        ],
                      );
                    },
                  );
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Registration Failed'),
                          content: const Text('Invalid email.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Try again'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (result == 'email-already-in-use') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Registration Failed'),
                          content: const Text(
                              'The account already exists for that email.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Try again'),
                            ),
                          ],
                        );
                      },
                    );
                  } else if (result == 'weak-password') {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Registration Failed'),
                          content: const Text('Password is too short'),
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
