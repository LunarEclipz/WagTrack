import 'dart:convert';

import 'package:wagtrack/services/logging.dart';

class AppNotification {
  // id of notification
  int id;

  // When the notification was created.
  DateTime createdTime;

  // When the notification is scheduled to be shown.
  DateTime notificationTime;

  // Title to be displayed in the notification.
  String? title;

  // Text to be displayed in the notification.
  String? body;

  // Type of the notification.
  String? type;

  AppNotification({
    required this.id,
    required this.createdTime,
    required this.notificationTime,
    this.title,
    this.body,
    this.type,
  });

  // Whether this is the empty notification.
  bool get isEmpty => id == -1;

  // Empty notification
  static final _emptyNotification = AppNotification(
    id: -1,
    createdTime: DateTime.fromMillisecondsSinceEpoch(0),
    notificationTime: DateTime.fromMillisecondsSinceEpoch(0),
  );

  /// creates an `AppNotification` object from an encoded Json string.
  ///
  /// Returns an empty notification object if error.
  static AppNotification fromJSONString(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;

      return AppNotification(
        id: data["id"],
        createdTime: data["createdTime"],
        notificationTime: data["notificationTime"],
        title: data["title"],
        body: data["body"],
        type: data["type"],
      );
    } on Exception catch (e) {
      AppLogger.w(
          "Couldn't create AppNotification object from json string: $e");
    }

    // returns empty Application
    return _emptyNotification;
  }

  /// Converts this `AppNotification` object into an encoded Json string
  ///
  /// Returns an empty string if error.
  String toJSONString() {
    try {
      final data = {
        "id": id,
        "createdTime": createdTime,
        "notificationTime": notificationTime,
        "title": title,
        "body": body,
        "type": type,
      };

      return jsonEncode(data);
    } on Exception catch (e) {
      AppLogger.w("Couldn't convert AppNotification object to json string: $e");
    }

    // return empty string if errors.
    return "";
  }

  @override
  String toString() {
    if (isEmpty) {
      return "AppNotification[Empty]";
    }
    return "AppNotification[id: $id]";
  }
}
