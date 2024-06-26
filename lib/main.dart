import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/firebase_options.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/services/auth_service.dart';
import 'package:wagtrack/services/logging.dart';
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
        ChangeNotifierProvider(
          create: (context) => UserService(),
        ),
        ChangeNotifierProvider(
          create: (context) => PetService(),
        ),
        ChangeNotifierProvider(
          create: (context) => SymptomService(),
        ),
        // Provider<AuthenticationService>(
        //   create: (context) => AuthenticationService(FirebaseAuth.instance),
        // ),
        ChangeNotifierProxyProvider<UserService, AuthenticationService>(
          update: (context, user, auth) =>
              AuthenticationService(FirebaseAuth.instance, user),
          create: (BuildContext context) => AuthenticationService(
              FirebaseAuth.instance, context.read<UserService>()),
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
