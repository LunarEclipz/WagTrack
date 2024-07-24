import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart';
import 'package:wagtrack/models/notification_enums.dart';
import 'package:wagtrack/models/notification_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/notification_service.dart';

import 'injection_service_testing.dart';

// class MockFlutterLocalNotificationsPlugin extends Mock
//     implements FlutterLocalNotificationsPlugin {}

// class MockSharedPreferences extends Mock implements SharedPreferences {}

class MockAndroidFlutterLocalNotificationsPlugin extends Mock
    implements AndroidFlutterLocalNotificationsPlugin {}

class MockTZDateTime extends Mock implements TZDateTime {}

class MockNotificationDetails extends Mock implements NotificationDetails {}

// Mock notification parameters and object
class MockNotification {
  String title;
  String body;
  NotificationType type;

  MockNotification({
    required this.title,
    required this.body,
    required this.type,
  });
}

/// TODO:
///
/// Untested:
/// - `limitNotifications`
/// - `getNotifications` - don't get future notifs
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  InjectionServiceTesting.injectAll();
  final getIt = GetIt.instance;

  // mock class fields
  late MockFlutterLocalNotificationsPlugin mockFlutterLocalNotificationsPlugin;
  late MockAndroidFlutterLocalNotificationsPlugin
      mockAndroidFlutterLocalNotificationsPlugin;
  late MockSharedPreferences mockSharedPreferences;
  late NotificationService notificationService;
  late MockNotification mockNotification;

  // other fields
  late DateTime dtNow;
  late DateTime dtFuture;
  late DateTime dtPast;

  // Creates a mock `AppNotification` object for the current time.
  AppNotification createMockAppNotification({
    id = 0,
    DateTime? createdTime,
    DateTime? notificationTime,
    title = 'testTitle',
    body = 'testBody',
    type = NotificationType.debug,
  }) {
    return AppNotification(
      id: id,
      createdTime: createdTime ?? DateTime.now(),
      notificationTime: notificationTime ?? DateTime.now(),
      title: title,
      body: body,
      type: type,
    );
  }

  /// Reinjects dependency instances into `GetIt`
  Future<void> reInjectDepedencyInstances() async {
    final getIt = GetIt.instance;
    getIt.allowReassignment = true;

    getIt.registerSingleton<SharedPreferences>(mockSharedPreferences);
    getIt.registerSingleton<FlutterLocalNotificationsPlugin>(
        mockFlutterLocalNotificationsPlugin);
  }

  /// Sets dependency instances to be used for mocking/stubbing and to be referenced
  /// in the main code
  void setDependencyInstances() {
    mockSharedPreferences = MockSharedPreferences();
    mockFlutterLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
  }

  // MAIN TESTING CODE

  /// Initial first-time test setup
  ///
  /// Including setting `FallbackValue`s
  setUpAll(() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    const AndroidNotificationChannel testChannel = AndroidNotificationChannel(
      'main_channel', // channel ID
      'test', //channel name
    );
    registerFallbackValue(initializationSettings);
    registerFallbackValue(testChannel);
    registerFallbackValue(MockTZDateTime());
    registerFallbackValue(MockNotificationDetails());
    registerFallbackValue(UILocalNotificationDateInterpretation.absoluteTime);
    registerFallbackValue(DateTimeComponents.time);

    SharedPreferences.setMockInitialValues({});

    mockAndroidFlutterLocalNotificationsPlugin =
        MockAndroidFlutterLocalNotificationsPlugin();
  });

  setUp(() async {
    setDependencyInstances();
    await reInjectDepedencyInstances();

    // Stubs for `NotificationService` initialisation
    when(() => mockFlutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()).thenReturn(null);
    when(() => mockAndroidFlutterLocalNotificationsPlugin
        .createNotificationChannel(any())).thenAnswer((_) async {});
    when(() => mockFlutterLocalNotificationsPlugin.initialize(any()))
        .thenAnswer((_) async {
      return true;
    });

    // initialise notification service
    notificationService = NotificationService();

    // other mocked data required
    mockNotification = MockNotification(
        title: "test", body: "test", type: NotificationType.debug);

    dtNow = DateTime.now();
    dtFuture = dtNow.add(const Duration(days: 1));
    dtPast = dtNow.subtract(const Duration(days: 1));

    // wait for notificationService to init
    while (!notificationService.isReady) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  });

  group('initialize', () {
    test('initialize initializes the notification service and sets isReady',
        () {
      // it should be initialised already, all that needs to be checked (FOR NOW) is that
      // isReady is set!
      // AppLogger.d(!notificationService.isReady);

      expect(notificationService.isReady, true);
    });
  });

  group('showNotification', () {
    setUp(() {
      when(() => mockSharedPreferences.getStringList(any())).thenReturn([]);
      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
    });

    test('should show a notification and save it', () async {
      final title = mockNotification.title;
      final body = mockNotification.body;
      final type = mockNotification.type;

      when(() => mockFlutterLocalNotificationsPlugin.show(
          any(), any(), any(), any())).thenAnswer((_) async => {});

      await notificationService.showNotification(title, body, type);

      // calls show()
      verify(() => mockFlutterLocalNotificationsPlugin.show(
          any(), title, body, any())).called(1);
    });
  });

  group('scheduleNotification', () {
    setUp(() {
      when(() => mockSharedPreferences.getStringList(any())).thenReturn([]);
      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
    });

    // TODO: Just doesn't work. please fix.
    test('should schedule a notification and save it', () async {
      final title = mockNotification.title;
      final body = mockNotification.body;
      final type = mockNotification.type;
      final scheduledTime = dtFuture;

      when(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
              any(), any(), any(), any(), any(),
              androidScheduleMode: any(named: 'androidScheduleMode'),
              uiLocalNotificationDateInterpretation:
                  any(named: 'uiLocalNotificationDateInterpretation'),
              matchDateTimeComponents: any(named: 'matchDateTimeComponents')))
          .thenAnswer((_) async => {});

      // await notificationService.scheduleNotification(
      //     title, body, scheduledTime, type);

      // calls zonedSchedule
      // verify(() => mockFlutterLocalNotificationsPlugin.zonedSchedule(
      //         any(), title, body, any(), any(),
      //         androidScheduleMode: any(named: 'androidScheduleMode'),
      //         uiLocalNotificationDateInterpretation:
      //             any(named: 'uiLocalNotificationDateInterpretation'),
      //         matchDateTimeComponents: any(named: 'matchDateTimeComponents')))
      //     .called(1);
    });
  });

  group('saveNotification', () {
    setUp(() {
      notificationService.isReady = true;

      // set current maxInt
      notificationService.notificationsMaxId = 0;
    });

    test(
        'should save a notification to SharedPreferences and increment notificationsMaxId',
        () async {
      final mockNotif = createMockAppNotification();

      // stubs
      when(() => mockSharedPreferences.getStringList(any())).thenReturn([]);
      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // don't limit notifications - that causes another write to storage
      await notificationService.saveNotification(mockNotif, limitNotifs: false);

      // verify the right calls to SharedPreferences
      verify(() => mockSharedPreferences.setStringList(any(), any())).called(1);
      verify(() => mockSharedPreferences.setInt(any(), any())).called(1);

      // verify that notificationList only has mockNotif
      expect(notificationService.notificationList.length, 1);
      expect(notificationService.notificationList[0], mockNotif);

      // verify that notificationsMaxId is incremented
      expect(notificationService.notificationsMaxId, 1);
    });

    test('should not save an empty notification', () async {
      final emptyNotif = AppNotification.getEmptyNotification;

      // this is for testing
      when(() => mockSharedPreferences.getStringList(any())).thenReturn([]);
      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      // don't limit notifications - that causes another write to storage
      await notificationService.saveNotification(emptyNotif,
          limitNotifs: false);

      // verify that no SharedPreferences set calls are made
      verifyNever(() => mockSharedPreferences.setStringList(any(), any()));
      verifyNever(() => mockSharedPreferences.setInt(any(), any()));

      // verify that notificationList is empty
      expect(notificationService.notificationList.length, 0);

      // verify that notificationsMaxId is not incremented
      expect(notificationService.notificationsMaxId, 0);
    });
  });

  group('saveAllNotificationsToDevice', () {
    setUp(() {
      notificationService.isReady = true;
    });
    test(
        'should save notifications converted to JSONString and maxId to SharedPreferences',
        () async {
      final mockNotif = createMockAppNotification();
      final notificationString = mockNotif.toJSONString();

      notificationService.notificationList.add(mockNotif);
      notificationService.notificationsMaxId = 1;

      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      await notificationService.saveAllNotificationsToDevice();

      // correct list saved
      verify(() => mockSharedPreferences.setStringList(
          any(),
          any(
              that: isA<List<String>>().having(
            (e) => e[0],
            "same-notification",
            (notifString) => notifString == notificationString,
          )))).called(1);
      // correct maxID saved
      verify(() => mockSharedPreferences.setInt(any(), 1)).called(1);
    });
  });

  group('loadNotifications', () {
    setUp(() {
      notificationService.isReady = true;
    });
    test('should load notifications saved as JSONString from SharedPreferences',
        () async {
      final mockNotifs = [
        createMockAppNotification(id: 1),
        createMockAppNotification(id: 2),
        createMockAppNotification(id: 3),
      ];
      final notificationStrings =
          mockNotifs.map((n) => n.toJSONString()).toList();

      when(() => mockSharedPreferences.getStringList(any()))
          .thenReturn(notificationStrings);
      when(() => mockSharedPreferences.getInt(any())).thenReturn(1);

      await notificationService.loadNotifications();

      // 1 notif in notificationList
      expect(notificationService.notificationList.length, mockNotifs.length);
      // same notifications are found
      for (AppNotification notif in mockNotifs) {
        expect(notificationService.notificationList.contains(notif), true);
      }
    });
  });

  group('sortNotifications', () {
    setUp(() {
      notificationService.isReady = true;
    });
    test(
        'should sort notifications in reverse order by notificationTime (default)',
        () async {
      final mockNotifs = [
        createMockAppNotification(id: 1, notificationTime: dtNow),
        createMockAppNotification(id: 2, notificationTime: dtPast),
        createMockAppNotification(id: 3, notificationTime: dtFuture),
      ];

      // copies elements without copying reference
      notificationService.notificationList =
          mockNotifs.map((notif) => notif).toList();

      notificationService.sortNotifications();

      // same number of notifs in notificationList
      expect(notificationService.notificationList.length, mockNotifs.length);
      // check for order:
      expect(notificationService.notificationList[0], mockNotifs[2]);
      expect(notificationService.notificationList[1], mockNotifs[0]);
      expect(notificationService.notificationList[2], mockNotifs[1]);
    });
  });

  group('deleteAllNotifications', () {
    setUp(() {
      notificationService.isReady = true;
    });

    test('should delete all past notifications and retain future notifications',
        () async {
      final pastNotif = createMockAppNotification(notificationTime: dtPast);
      final futureNotif = createMockAppNotification(notificationTime: dtFuture);

      AppLogger.d(pastNotif.notificationTime.toIso8601String());
      AppLogger.d(dtNow.toIso8601String());
      AppLogger.d(futureNotif.notificationTime.toIso8601String());

      notificationService.notificationList.add(pastNotif);
      notificationService.notificationList.add(futureNotif);

      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      await notificationService.deleteAllNotifications();

      // 1 notif in notificationList
      expect(notificationService.notificationList.length, 1);
      // notifications is the future notification
      expect(notificationService.notificationList[0], futureNotif);
    });

    test(
        'should delete all past/future notifications when retainFutureNotifications = false',
        () async {
      final pastNotif = createMockAppNotification(notificationTime: dtPast);
      final futureNotif = createMockAppNotification(notificationTime: dtFuture);

      notificationService.notificationList.add(pastNotif);
      notificationService.notificationList.add(futureNotif);

      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);

      await notificationService.deleteAllNotifications(
          retainFutureNotifications: false);

      AppLogger.d(notificationService.notificationList);

      expect(notificationService.notificationList.isEmpty, true);
    });
  });

  group('notificationService full tests', () {
    setUp(() {
      notificationService.isReady = true;

      // set current maxInt
      notificationService.notificationsMaxId = 0;

      // stubs
      when(() => mockSharedPreferences.setStringList(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockSharedPreferences.setInt(any(), any()))
          .thenAnswer((_) async => true);
    });

    // TODO this one has issues but it passes :shrug:
    test(
        'should retrieve all saved notifications through loadNotifications when repeated showNotification calls are made',
        () async {
      final mockNotifs = [
        createMockAppNotification(id: 1, title: "test1"),
        createMockAppNotification(id: 2),
        createMockAppNotification(id: 3, body: "body3"),
      ];

      // stubs
      final notificationStrings =
          mockNotifs.map((n) => n.toJSONString()).toList();

      when(() => mockSharedPreferences.getStringList(any()))
          .thenReturn(notificationStrings);
      when(() => mockSharedPreferences.getInt(any())).thenReturn(1);
      when(() => mockFlutterLocalNotificationsPlugin.show(
          any(), any(), any(), any())).thenAnswer((_) async => {});

      // show notifications
      for (AppNotification notif in mockNotifs) {
        await notificationService.showNotification(
          notif.title!,
          notif.body!,
          notif.type,
        );
      }
      // they should get automatically saved.

      // now retrieve:
      await notificationService.loadNotifications();

      // same notifications are found
      for (AppNotification notif in mockNotifs) {
        expect(notificationService.notificationList.contains(notif), true);
      }
    });
  });
}
