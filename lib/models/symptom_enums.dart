import 'package:wagtrack/models/notification_enums.dart';

enum SymptomLevel implements Comparable<SymptomLevel> {
  red(NotificationType.medicalRed, "Red", "Emergency", 100),
  orange(NotificationType.medicalOrange, "Orange", "Urgent", 80),
  yellow(NotificationType.medicalYellow, "Yellow", "Semi-Urgent", 60),
  green(NotificationType.medicalGreen, "Green", "Non-Urgent", 20);

  /// String representation of this `SymptomLevel`
  final String string;

  /// More descriptive decription of the symptom level
  final String desc;

  /// Arbitrary integer used to represent each type, used for sorting.
  final int val;

  /// Associated `NotificationType`
  final NotificationType notifType;

  const SymptomLevel(
    this.notifType,
    this.string,
    this.desc,
    this.val,
  );

  /// Creates `NotificationType` from given string, defaults to `noType`
  static SymptomLevel fromString(String string) {
    switch (string) {
      case "Red":
        return red;
      case "Orange":
        return orange;
      case "Yellow":
        return yellow;
      case "Green":
        return green;
      default:
        return green;
    }
  }

  @override
  int compareTo(SymptomLevel other) => val - other.val;
}
