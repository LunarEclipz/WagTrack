// Wraps features such as Details, Posts, Symptoms, Medication

import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/medication/medication_frame.dart';
import 'package:wagtrack/screens/misc_pages.dart';
import 'package:wagtrack/screens/pet_details/edit_pet.dart';
import 'package:wagtrack/screens/pet_details/pet_details.dart';
import 'package:wagtrack/screens/posts/pet_posts_page.dart';
import 'package:wagtrack/screens/symptoms/add_symptoms.dart';
import 'package:wagtrack/screens/symptoms/symptoms.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class PetDetailsWrapper extends StatefulWidget {
  final Pet petData;
  const PetDetailsWrapper({super.key, required this.petData});

  @override
  State<PetDetailsWrapper> createState() => _PetDetailsWrapperState();
}

class _PetDetailsWrapperState extends State<PetDetailsWrapper> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
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

        // to remove the change of color when scrolling
        forceMaterialTransparency: true,
        actions: <Widget>[
          petData.imgPath == null
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 41, 41, 41),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundImage: Image.network(
                      petData.imgPath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ).image,
                  ),
                ),
        ],
      ), // Floating Action Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // SYMPTOM HELP BUTTON (symptoms tab)
          // TODO these Floating action buttons can and should be refactored!
          if (currentPageIndex == 2)
            FloatingActionButton(
              heroTag: "helpSymptoms",
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
                    transitionDuration: const Duration(
                        milliseconds: 300), // Adjust the duration here
                    pageBuilder: (context, a, b) => const WorkInProgressPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.question_mark_rounded,
                color: Colors.white,
              ),
            ),
          const SizedBoxh20(),

          // ADD SYMPTOM BUTTON (symptoms tab)
          if (currentPageIndex == 2)
            FloatingActionButton(
              heroTag: "addSymptoms",
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
                    transitionDuration: const Duration(
                        milliseconds: 300), // Adjust the duration here
                    pageBuilder: (context, a, b) => AddSymptomsPage(
                      petData: petData,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),

          // EDIT BUTTON on MAIN PET TAB
          if (currentPageIndex == 0)
            FloatingActionButton(
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
                    transitionDuration: const Duration(
                        milliseconds: 300), // Adjust the duration here
                    pageBuilder: (context, a, b) => EditPetPage(
                      petData: petData,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
              ),
            ),
        ],
      ),
      // Screens
      body: BackgroundImageWrapper(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              NavigationBar(
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
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

                  // Bottom Navigation
                ],
                backgroundColor: colorScheme.surface,
                shadowColor: Colors.transparent,
                elevation: 0.0,
              ),
              if (currentPageIndex == 0)
                PetDetails(
                  petData: petData,
                ),
              if (currentPageIndex == 1)
                PetPostsPage(
                  petData: petData,
                ),
              if (currentPageIndex == 2)
                SymptomsPage(
                  petData: petData,
                ),
              if (currentPageIndex == 3)
                MedicationFrame(
                  petData: petData,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
