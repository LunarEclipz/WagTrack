enum SymptomLevel implements Comparable<SymptomLevel> {
  red("Red", "Emergency", 100),
  orange("Orange", "Urgent", 80),
  yellow("Yellow", "Semi-Urgent", 60),
  green("Green", "Non-Urgent", 20);

  /// String representation of this `SymptomLevel`
  final String string;

  /// More descriptive decription of the symptom level
  final String desc;

  /// Arbitrary integer used to represent each type, used for sorting.
  final int val;

  const SymptomLevel(this.string, this.desc, this.val);

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
