import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wagtrack/models/notification_params.dart';
import 'package:wagtrack/models/notiification_model.dart';
import 'package:wagtrack/services/logging.dart';

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
      FlutterLocalNotificationsPlugin();

  // Keys for storing in shared preferences
  final String _notificationsListKey = 'notificationsList';
  final String _notificationsMaxIdKey = 'notificationsMaxId';

  /// Whether the service is ready to be used.
  ///
  /// To be used as a flag to prevent service methods from executing, or particular
  /// UI elements from bein shown while loading is incomplete..
  bool isReady = false;

  /// Maxmium number of notifications stored, default = 10.
  int maxNotificationCount = 10;

  /// List of local notifications
  List<AppNotification> notificationList = [];

  /// Current maximum Id of notifications
  int notificationsMaxId = 0;

  // Notification details
  late NotificationDetails mainNotificationDetails;

  /// Constructor to create notification service.
  ///
  /// All the main initialisation happens in
  NotificationService() {
    initialize();
  }

  /// Initialises the notification service. Has async functions in here.
  Future<void> initialize() async {
    AppLogger.d("[NOTIF] Initializing notification service...");

    try {
      // TODO: only works for Android????
      // iOS settings https://blog.codemagic.io/flutter-local-notifications/
      // Initializing notification settings for Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      // Initialize notification channels
      const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
        'main_channel', // channel ID
        'Main Notifications', // channel name
        description: 'Main WagTrack app notifications',
        importance: Importance.high,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(mainChannel);

      // Setup notification details
      const AndroidNotificationDetails androidNotificationDetails =
          AndroidNotificationDetails(
        'main_channel', // channel ID
        'Main Notifications', // channel name
        importance: Importance.max,
        priority: Priority.high,
      );

      mainNotificationDetails =
          const NotificationDetails(android: androidNotificationDetails);

      // init flutter local notifs
      await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

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
        mainNotificationDetails,
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
        mainNotificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // Save scheduled notification to storage
      saveNotification(newNotif);

      // Doesn't notify

      AppLogger.i("[NOTIF] Succesfully scheduled $newNotif");
    } catch (e) {
      AppLogger.e("[NOTIF] Error scheduling notification: $e", e);
    }
  }

  /// Saves one specified notification to device storage (shared preferences).
  Future<void> saveNotification(AppNotification notification) async {
    // loads currently saved notifications in shared prefs
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList(_notificationsListKey) ?? <String>[];

    // only add and save notification if it is nonEmpty.
    if (!notification.isEmpty) {
      // increments max id
      notificationsMaxId++;
      notificationList.add(notification);
      notifications.add(notification.toJSONString());
      await prefs.setStringList(_notificationsListKey, notifications);
      await prefs.setInt(_notificationsMaxIdKey, notificationsMaxId);

      // makes sure notifications is under the limit.
      limitNotifications();
    }
  }

  /// Saves all notifications in service to device storage (shared preferences).
  ///
  /// Also updates maxId
  Future<void> saveAllNotificationsToDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final notificationsJsonString =
        notificationList.map((notif) => notif.toJSONString()).toList();

    await prefs.setStringList(_notificationsListKey, notificationsJsonString);
    await prefs.setInt(_notificationsMaxIdKey, notificationsMaxId);
  }

  /// loads notifications from shared preferences.
  Future<void> loadNotifications() async {
    AppLogger.t("[NOTIF] Loading notifications");
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Get list of notifications as strings
      List<String> notificationStrings =
          prefs.getStringList(_notificationsListKey) ?? <String>[];

      // Convert to `AppNotification`
      notificationList = notificationStrings.map((notificationString) {
        return AppNotification.fromJSONString(notificationString);
      }).toList();

      // loads maxId
      notificationsMaxId = prefs.getInt(_notificationsMaxIdKey) ?? 0;
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
    sortnotifications(sortingMode: sortingMode, reversed: reversed);

    return notificationList.where((notif) {
      // The notification is not a future notification
      return !notif.isFutureNotification;
    }).toList();
  }

  /// Sorts notifications, default is by notified time and in reverse order (newest first)
  ///
  /// Should run everytime:
  /// - a notification is added
  /// - a `getNotifications()` call is made
  void sortnotifications({
    NotificationSortingMode sortingMode = NotificationSortingMode.timeNotified,
    bool reversed = true,
  }) {
    AppLogger.t("[NOTIF] Sorting notifications");
    try {
      // Comparators
      switch (sortingMode) {
        case NotificationSortingMode.id:
          if (reversed) {
            notificationList.sort((x, y) => x.id - y.id);
          } else {
            notificationList.sort((x, y) => y.id - x.id);
          }
        case NotificationSortingMode.timeNotified:
          if (reversed) {
            notificationList.sort(
                (x, y) => y.notificationTime.compareTo(x.notificationTime));
          } else {
            notificationList.sort(
                (x, y) => x.notificationTime.compareTo(y.notificationTime));
          }
        case NotificationSortingMode.timeCreated:
          if (reversed) {
            notificationList
                .sort((x, y) => y.createdTime.compareTo(x.createdTime));
          } else {
            notificationList
                .sort((x, y) => x.createdTime.compareTo(y.createdTime));
          }
        case NotificationSortingMode.type:
          if (reversed) {
            notificationList.sort((x, y) => y.type.compareTo(x.type));
          } else {
            notificationList.sort((x, y) => x.type.compareTo(y.type));
          }
        default:
          if (reversed) {
            notificationList.sort(
                (x, y) => y.notificationTime.compareTo(x.notificationTime));
          } else {
            notificationList.sort(
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
    // First sort notifications
    sortnotifications(
      sortingMode: NotificationSortingMode.timeNotified,
      reversed: false,
    );

    // then delete
    // while there are more notifications than the limit AND
    // the first notification is NOT an future notification
    while (notificationList.length > maxNotificationCount &&
        !notificationList[0].isFutureNotification) {
      notificationList.removeAt(0);
    }

    notifyListeners();

    // save to local preferences.
    if (updateStorage) {
      await saveAllNotificationsToDevice();
    }
  }

  /// Deletes all notifications. By default, retains notifications that have not been notified
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
        notificationList = notificationList
            .where((notif) => notif.isFutureNotification)
            .toList();
      } else {
        // clears ALL notifications
        notificationList = [];
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
}
