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
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleString),
          content: Text(contentString),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(closeDialogString),
            ),
          ],
        );
      });
}

/// App Confirmation Dialog for WagTrack with default settings
///
/// Default buttons are 'Cancel' and 'Continue'
///
/// Continue pops the confirmation dialog as well by default.
Future<void> showAppConfirmationDialog(
    {required BuildContext context,
    String titleString = 'Confirmation',
    String contentString = '',
    String closeDialogString = 'Cancel',
    String continueString = 'Continue',
    Function? continueAction}) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titleString),
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
        );
      });
}
