import 'package:flutter/material.dart';
import 'package:wagtrack/models/symptom_enums.dart';
import 'package:wagtrack/shared/themes.dart';

/// Takes in the number to be displayed in the severity.
/// Takes in the `SymptomLevel` severity and sets the color based on that
///
/// Default size is 15, `isLarge` sets it to the default `CircleAvatar` size,
/// meant for the severity slider when adding/editing a symptom
class SeverityIcon extends StatefulWidget {
  final SymptomLevel level;
  final int val;
  final bool isLarge;

  const SeverityIcon({
    super.key,
    required this.level,
    required this.val,
    this.isLarge = false,
  });

  @override
  State<SeverityIcon> createState() => _SeverityIconState();
}

class _SeverityIconState extends State<SeverityIcon> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    const Color colorRed = SeverityColors.red;
    const Color colorOrange = SeverityColors.orange;
    const Color colorYellow = SeverityColors.yellow;
    const Color colorGreen = SeverityColors.green;

    final Color severityColor;

    switch (widget.level) {
      case SymptomLevel.red:
        severityColor = colorRed;
      case SymptomLevel.orange:
        severityColor = colorOrange;
      case SymptomLevel.yellow:
        severityColor = colorYellow;
      case SymptomLevel.green:
        severityColor = colorGreen;
      default:
        severityColor = Colors.grey;
    }

    return CircleAvatar(
      radius: widget.isLarge ? null : 15,
      backgroundColor: severityColor,
      child: Text(
        widget.val.toString(),
        style: widget.isLarge
            ? const TextStyle(color: Colors.white)
            : textStyles.bodyLarge!.copyWith(color: Colors.white),
      ),
    );
  }
}
