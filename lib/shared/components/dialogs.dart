import 'package:flutter/material.dart';

/// App Error Alert Dialog for WagTrack with default settings
///
/// Creates an 'unknown error' dialog when string inputs are empty.
///
/// Default button to close dialog has text 'Try Again'
Future<void> showAppErrorAlertDialog(
    {required BuildContext context,
    String titleString = 'Unknown Error',
    String contentString = '',
    String closeDialogString = 'Try Again'}) {
  final TextTheme textStyles = Theme.of(context).textTheme;
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            titleString,
            style: textStyles.titleMedium!.copyWith(color: colorScheme.primary),
          ),
          content: Text(contentString),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(closeDialogString),
            ),
          ],
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        );
      });
}

/// App Confirmation Dialog for WagTrack with default settings
///
/// Default buttons are 'Cancel' and 'Continue'
///
/// Continue pops the confirmation dialog as well by default.
/// It will however, not pop the context of the underlying page. That has to be done
/// manually outside of this dialog.
Future<void> showAppConfirmationDialog(
    {required BuildContext context,
    String titleString = 'Confirmation',
    String contentString = '',
    String closeDialogString = 'Cancel',
    String continueString = 'Continue',
    Function? continueAction}) {
  final TextTheme textStyles = Theme.of(context).textTheme;
  final ColorScheme colorScheme = Theme.of(context).colorScheme;

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            titleString,
            style: textStyles.titleMedium!.copyWith(color: colorScheme.primary),
          ),
          content: Text(contentString),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(closeDialogString),
            ),
            TextButton(
              onPressed: () {
                continueAction!();
                Navigator.pop(context);
              },
              child: Text(continueString),
            ),
          ],
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
        );
      });
}
