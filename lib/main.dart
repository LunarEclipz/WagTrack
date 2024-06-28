import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/firebase_options.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WagTrackApp());
}

class WagTrackApp extends StatelessWidget {
  const WagTrackApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    AppLogger.i("Building main app");

    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(
        //   create: (context) => NotificationService(),
        // ),
        FutureProvider(
          // does this work?
          create: (_) async {
            final notifService = NotificationService();
            await notifService.initialize();
            return notifService;
          },
          initialData: NotificationService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserService(),
        ),
        ChangeNotifierProvider(
          create: (context) => PetService(),
        ),
        ChangeNotifierProvider(
          create: (context) => SymptomService(),
        ),
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
          create: (context) => AuthenticationService(
              FirebaseAuth.instance,
              Provider.of<UserService>(
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
      ),
    );
  }
}
