import 'dart:math';

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
  /// Clears all notifications
  void _clearAllNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifService =
          Provider.of<NotificationService>(context, listen: false);

      notifService.deleteAllNotifications();
    });
  }

  /// Creates a random notification
  void _createRandomNotification() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifService =
          Provider.of<NotificationService>(context, listen: false);

      final type = NotificationType
          .values[Random().nextInt(NotificationType.values.length)];

      final typeString = type.string;
      final bodyString = "$typeString notification!\nLorem Ipsum";

      notifService.showNotification(
        typeString,
        bodyString,
        type,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final notificationService = context.watch<NotificationService>();
    final notificationList = notificationService.getNotifications();

    final maxNotifCount = notificationService.maxNotificationCount;

    return AppScrollablePage(
      children: <Widget>[
        Text(
          'Notifications',
          style: textStyles.headlineMedium,
        ),
        const SizedBoxh10(),
        Text(
          '''Placeholder page. All notifications will be placeholders. 
Maximum of $maxNotifCount notifications shown.''',
          style: textStyles.bodySmall,
        ),

        // SECTION: BUTTONS
        const SizedBoxh10(),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _createRandomNotification(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'Create Random',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: InkWell(
                onTap: () => _clearAllNotifications(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'Clear',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // SECTION: notifications
        const SizedBoxh10(),
        ListView.separated(
          itemBuilder: (BuildContext context, int index) =>
              NotificationBox(notificationList[index]),
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBoxh10(),
          itemCount: notificationList.length,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
        ),
      ],
    );
  }
}

class NotificationBox extends StatelessWidget {
  final AppNotification notif;

  const NotificationBox(this.notif, {super.key});

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
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {},
      child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getIconForType(context, notif.type),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: Text(
                notif.body!,
                style: textStyles.bodyMedium,
              ))
            ],
          )),
    );
  }
}
