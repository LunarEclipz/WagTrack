import 'package:flutter/material.dart';
import 'package:wagtrack/models/notification_model.dart';

class NotificationDetails extends StatelessWidget {
  final AppNotification notif;

  const NotificationDetails(this.notif, {super.key});
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    return Container(
      width: 450,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Text(
            notif.title ?? "",
            style: textStyles.titleMedium,
          ),
        ],
      ),
    );
  }
}
