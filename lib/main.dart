import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/firebase_options.dart';
import 'package:wagtrack/screens/app_wrapper.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/screens/notifications/notifications.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/injection_service.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/medication_service.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/post_service.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/themes.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // now wait for dependency injection
  await InjectionService.injectAll();

  runApp(WagTrackApp(navigatorKey));
}

class WagTrackApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const WagTrackApp(this.navigatorKey, {super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppLogger.i("[MAIN] Building main app...");

    AppLogger.d("kReleaseMode: $kReleaseMode");
    AppLogger.d("kDebugMode: $kDebugMode");

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => NotificationService(navigatorKey),
        ),
        ChangeNotifierProvider(
          create: (context) => UserService(),
        ),
        ChangeNotifierProvider(
          create: (context) => PetService(),
        ),
        ChangeNotifierProvider(
          create: (context) => PostService(),
        ),
        ChangeNotifierProvider(
          create: (context) => SymptomService(
            Provider.of<PetService>(context, listen: false),
            Provider.of<NotificationService>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => MedicationService(
            Provider.of<PetService>(context, listen: false),
            Provider.of<SymptomService>(context, listen: false),
            Provider.of<NotificationService>(context, listen: false),
          ),
        ),
        // Provider<AuthenticationService>(
        //   create: (context) => AuthenticationService(FirebaseAuth.instance),
        // ChangeNotifierProxyProvider<UserService, AuthenticationService>(
        //   update: (context, user, auth) =>
        //       AuthenticationService(FirebaseAuth.instance, user),
        //   create: (BuildContext context) => AuthenticationService(
        //       FirebaseAuth.instance, context.read<UserService>()),
        // ),

        // writing it like this using `ChangeNotifierProvider` rather than using
        // `ChangeNotifierProxyProvider`,
        // Since updates UserService don't need to change AuthenticationService
        // and in turn call a ChangeNotifier
        ChangeNotifierProvider(
          create: (context) => AuthenticationService(Provider.of<UserService>(
            context,
            listen: false,
          )),
        ),
        StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'wagtrack',
        theme: AppTheme.light,
        home: const Authenticate(),

        // Navigation routes
        routes: {
          '/home': (context) => const AppWrapper(),
          '/notifications': (context) => const Notifications(),
        },

        navigatorKey: navigatorKey,
      ),
    );
  }
}

/// Notification tap background action
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  AppLogger.t('[NOTIF:TAP] notification(${notificationResponse.id}) '
      'action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');

  if (notificationResponse.input?.isNotEmpty ?? false) {
    AppLogger.t('[NOTIF:TAP] notification action tapped with input: '
        '${notificationResponse.input}');
  }

  /// navigate to payload
  if (notificationResponse.payload != null &&
      notificationResponse.payload!.isNotEmpty) {
    navigatorKey.currentState?.pushNamed(notificationResponse.payload!);
  }
}

/// Notification tap action
void notificationTapAction(NotificationResponse notificationResponse) {
  AppLogger.t('[NOTIF:TAP] notification(${notificationResponse.id}) '
      'action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');

  /// navigate to payload
  if (notificationResponse.payload != null &&
      notificationResponse.payload!.isNotEmpty) {
    navigatorKey.currentState?.pushNamed(notificationResponse.payload!);
  }
}
