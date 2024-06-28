import 'dart:convert';

import 'package:wagtrack/models/notification_params.dart';
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
  NotificationType type;

  AppNotification({
    required this.id,
    required this.createdTime,
    required this.notificationTime,
    this.title,
    this.body,
    this.type = NotificationType.noType,
  });

  /// Whether this is the empty notification.
  bool get isEmpty => id == -1;

  /// Whether this notification is a future notification, i.e. whether the time
  /// scheduled for it to be notified is in the future
  bool get isFutureNotification =>
      DateTime.now().compareTo(notificationTime) < 0;

  /// Empty notification
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

      // first handle the type
      final type = NotificationType.fromString(data["type"]);

      // create the notification and return
      return AppNotification(
        id: data["id"],
        // DateTimes are stored as ISO8601 Strings
        createdTime: DateTime.parse(data["createdTime"]),
        notificationTime: DateTime.parse(data["notificationTime"]),
        title: data["title"],
        body: data["body"],
        type: type,
      );
    } on Exception catch (e) {
      AppLogger.w(
          "[NOTIF] Couldn't create AppNotification object from json string: $e",
          e);
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
        // DateTimes are stored as ISO8601 Strings
        "createdTime": createdTime.toIso8601String(),
        "notificationTime": notificationTime.toIso8601String(),
        "title": title,
        "body": body,
        // NotificationType needs to be converted to the string
        "type": type.string,
      };

      return jsonEncode(data);
    } on Exception catch (e) {
      AppLogger.w("[NOTIF] Couldn't convert $toString() to json string: $e", e);
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
