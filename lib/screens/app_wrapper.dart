import 'package:flutter/material.dart';
import 'package:wagtrack/screens/explore/explore.dart';
import 'package:wagtrack/screens/home/add_pet.dart';
import 'package:wagtrack/screens/home/home.dart';
import 'package:wagtrack/screens/notifications/notifications.dart';
import 'package:wagtrack/screens/reports/reports.dart';
import 'package:wagtrack/screens/settings/app_settings.dart';

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPageIndex = 0;

  List<Widget> screens = [
    const Home(),
    const Reports(),
    const Notifications(),
    const Explore()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: Image.asset(
          "assets/wagtrack_v1.png",
          height: 50,
          fit: BoxFit.fitHeight,
        ),
        actions: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.ease;
                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(
                      milliseconds: 500), // Adjust the duration here
                  pageBuilder: (context, a, b) => const AppSettings(),
                ),
              );
            }, // Transition to Application Setting Screen
            child: const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Icon(Icons.settings),
            ),
          )
        ],
      ),
      // Screens
      body: screens.elementAt(currentPageIndex),
      // Floating Action Buttons
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
              transitionDuration:
                  const Duration(milliseconds: 500), // Adjust the duration here
              pageBuilder: (context, a, b) => const AddPetPage(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      // Bottom Navigation
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.newspaper_rounded),
            icon: Icon(Icons.newspaper_outlined),
            label: 'Reports',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.notifications),
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
        ],
      ),
    );
  }
}
