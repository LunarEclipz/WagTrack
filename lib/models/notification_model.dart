import 'dart:convert';

import 'package:wagtrack/models/notification_enums.dart';
import 'package:wagtrack/services/logging.dart';

/// This is a class that wraps values used to represent a notification, that is
/// a notification that needs to be shown at a certain time.
///
/// For recurring notifications see `AppRecurringNotification`
class AppNotification {
  /// id of notification
  final int id;

  /// When the notification was created.
  final DateTime createdTime;

  /// When the notification is scheduled to be shown.
  final DateTime notificationTime;

  /// Title to be displayed in the notification.
  final String? title;

  /// Text to be displayed in the notification.
  final String? body;

  /// Type of the notification.
  final NotificationType type;

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

  static AppNotification get getEmptyNotification => _emptyNotification;

  /// Empty notification
  static final AppNotification _emptyNotification = AppNotification(
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

  @override
  bool operator ==(Object other) {
    return other is AppNotification &&
        id == other.id &&
        createdTime.compareTo(other.createdTime) == 0 &&
        notificationTime.compareTo(other.notificationTime) == 0 &&
        title == other.title &&
        body == other.body &&
        type == other.type;
  }

  @override
  int get hashCode => Object.hash(
        id,
        createdTime,
        notificationTime,
        title,
        body,
        type,
      );
}

/// This represents a recurring notification
///
/// Doesn't store the creation time
class AppRecurringNotification {
  /// id of notification
  final int id;

  /// When the notification is meant to start.
  ///
  /// For now this is kind of meaningless as the notification has to start
  /// showing now.
  DateTime startTime;

  /// the interval of the between which a new notification will be created
  final Duration interval;

  /// Title to be displayed in the notification.
  final String? title;

  /// Text to be displayed in the notification.
  final String? body;

  /// Type of the notification.
  final NotificationType type;

  /// Id of the object that is associated with this recurring notification. That
  /// type of object is determined by the `type` of this notification.
  ///
  /// For instance, a `NotificationType.medication` means its the id of the
  /// associated medication.
  final String? oid;

  /// whether this notification is currently showing.
  bool isActive;

  AppRecurringNotification({
    required this.id,
    required this.startTime,
    required this.interval,
    this.title,
    this.body,
    this.type = NotificationType.noType,
    this.oid,
    this.isActive = false,
  });

  /// Whether this is the empty notification.
  bool get isEmpty => id == -1;

  static AppRecurringNotification get getEmptyNotification =>
      _emptyNotification;

  /// Empty notification
  static final AppRecurringNotification _emptyNotification =
      AppRecurringNotification(
    id: -1,
    startTime: DateTime.fromMillisecondsSinceEpoch(0),
    interval: const Duration(days: 1),
  );

  /// creates an `AppRecurringNotification` object from an encoded Json string.
  ///
  /// Returns an empty notification object if error.
  static AppRecurringNotification fromJSONString(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;

      // first handle the type
      final type = NotificationType.fromString(data["type"]);

      // create the notification and return
      return AppRecurringNotification(
        id: data["id"],
        // DateTimes are stored as ISO8601 Strings
        // Duration is stored in seconds
        startTime: DateTime.parse(data["startTime"]),
        interval: Duration(seconds: data["intervalSeconds"]),
        title: data["title"],
        body: data["body"],
        type: type,
        oid: data["oid"],
        isActive: data["isActive"],
      );
    } on Exception catch (e) {
      AppLogger.w(
          "[NOTIF] Couldn't create AppRecurringNotification object from json string: $e",
          e);
    }

    // returns empty Application
    return _emptyNotification;
  }

  /// Converts this `AppRecurringNotification` object into an encoded Json string
  ///
  /// Returns an empty string if error.
  String toJSONString() {
    try {
      final data = {
        "id": id,
        // DateTimes are stored as ISO8601 Strings
        "startTime": startTime.toIso8601String(),
        "intervalSeconds": interval.inSeconds,
        "title": title,
        "body": body,
        // NotificationType needs to be converted to the string
        "type": type.string,
        "oid": oid,
        "isActive": isActive,
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
      return "AppRecurringNotification[Empty]";
    }
    return "AppRecurringNotification[id: $id]";
  }

  @override
  bool operator ==(Object other) {
    return other is AppRecurringNotification &&
        id == other.id &&
        startTime.compareTo(other.startTime) == 0 &&
        interval.compareTo(other.interval) == 0 &&
        title == other.title &&
        body == other.body &&
        type == other.type &&
        oid == other.oid;
  }

  @override
  int get hashCode => Object.hash(
        id,
        startTime,
        interval,
        title,
        body,
        type,
        oid,
      );
}
