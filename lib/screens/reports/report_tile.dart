import 'package:flutter/material.dart';
import 'package:wagtrack/shared/themes.dart';

class ReportTile extends StatefulWidget {
  final String month;
  final String red;
  final String orange;
  final String yellow;
  final String green;

  const ReportTile({
    super.key,
    required this.month,
    required this.red,
    required this.orange,
    required this.yellow,
    required this.green,
  });

  @override
  State<ReportTile> createState() => _ReportTileState();
}

class _ReportTileState extends State<ReportTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.month != "")
          Text(
            'Total Reports in ${widget.month}',
          ),
        const CircleAvatar(
          backgroundColor: SeverityColors.red,
          radius: 5,
        ),
        Text(widget.red),
        const CircleAvatar(
          backgroundColor: SeverityColors.orange,
          radius: 5,
        ),
        Text(widget.orange),
        const CircleAvatar(
          backgroundColor: SeverityColors.yellow,
          radius: 5,
        ),
        Text(widget.yellow),
        const CircleAvatar(
          backgroundColor: SeverityColors.green,
          radius: 5,
        ),
        Text(widget.green),
        const SizedBox(
          width: 5,
        ),
      ],
    );
  }
}
