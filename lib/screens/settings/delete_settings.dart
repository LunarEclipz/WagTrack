import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/services/auth.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/components/dialogs.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class DeletionSettings extends StatefulWidget {
  const DeletionSettings({super.key});

  @override
  State<DeletionSettings> createState() => _DeletionSettingsState();
}

class _DeletionSettingsState extends State<DeletionSettings> {
  /// Resets local preferences
  ///
  /// Sets all booleans to false
  void _resetDevicePreferences() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);

      userService.setParams(
        allowCamera: false,
        allowGallery: false,
      );

      userService.updateLocalPrefs();
    });
  }

  /// Resets user preferences
  ///
  /// Sets all booleans to false
  void _resetUserPreferences() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);

      userService.setParams(
        allowShareContact: false,
        allowShareData: false,
      );

      userService.updateUserInDb();
    });
  }

  /// Resets user data. Irreversible!
  ///
  /// Retains uid, name, and, email.
  ///
  /// Associated pets are not deleted.
  void _resetUserData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);

      userService.setParams(
        allowShareContact: false,
        allowShareData: false,
      );

      userService.updateUserInDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          // TODO: RENAME!
          // Might wanna move delete user data elsewhere honestly
          'Reset Settings',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: AppScrollablePage(children: [
          // SECTION: CAUTION
          Text(
            'Caution',
            style: textStyles.headlineMedium,
          ),
          const Text('The following actions are irreversible!'),
          const SizedBoxh10(),
          InkWell(
            onTap: () => showAppConfirmationDialog(
              context: context,
              titleString: 'Confirm?',
              contentString:
                  'Are you sure you want to reset device preferences?',
              continueAction: () => _resetDevicePreferences(),
            ),
            child: Container(
              width: 250,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Reset Device Preferences',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () => showAppConfirmationDialog(
              context: context,
              titleString: 'Confirm?',
              contentString: 'Are you sure you want to reset user preferences?',
              continueAction: () => _resetUserPreferences(),
            ),
            child: Container(
              width: 250,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Reset User Preferences',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () => showAppConfirmationDialog(
              context: context,
              titleString: 'Confirm?',
              contentString:
                  'Are you sure you want to reset user data? (your name and email will stil be associated with this account) \nWarning: this action is irreversible!',
              continueAction: () => _resetUserData(),
            ),
            child: Container(
              width: 250,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Delete User Data',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () => showAppConfirmationDialog(
              context: context,
              titleString: 'Confirm?',
              contentString:
                  'Are you sure you want to delete your account? \nWarning: this action is irreversible!',
              continueAction: () async {
                String? result =
                    await context.read<AuthenticationService>().deleteUser();
                if (result == 'requires-recent-login') {
                  showAppErrorAlertDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      titleString: 'Deletion Failed',
                      contentString:
                          'You are required to re-login to your account to perform this action.');
                } else {
                  // Success
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted!')),
                  );

                  Navigator.pushAndRemoveUntil(
                    // ignore: use_build_context_synchronously
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Authenticate()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
            ),
            child: Container(
              width: 250,
              height: 30,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBoxh10(),
        ]),
      ),
    );
  }
}
