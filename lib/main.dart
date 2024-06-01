import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/firebase_options.dart';
import 'package:wagtrack/screens/app_wrapper.dart';
import 'package:wagtrack/screens/authorisation/authenticate.dart';
import 'package:wagtrack/screens/home/home.dart';
import 'package:wagtrack/services/auth.dart';
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
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
            create: (context) => AuthenticationService(FirebaseAuth.instance)),
        StreamProvider(
            create: (context) =>
                context.read<AuthenticationService>().authStateChanges,
            initialData: null)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: true,
        title: 'wagtrack',
        theme: AppTheme.light,
        home: const AppWrapper(),
      ),
    );
  }
}
