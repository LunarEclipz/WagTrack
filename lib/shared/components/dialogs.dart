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
