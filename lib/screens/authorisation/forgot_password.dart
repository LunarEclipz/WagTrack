import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/shared/components/dialogs.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class ForgotPasswordPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
                'Please provide your Email Address and we will send you a reset password request. ',
                style: textStyles.bodyMedium
                    ?.copyWith(fontStyle: FontStyle.italic)),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),
            const SizedBoxh20(),
            ElevatedButton(
              onPressed: () async {
                String? result = await context
                    .read<AuthenticationService>()
                    .resetPassword(_emailController.text);

                // debugPrint('DEBUG: password reset: $result');

                if (result == "Success") {
                  // return to login
                  Navigator.pop(context);

                  showAppConfirmationDialog(
                    context: context,
                    titleString: 'Reset password email sent',
                    contentString: 'Please check your email.',
                    continueString: "Ok",
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title:
                            const Text('Reset password email cannot be sent'),
                        content: const Text('Invalid email or email not found'),
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
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all<Color>(colorScheme.primary),
              ),
              child: const Center(
                child: Text(
                  'Reset Password',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
