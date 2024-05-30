import 'package:flutter/material.dart';
import 'package:wagtrack/screens/settings/app_settings.dart';
import 'package:wagtrack/shared/components/call_to_action.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/themes.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

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
                  transitionDuration:
                      const Duration(seconds: 2), // Adjust the duration here
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
      // Body
      body: AppScrollablePage(children: <Widget>[
        Text(
          "Welcome Back Damien",
          style: textStyles.headlineMedium,
        ),
        const SizedBox(
          height: 20,
        ),
        CallToActionButton(
          icon: Icons.book_rounded,
          title: "Pet Care Resources",
          text:
              "Pet Care Resources at Your Fingertips! Click to learn more ...",
          color: AppTheme.customColors.pastelBlue,
          onTap: () {},
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "My Pets",
          style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "You have not added a personal pet",
          style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
        const SizedBox(
          height: 20,
        ),
        Text(
          "Community Pets",
          style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          "You have not added a community pet",
          style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      ]),
      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
