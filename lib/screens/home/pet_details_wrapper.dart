// Wraps features such as Details, Posts, Symptoms, Medication

import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/symptoms/add_symptoms.dart';
import 'package:wagtrack/screens/symptoms/symptoms.dart';

class PetDetailsWrapper extends StatefulWidget {
  final Pet petData;
  const PetDetailsWrapper({super.key, required this.petData});

  @override
  State<PetDetailsWrapper> createState() => _PetDetailsWrapperState();
}

class _PetDetailsWrapperState extends State<PetDetailsWrapper> {
  int currentPageIndex = 0;

  List<Widget> screens = [
    const SymptomsPage(),
    const SymptomsPage(),
    const SymptomsPage(),
    const SymptomsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final petData = widget.petData;
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              petData.name,
              style: textStyles.bodyLarge,
            ),
            Text(
              petData.description,
              style:
                  textStyles.bodyMedium!.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: const <Widget>[],
      ), // Floating Action Buttons
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
              pageBuilder: (context, a, b) => const AddSymptoms(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      // Screens
      body: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.pets),
            label: 'Details',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.feed_rounded),
            icon: Icon(Icons.feed_rounded),
            label: 'Posts',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.thermostat_rounded),
            icon: Icon(Icons.thermostat_rounded),
            label: 'Symptoms',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.medical_information_rounded),
            icon: Icon(Icons.medical_information_rounded),
            label: 'Medications',
          ),
          // screens.elementAt(currentPageIndex),

          // Bottom Navigation
        ],
      ),
    );
  }
}
