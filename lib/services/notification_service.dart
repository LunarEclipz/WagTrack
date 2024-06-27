// import 'package:wagtrack/services/logging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:wagtrack/models/notiification_model.dart';

/// Service that handles notifications
class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // keys for storing in shared preferences
  final String _notificationsListKey = 'notificationsList';
  final String _notificationsMaxIdKey = 'notificationsMaxId';

  // List of local notifications
  late List<AppNotification> localNotifications;
  late int notificationsMaxId;

  // Notification details
  late NotificationDetails mainNotificationDetails;

  // SINGLETON
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  /// To be initialized in main() before the main app is built!
  Future<void> initialize() async {
    // TODO: only works for Android????
    // iOS settings https://blog.codemagic.io/flutter-local-notifications/
    // Initializing notification settings for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_launcher');
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
  }

  /// Shows notification now.
  Future<void> showNotification(
    int id,
    String title,
    String body,
  ) async {
    // create new notification object
    final newNotif = AppNotification(
      id: notificationsMaxId + 1,
      createdTime: DateTime.now(),
      notificationTime: DateTime.now(),
      title: title,
      body: body,
    );

    if (!newNotif.isEmpty) {
      // increments max id if notification was sucessfully created
      notificationsMaxId++;
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
  }

  // Schedules notification for future at a specified dateTime.
  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    // https://stackoverflow.com/questions/64305469/how-to-convert-datetime-to-tzdatetime-in-flutter
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.from(scheduledTime, tz.local);

    // create new notification object
    final newNotif = AppNotification(
      id: notificationsMaxId + 1,
      createdTime: DateTime.now(),
      notificationTime: scheduledTime,
      title: title,
      body: body,
    );

    if (!newNotif.isEmpty) {
      // increments max id if notification was sucessfully created
      notificationsMaxId++;
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
  }

  /// Saves current notifications to shared preferences.
  Future<void> saveNotification(AppNotification notification) async {
    // loads currently saved notifications in shared prefs
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList(_notificationsListKey) ?? <String>[];

    // only save notification if it is nonEmpty.
    if (!notification.isEmpty) {
      // increments max id
      notificationsMaxId++;
      localNotifications.add(notification);
      notifications.add(notification.toJSONString());
      await prefs.setStringList(_notificationsListKey, notifications);
      await prefs.setInt(_notificationsMaxIdKey, notificationsMaxId);
    }
  }

  /// loads notifications from shared preferences.
  Future<void> loadNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Get list of notifications as strings
    List<String> notificationStringss =
        prefs.getStringList(_notificationsListKey) ?? <String>[];

    // Convert to `AppNotification`
    localNotifications = notificationStringss.map((notificationString) {
      return AppNotification.fromJSONString(notificationString);
    }).toList();

    // loads maxId
    notificationsMaxId = prefs.getInt(_notificationsMaxIdKey) ?? 0;
  }

  /// Gets current notifications TODO
  Future<List<Map<String, String>>> getNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notifications =
        prefs.getStringList(_notificationsListKey) ?? <String>[];

    return notifications.map((notification) {
      final parts = notification.split('|');
      return {
        'id': parts[0],
        'title': parts[1],
        'body': parts[2],
      };
    }).toList();
  }

  /// Limits notifications to a specified amount
  ///
  /// (Limits the localNotifications list) - this is to be done before updating
  /// shared preferences.
  Future<void> limitNotifications() async {}
}
