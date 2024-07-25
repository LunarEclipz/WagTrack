import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/notification_enums.dart';
import 'package:wagtrack/models/notification_model.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/shared/components/button_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

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
    final recurringNotificationList =
        notificationService.recurringNotificationList;

    final maxNotifCount = notificationService.maxNotificationCount;

    return AppScrollablePage(
      children: <Widget>[
        Text(
          'Notifications',
          style: textStyles.headlineMedium,
        ),
        const SizedBoxh10(),

        // SECTION: BUTTONS
        _showDebugButtons(),

        // SECTION: notifications
        const SizedBoxh10(),
        ListView.separated(
          itemBuilder: (BuildContext context, int index) =>
              NotificationCard(notificationList[index]),
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBoxh10(),
          itemCount: notificationList.length,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
        ),

        // SECTION: under notifications
        const SizedBoxh10(),
        Text('A maximum of $maxNotifCount notifications shown. '
            'Configure this in settings (WIP).'),

        const SizedBoxh10(),
        // SECTION: RECURRING NOTIFICATIONS
        Text(
          'Recurring Notifications',
          style: textStyles.titleMedium!.copyWith(color: colorScheme.secondary),
        ),
        ListView.separated(
          itemBuilder: (BuildContext context, int index) =>
              RecurringNotificationCard(recurringNotificationList[index]),
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBoxh10(),
          itemCount: recurringNotificationList.length,
          physics: const ClampingScrollPhysics(),
          shrinkWrap: true,
        ),
      ],
    );
  }

  Widget _showDebugButtons() {
    if (kReleaseMode) {
      return Container();
    }

    return Column(
      children: [
        const SizedBoxh10(),
        Row(
          children: [
            Expanded(
              child: AppButtonLarge(
                onTap: () => _createRandomNotification(),
                text: 'Create Random',
                padding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: AppButtonLarge(
                onTap: () => _clearAllNotifications(),
                text: 'Clear',
                padding: const EdgeInsets.all(10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Card for standard show notifications
class NotificationCard extends StatefulWidget {
  final AppNotification notif;

  const NotificationCard(this.notif, {super.key});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isExpanded = false;

  Widget getIconForType(BuildContext context, NotificationType type) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;

    switch (type) {
      case NotificationType.noType:
        return const Icon(Icons.question_mark);
      case NotificationType.debug:
        return const Icon(Icons.construction);
      case NotificationType.medicalGreen:
        return Icon(
          Icons.check_circle,
          color: customColors.green,
        );
      case NotificationType.medicalYellow:
        return Icon(
          // Icons.thermostat,
          Icons.error,
          color: Colors.yellow[600],
        );
      case NotificationType.medicalOrange:
        return Icon(
          // Icons.thermostat,
          Icons.error,
          color: Colors.orange[700],
        );
      case NotificationType.medicalRed:
        return Icon(
          Icons.error,
          color: colorScheme.primary,
        );
      case NotificationType.medication:
        return const Icon(Icons.medication);
      case NotificationType.socialComment:
        return const Icon(Icons.chat);
      case NotificationType.socialLike:
        return const Icon(Icons.favorite);
      default:
        return const Icon(Icons.info);
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final AppNotification notif = widget.notif;

    return InkWell(
      onTap: _toggleExpansion,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: AnimatedCrossFade(
          firstChild: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getIconForType(context, notif.type),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title ?? "",
                          style: textStyles.bodyLarge,
                        ),
                        Text(
                          notif.body ?? "",
                          style: textStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    timeAgo(notif.notificationTime),
                    style: textStyles.bodySmall!
                        .copyWith(color: AppTheme.customColors.secondaryText),
                  ),
                ],
              )
            ],
          ),
          secondChild: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getIconForType(context, notif.type),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title ?? "",
                          style: textStyles.bodyLarge,
                        ),
                        Text(
                          notif.body ?? "",
                          style: textStyles.bodyMedium,
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppIconButtonSmall(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: AppTheme.customColors.secondaryText,
                    ),
                    onPressed: () {
                      setState(_toggleExpansion);
                      context
                          .read<NotificationService>()
                          .deleteNotification(id: notif.id);
                    },
                  ),
                  Text(
                    // timeAgo(notif.notificationTime),
                    '${formatDateTime(notif.notificationTime).date} '
                    '${formatDateTime(notif.notificationTime).time}',
                    style: textStyles.bodySmall!
                        .copyWith(color: AppTheme.customColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 100),
        ),
      ),
    );
  }
}

/// Card for recurring notifications
class RecurringNotificationCard extends StatefulWidget {
  final AppRecurringNotification notif;

  const RecurringNotificationCard(this.notif, {super.key});

  @override
  State<RecurringNotificationCard> createState() =>
      _RecurringNotificationCardState();
}

class _RecurringNotificationCardState extends State<RecurringNotificationCard> {
  bool _isExpanded = false;

  Widget getIconForType(BuildContext context, NotificationType type) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors =
        Theme.of(context).extension<CustomColors>()!;

    switch (type) {
      case NotificationType.noType:
        return const Icon(Icons.question_mark);
      case NotificationType.debug:
        return const Icon(Icons.construction);
      case NotificationType.medicalGreen:
        return Icon(
          Icons.check_circle,
          color: customColors.green,
        );
      case NotificationType.medicalYellow:
        return Icon(
          // Icons.thermostat,
          Icons.error,
          color: Colors.yellow[600],
        );
      case NotificationType.medicalOrange:
        return Icon(
          // Icons.thermostat,
          Icons.error,
          color: Colors.orange[700],
        );
      case NotificationType.medicalRed:
        return Icon(
          Icons.error,
          color: colorScheme.primary,
        );
      case NotificationType.medication:
        return const Icon(Icons.medication);
      case NotificationType.socialComment:
        return const Icon(Icons.chat);
      case NotificationType.socialLike:
        return const Icon(Icons.favorite);
      default:
        return const Icon(Icons.info);
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final AppRecurringNotification notif = widget.notif;

    return InkWell(
      onTap: _toggleExpansion,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
        ),
        child: AnimatedCrossFade(
          firstChild: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getIconForType(context, notif.type),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title ?? "",
                          style: textStyles.bodyLarge,
                        ),
                        Text(
                          notif.body ?? "",
                          style: textStyles.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Every ${formatDuration(notif.interval)}',
                    style: textStyles.bodySmall!
                        .copyWith(color: AppTheme.customColors.secondaryText),
                  ),
                ],
              )
            ],
          ),
          secondChild: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  getIconForType(context, notif.type),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.title ?? "",
                          style: textStyles.bodyLarge,
                        ),
                        Text(
                          notif.body ?? "",
                          style: textStyles.bodyMedium,
                        )
                      ],
                    ),
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppIconButtonSmall(
                    icon: Icon(
                      Icons.delete_rounded,
                      color: AppTheme.customColors.secondaryText,
                    ),
                    onPressed: () {
                      setState(_toggleExpansion);
                      context
                          .read<NotificationService>()
                          .deleteNotification(id: notif.id);
                    },
                  ),
                  Text(
                    'Started '
                    '${formatDateTime(notif.startTime).date} '
                    '${formatDateTime(notif.startTime).time}, '
                    'Every ${formatDuration(notif.interval)}',
                    style: textStyles.bodySmall!
                        .copyWith(color: AppTheme.customColors.secondaryText),
                  ),
                ],
              ),
            ],
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 100),
        ),
      ),
    );
  }
}
