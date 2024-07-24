import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:wagtrack/models/notification_enums.dart';
import 'package:wagtrack/models/notification_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/shared/utils.dart';

/// Modes to sort notifications by.
enum NotificationSortingMode {
  timeCreated,
  timeNotified,
  id,
  type,
}

/// Service that handles notifications
///
/// **EVERYTHING** HERE (THE NOTIFICATIONS CONFIG) IS A BLOODY MESS PLEASE
/// FIX WHEN ABLE :pray:
///
/// Also storing notifications as a list given the operations seems very
/// inefficient, but we aren't storing that much so ¯\_(ツ)_/¯
class NotificationService with ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      GetIt.I<FlutterLocalNotificationsPlugin>();
  final SharedPreferences _prefs = GetIt.I<SharedPreferences>();

  // Keys for storing in shared preferences
  final String _notificationsListKey = 'notificationsList';
  final String _recurringNotificationsListKey = 'recurringNotificationsList';
  final String _notificationsMaxIdKey = 'notificationsMaxId';

  /// Whether the service is ready to be used.
  ///
  /// To be used as a flag to prevent service methods from executing, or particular
  /// UI elements from bein shown while loading is incomplete..
  bool isReady = false;

  /// Maxmium number of show notifications stored, default = 100.
  ///
  /// This does not include recurring notifications TODO
  int maxNotificationCount = 100;

  /// List of local notifications
  List<AppNotification> notificationShowList = [];

  /// List of recurring notifications
  List<AppRecurringNotification> recurringNotificationList = [];

  /// Current maximum Id of notifications. Used to determine the id of new notifs
  int notificationsMaxId = 0;

  // Standard notification details to be used;
  late final NotificationDetails _mainNotificationDetails;

  /// whether notifications (in the operating system) are enabled.
  /// Doesn't seem to work for iOS.
  bool _notificationsEnabled = false;

  /// Constructor to create notification service.
  ///
  /// All the main initialisation happens in
  NotificationService() {
    initialize();
  }

  /// Initialises the notification service. Is async.
  ///
  /// sets `isReady` to `true` after it completes.
  Future<void> initialize() async {
    /// https://medium.com/@MarvelApps_/flutter-local-notification-d52aa41c065f
    /// https://medium.com/@gauravswarankar/local-push-notification-flutter-32cc99f900a5
    /// https://pub.dev/packages/flutter_local_notifications
    /// iOS settings https://blog.codemagic.io/flutter-local-notifications/
    ///
    /// Unsure if fully set up for iOS (untested)
    /// Notification actions are currently not supported.
    ///
    /// currently also not setting up channels.
    ///
    /// Future TODO:
    /// - allow user to press notification to go to a page (use payloads)

    if (isReady) {
      // already initialised, no need to reinit
      return;
    }

    AppLogger.d("[NOTIF] Initializing notification service...");

    // CONFIG TIME ZONES
    await _configureLocalTimeZone();

    try {
      // TODO: Only more or less set up for Android at the moment

      /// Set up initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('notification_icon_main');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      // initialize with settings
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

      // Setup notification details
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'main_channel', // channel ID
        'Main Notifications', // channel name
        importance: Importance.max,
        priority: Priority.high,
      );

      _mainNotificationDetails =
          const NotificationDetails(android: androidNotificationDetails);

      // load notifications from local storage
      await loadNotifications();

      // not really necessary?
      notifyListeners();

      // Complete loading
      isReady = true;

      AppLogger.i("[NOTIF] Succesfully initalized notification service");
    } catch (e) {
      AppLogger.e("[NOTIF] Error initalizing notification service: $e", e);
    }
  }

  // CONFIG Methods

  /// Requests permissions. OS-specific. Not part of full initialization as it
  /// is meant to be run as the user is logged into the main home screen.
  Future<void> requestPermissions() async {
    if (Platform.isIOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      final bool? grantedNotificationPermission =
          await androidImplementation?.requestNotificationsPermission();
      _notificationsEnabled = grantedNotificationPermission ?? false;
    }
    AppLogger.d("[NOTIF] Notifications permissions requested.");
  }

  // USAGE methods

  /// Shows notification now.
  ///
  /// Saves notification to device storage.
  Future<void> showNotification(
    String title,
    String body,
    NotificationType type,
  ) async {
    if (!isReady) {
      AppLogger.w("[NOTIF] Notification service is not ready.");
      return;
    }

    AppLogger.d("[NOTIF] Showing notification '$title' now");

    try {
      // create new notification object
      final newNotif = AppNotification(
        id: notificationsMaxId + 1,
        createdTime: DateTime.now(),
        notificationTime: DateTime.now(),
        type: type,
        title: title,
        body: body,
      );

      // only show schedule notification it it was succesfully created
      if (newNotif.isEmpty) {
        AppLogger.w("[NOTIF] Empty notification");
        return;
      }

      // Show notification with FLN
      await _flutterLocalNotificationsPlugin.show(
        newNotif.id,
        newNotif.title,
        newNotif.body,
        _mainNotificationDetails,
      );

      // Save notification to storage
      saveNotification(newNotif);

      // Notify listeners
      notifyListeners();

      AppLogger.i("[NOTIF] Succesfully added $newNotif");
    } catch (e) {
      AppLogger.e("[NOTIF] Error showing notification: $e", e);
    }
  }

  /// Schedules notification for future at a specified dateTime.
  ///
  /// Saves notification to device storage.
  Future<void> scheduleNotification(
    String title,
    String body,
    DateTime scheduledTime,
    NotificationType type,
  ) async {
    if (!isReady) {
      AppLogger.w("[NOTIF] Notification service is not ready.");
      return;
    }

    AppLogger.d("[NOTIF] Scheduling notification '$title' for $scheduledTime");

    try {
      // https://stackoverflow.com/questions/64305469/how-to-convert-datetime-to-tzdatetime-in-flutter
      final tz.TZDateTime scheduledDate =
          tz.TZDateTime.from(scheduledTime, tz.local);

      // create new notification object
      final newNotif = AppNotification(
        id: notificationsMaxId + 1,
        createdTime: DateTime.now(),
        notificationTime: scheduledTime,
        type: type,
        title: title,
        body: body,
      );

      // only schedule notification it it was succesfully created
      if (newNotif.isEmpty) {
        AppLogger.w("[NOTIF] Empty notification");
        return;
      }

      // Schedule notification with FLN
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        newNotif.id,
        newNotif.title,
        newNotif.body,
        scheduledDate,
        _mainNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Save scheduled notification to storage
      saveNotification(newNotif);

      // Doesn't notify listeners, not necessary

      AppLogger.i("[NOTIF] Succesfully scheduled $newNotif");
    } catch (e) {
      AppLogger.e("[NOTIF] Error scheduling notification: $e", e);
    }
  }

  /// Repeats a notification periodically
  ///
  /// TODO Note: `interval` must be one minute or more!!!!
  Future<void> showRecurringNotification(
    String title,
    String body,
    Duration interval,
    NotificationType type,
  ) async {
    if (!isReady) {
      AppLogger.w("[NOTIF] Notification service is not ready.");
      return;
    }
    AppLogger.d(
        "[NOTIF] Scheduling recurring notification '$title' every ${formatDuration(interval)}");
    try {
      // create new recurring notification object
      final newNotif = AppRecurringNotification(
        id: notificationsMaxId + 1,
        startTime: DateTime.now(),
        interval: interval,
        type: type,
        title: title,
        body: body,
      );

      // shopw periodically
      await _flutterLocalNotificationsPlugin.periodicallyShowWithDuration(
        newNotif.id,
        newNotif.title,
        newNotif.body,
        interval,
        _mainNotificationDetails,
      );

      // Save scheduled recurring notification to list and storage
      saveRecurringNotification(newNotif);

      notifyListeners();

      AppLogger.i("[NOTIF] Succesfully scheduled recurring $newNotif");
    } catch (e) {
      AppLogger.e("[NOTIF] Error scheduling recurring notification: $e", e);
    }
  }

  /// Saves one specified notification to device storage (shared preferences).
  Future<void> saveNotification(AppNotification notification,
      {bool limitNotifs = true}) async {
    AppLogger.d("[NOTIF] Saving notification");

    // loads currently saved notifications in shared _prefs
    List<String> notifications =
        _prefs.getStringList(_notificationsListKey) ?? <String>[];

    // only add and save notification if it is nonEmpty.
    if (!notification.isEmpty) {
      // increments max id
      notificationsMaxId++;
      notificationShowList.add(notification);
      notifications.add(notification.toJSONString());
      await _prefs.setStringList(_notificationsListKey, notifications);
      await _prefs.setInt(_notificationsMaxIdKey, notificationsMaxId);

      // final test = notification.body;

      // makes sure notifications is under the limit.
      if (limitNotifs) {
        limitNotifications();
      }
    } else {
      AppLogger.t("[NOTIF] Empty notification");
    }
  }

  /// Saves one specified recurring notification to device storage (shared preferences).
  Future<void> saveRecurringNotification(AppRecurringNotification notification,
      {bool limitNotifs = true}) async {
    AppLogger.d("[NOTIF] Saving recurring notification: $notification");

    // loads currently saved notifications in shared _prefs
    List<String> notifications =
        _prefs.getStringList(_recurringNotificationsListKey) ?? <String>[];

    // only add and save notification if it is nonEmpty.
    if (!notification.isEmpty) {
      // increments max id
      notificationsMaxId++;
      recurringNotificationList.add(notification);
      notifications.add(notification.toJSONString());
      await _prefs.setStringList(_recurringNotificationsListKey, notifications);
      await _prefs.setInt(_notificationsMaxIdKey, notificationsMaxId);

      // final test = notification.body;

      // makes sure notifications is under the limit.
      // if (limitNotifs) {
      //   limitNotifications();
      // }
    } else {
      AppLogger.t("[NOTIF] Empty recurring notification");
    }
  }

  /// Saves all notifications in service to device storage (shared preferences).
  ///
  /// Also updates maxId
  Future<void> saveAllNotificationsToDevice() async {
    final notificationsJsonString =
        notificationShowList.map((notif) => notif.toJSONString()).toList();
    final recurringNotificationsJsonString =
        recurringNotificationList.map((notif) => notif.toJSONString()).toList();

    await _prefs.setStringList(_notificationsListKey, notificationsJsonString);
    await _prefs.setStringList(
        _recurringNotificationsListKey, recurringNotificationsJsonString);
    await _prefs.setInt(_notificationsMaxIdKey, notificationsMaxId);
  }

  /// loads notifications from shared preferences.
  Future<void> loadNotifications() async {
    AppLogger.t("[NOTIF] Loading notifications");
    try {
      // Get list of notifications as strings
      List<String> notificationStrings =
          _prefs.getStringList(_notificationsListKey) ?? <String>[];
      List<String> recurringNotificationStrings =
          _prefs.getStringList(_recurringNotificationsListKey) ?? <String>[];

      // Convert to `AppNotification`
      notificationShowList = notificationStrings.map((notificationString) {
        return AppNotification.fromJSONString(notificationString);
      }).toList();
      recurringNotificationList =
          recurringNotificationStrings.map((notificationString) {
        return AppRecurringNotification.fromJSONString(notificationString);
      }).toList();

      // TODO need to check if recurring notifications are all active

      // loads maxId
      notificationsMaxId = _prefs.getInt(_notificationsMaxIdKey) ?? 0;
      AppLogger.t("[NOTIF] Succesfully loaded notifications");
    } catch (e) {
      AppLogger.e("[NOTIF] Error loading notifications: $e", e);
    }
  }

  /// Gets current notifications, returns a list of `AppNotification` objects.
  ///
  /// Sorting modes can be configured.
  List<AppNotification> getNotifications({
    NotificationSortingMode sortingMode = NotificationSortingMode.timeNotified,
    bool reversed = true,
  }) {
    if (!isReady) {
      AppLogger.w("[NOTIF] Notification service is not ready.");
      return [];
    }

    // first sort
    sortNotifications(sortingMode: sortingMode, reversed: reversed);

    return notificationShowList.where((notif) {
      // The notification is not a future notification
      return !notif.isFutureNotification;
    }).toList();
  }

  /// Sorts notifications, default is by notified time and in reverse order (newest first)
  ///
  /// Should run everytime:
  /// - a notification is added
  /// - a `getNotifications()` call is made
  void sortNotifications({
    NotificationSortingMode sortingMode = NotificationSortingMode.timeNotified,
    bool reversed = true,
  }) {
    AppLogger.t("[NOTIF] Sorting notifications");
    try {
      // Comparators
      switch (sortingMode) {
        case NotificationSortingMode.id:
          if (reversed) {
            notificationShowList.sort((x, y) => x.id - y.id);
          } else {
            notificationShowList.sort((x, y) => y.id - x.id);
          }
        case NotificationSortingMode.timeNotified:
          if (reversed) {
            notificationShowList.sort(
                (x, y) => y.notificationTime.compareTo(x.notificationTime));
          } else {
            notificationShowList.sort(
                (x, y) => x.notificationTime.compareTo(y.notificationTime));
          }
        case NotificationSortingMode.timeCreated:
          if (reversed) {
            notificationShowList
                .sort((x, y) => y.createdTime.compareTo(x.createdTime));
          } else {
            notificationShowList
                .sort((x, y) => x.createdTime.compareTo(y.createdTime));
          }
        case NotificationSortingMode.type:
          if (reversed) {
            notificationShowList.sort((x, y) => y.type.compareTo(x.type));
          } else {
            notificationShowList.sort((x, y) => x.type.compareTo(y.type));
          }
        default:
          if (reversed) {
            notificationShowList.sort(
                (x, y) => y.notificationTime.compareTo(x.notificationTime));
          } else {
            notificationShowList.sort(
                (x, y) => x.notificationTime.compareTo(y.notificationTime));
          }
      }
      AppLogger.t("[NOTIF] Succesfully sorted notifications");
    } catch (e) {
      AppLogger.w("[NOTIF] Error sorting notifications: $e", e);
    }
  }

  /// Limits notifications to a specified amount. Updates notifications in shared preferences by default.
  ///
  /// Oldest (based on notification time) notifications are deleted first. Notitifications
  /// with that have not been notified yet (notifTime > nowTime) will not be deleted.
  ///
  /// (Limits the notificationList list) - this is to be done before updating
  /// shared preferences.
  ///
  /// Highly inefficient, but since the notification list gets sorted every time
  /// it's called for and the numbers of notifications aren't large
  Future<void> limitNotifications({bool updateStorage = true}) async {
    // if witihn length, don't care
    if (notificationShowList.length < maxNotificationCount) {
      return;
    }

    // First sort notifications
    sortNotifications(
      sortingMode: NotificationSortingMode.timeNotified,
      reversed: false,
    );

    // then delete
    // while there are more notifications than the limit AND
    // the first notification is NOT an future notification
    while (notificationShowList.length > maxNotificationCount &&
        !notificationShowList[0].isFutureNotification) {
      notificationShowList.removeAt(0);
    }

    notifyListeners();

    // save to local preferences.
    if (updateStorage) {
      await saveAllNotificationsToDevice();
    }
  }

  /// Deletes the notification with the given integer `id` from the _notificationsShowList.
  /// Deletes from both nofitications AND recurring notifications.
  /// By default, updates notifications
  /// in shared preferences.
  ///
  /// Will also cancel the notification in FLN.
  ///
  /// Doesn't delete empty (id=-1) notifications
  Future<void> deleteNotification({
    required int id,
    bool updateStorage = true,
  }) async {
    if (id < 0) {
      AppLogger.d("[NOTIF] Will not delete empty notification");
      return;
    }

    AppLogger.d("[NOTIF] Deleting notification with id $id");
    try {
      // remove from notification list
      notificationShowList.removeWhere((notif) => notif.id == id);
      recurringNotificationList.removeWhere((notif) => notif.id == id);

      // remove from flutter local notifs
      _flutterLocalNotificationsPlugin.cancel(id);

      // update shared prefs
      if (updateStorage) {
        await saveAllNotificationsToDevice();
      }
    } catch (e) {
      AppLogger.e("[NOTIF] Error deleting notification", e);
    }

    notifyListeners();
  }

  /// Deletes all notifications. Currently does not delete from recurring notifications
  /// By default, retains notifications that have not been notified
  /// and updates notifications in shared preferences.
  Future<void> deleteAllNotifications({
    bool retainFutureNotifications = true,
    bool updateStorage = true,
  }) async {
    if (!isReady) {
      AppLogger.w("[NOTIF] Notification service is not ready.");
      return;
    }

    AppLogger.d("[NOTIF] Deleting notifications");
    try {
      if (retainFutureNotifications) {
        // keeps future notifications
        notificationShowList = notificationShowList
            .where((notif) => notif.isFutureNotification)
            .toList();
      } else {
        // clears ALL notifications
        notificationShowList = [];
      }

      // Update local preferences. All notifications will be removed.
      if (updateStorage) {
        await saveAllNotificationsToDevice();
      }

      notifyListeners();

      AppLogger.i("[NOTIF] Succesfully deleted notifications");
    } catch (e) {
      AppLogger.w("[NOTIF] Error deleting notifications: $e", e);
    }
  }

  /// Resets notificationService
  ///
  /// clears lists of notifications
  void resetService() {
    AppLogger.t("[NOTIF] Resetting notification service");
    notificationShowList = [];
  }
}

// Misc
Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}
