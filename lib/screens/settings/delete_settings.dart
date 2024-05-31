import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save personal info values
    await prefs.setBool('device_allow_camera', false);
    await prefs.setBool('device_allow_gallery', false);
  }

  /// Resets user preferences
  ///
  /// Sets all booleans to false
  void _resetUserPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save personal info values
    await prefs.setBool('user_allow_share_data', false);
    await prefs.setBool('user_allow_share_contact', false);
  }

  /// Deletes user data. Irreversible!
  ///
  /// WARNINGS?
  void _deleteUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Save personal info values
    await prefs.setString('user_name', '');
    await prefs.setString('user_email', '');
    await prefs.setString('user_phone_number', '');
    await prefs.setString('user_location', '');
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
                  'Are you sure you want to delete user data? \nWarning: this action is irreversible!',
              continueAction: () => _deleteUserData(),
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
        ]),
      ),
    );
  }
}
