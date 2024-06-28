/// Type of notifications.
///
/// `socialComment`, `socialLike`, `medicalAlert`, `medicalClear`, `debug`,
/// `noType`
enum NotificationType implements Comparable<NotificationType> {
  socialComment("socialComment", 20),
  socialLike("socialLike", 21),
  medicalAlert("medicalAlert", 10),
  medicalClear("medicalClear", 11),
  debug("debug", 1),
  noType("noType", 0);

  /// String representation of this `NotificationType`
  final String string;

  /// Arbitrary integer used to represent each type, used for sorting.
  final int num;

  const NotificationType(this.string, this.num);

  /// Creates `NotificationType` from given string, defaults to `noType`
  static NotificationType fromString(String string) {
    switch (string) {
      case "socialComment":
        return socialComment;
      case "socialLike":
        return socialLike;
      case "medicalAlert":
        return medicalAlert;
      case "medicalClear":
        return medicalClear;
      case "debug":
        return debug;
      default:
        return noType;
    }
  }

  @override
  int compareTo(NotificationType other) => num - other.num;
}

/// Severity level of notifications [UNUSED, INCOMPLETE]
enum NotificationLevel {
  all(0),
  alert(60),
  warning(80),
  critical(90),
  off(100),
  ;

  final int value;

  const NotificationLevel(this.value);
}
