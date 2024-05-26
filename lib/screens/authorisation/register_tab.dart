import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/login_social_account.dart';
import 'package:wagtrack/services/auth.dart';

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
  bool _isUsernameValid = true;
  bool _isEmailValid = true;
  bool _isPasswordTooShort = true;
  bool _isConfirmPasswordTooShort = true;
  bool _obscureTextPassword = true;
  bool _obscureTextConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                errorText: _isUsernameValid ? null : 'Invalid username',
                hintText: 'Enter your username',
              ),
              onChanged: (value) {
                setState(() {
                  if (usernameController.text.isEmpty) {
                    _isUsernameValid = false;
                  } else {
                    _isUsernameValid = true;
                  }
                });
              },
            ),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email Address',
                errorText: _isEmailValid ? null : 'Invalid email',
                hintText: 'Enter your email address',
              ),
              onChanged: (value) {
                setState(() {
                  _isEmailValid = context
                      .read<AuthenticationService>()
                      .isEmailValidEmail(emailController.text);
                });
              },
            ),
            TextFormField(
              controller: passwordController,
              obscureText: _obscureTextPassword,
              decoration: InputDecoration(
                labelText: 'Password',
                errorText:
                    _isPasswordTooShort ? null : 'Enter more than 6 characters',
                hintText: 'Enter your password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureTextPassword = !_obscureTextPassword;
                    });
                  },
                  icon: Icon(
                    _obscureTextPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (passwordController.text.length < 6) {
                    _isPasswordTooShort = false;
                  } else {
                    _isPasswordTooShort = true;
                  }
                });
              },
            ),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: _obscureTextConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                errorText: _isConfirmPasswordTooShort
                    ? null
                    : 'Enter more than 6 characters',
                hintText: 'Enter to confirm your password',
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscureTextConfirmPassword =
                          !_obscureTextConfirmPassword;
                    });
                  },
                  icon: Icon(
                    _obscureTextConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    // color: colorScheme.tertiary,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  if (confirmPasswordController.text.length < 6) {
                    _isConfirmPasswordTooShort = false;
                  } else {
                    _isConfirmPasswordTooShort = true;
                  }
                });
              },
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
