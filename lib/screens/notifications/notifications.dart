import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/notification_params.dart';
import 'package:wagtrack/models/notiification_model.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final notificationService = context.read<NotificationService>();
    final notificationList = notificationService.getNotifications();

    return AppScrollablePage(
      children: <Widget>[
        Text(
          "Notifications",
          style: textStyles.headlineMedium,
        ),
        ListView.separated(
            itemBuilder: (BuildContext context, int index) =>
                NotificationBox(notificationList[index]),
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBoxh20(),
            itemCount: notificationList.length)
      ],
    );
  }
}

class NotificationBox extends StatelessWidget {
  const NotificationBox(AppNotification notif, {super.key});

  Widget getIconForType(BuildContext context, NotificationType type) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;

    switch (type) {
      case NotificationType.noType:
        return const Icon(Icons.question_mark);
      case NotificationType.debug:
        return const Icon(Icons.construction);
      case NotificationType.medicalAlert:
        return Icon(
          Icons.error,
          color: colorScheme.primary,
        );
      case NotificationType.medicalClear:
        return Icon(
          Icons.check_circle,
          color: customColors.green,
        );
      case NotificationType.socialComment:
        return const Icon(Icons.chat);
      case NotificationType.socialLike:
        return const Icon(Icons.favorite);
      default:
        return const Icon(Icons.info);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
