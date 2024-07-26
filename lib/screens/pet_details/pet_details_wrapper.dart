// Wraps features such as Details, Posts, Symptoms, Medication

import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/medication/meds_overview_page.dart';
import 'package:wagtrack/screens/medication/meds_routine/meds_add_routine.dart';
import 'package:wagtrack/screens/medication/meds_routine/meds_routine_page.dart';
import 'package:wagtrack/screens/medication/meds_sessions_page.dart';
import 'package:wagtrack/screens/pet_details/edit_pet.dart';
import 'package:wagtrack/screens/pet_details/pet_details.dart';
import 'package:wagtrack/screens/posts/add_post_page.dart';
import 'package:wagtrack/screens/posts/pet_posts_page.dart';
import 'package:wagtrack/screens/symptoms/add_symptoms.dart';
import 'package:wagtrack/screens/symptoms/help_symptoms.dart';
import 'package:wagtrack/screens/symptoms/symptoms.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class PetDetailsWrapper extends StatefulWidget {
  final Pet petData;
  const PetDetailsWrapper({super.key, required this.petData});

  @override
  State<PetDetailsWrapper> createState() => _PetDetailsWrapperState();
}

class _PetDetailsWrapperState extends State<PetDetailsWrapper>
    with TickerProviderStateMixin {
  int currentPetPageIndex = 0;

  /// to control the medical tabs
  late final TabController _medicalTabController;
  int _selectedTabMedical = 0;

  @override
  void initState() {
    super.initState();
    _medicalTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _medicalTabController.dispose();
    super.dispose();
  }

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
                    backgroundColor: const Color.fromARGB(255, 41, 41, 41),
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
          if (currentPetPageIndex == 2)
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
                    pageBuilder: (context, a, b) => const HelpSymptoms(),
                  ),
                );
              },
              child: const Icon(
                Icons.question_mark_rounded,
                color: Colors.white,
              ),
            ),
          const SizedBoxh20(),

          // ADD POST BUTTON (posts tab)
          if (currentPetPageIndex == 1)
            FloatingActionButton(
              heroTag: "addPost",
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
                    pageBuilder: (context, a, b) => AddPostPage(
                      pet: petData,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),

          // ADD SYMPTOM BUTTON (symptoms tab)
          if (currentPetPageIndex == 2)
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
          if (currentPetPageIndex == 0)
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

          // ADD ROUTINE Button on pet tab 3, medication tab 0
          if (currentPetPageIndex == 3 && _selectedTabMedical == 0)
            FloatingActionButton(
              heroTag: "addRoutine",
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
                    pageBuilder: (context, a, b) => MedsAddRoutine(
                      petData: widget.petData,
                    ),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
        ],
      ),

      // Main Screens
      body: BackgroundImageWrapper(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              NavigationBar(
                labelBehavior:
                    NavigationDestinationLabelBehavior.onlyShowSelected,
                selectedIndex: currentPetPageIndex,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPetPageIndex = index;
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
              if (currentPetPageIndex == 0)
                PetDetails(
                  petData: petData,
                ),
              if (currentPetPageIndex == 1)
                PetPostsPage(
                  petData: petData,
                ),
              if (currentPetPageIndex == 2)
                SymptomsPage(
                  petData: petData,
                ),
              if (currentPetPageIndex == 3) medicationFrame(context),
            ],
          ),
        ),
      ),
    );
  }

  /// the medication frame
  Widget medicationFrame(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final petData = widget.petData;

    return Column(
      children: [
        TabBar(
          controller: _medicalTabController,
          unselectedLabelColor: Colors.grey,
          labelColor: colorScheme.tertiary,
          indicatorColor: colorScheme.tertiary,
          tabs: const [
            Tab(
                child: Text(
              'Routine',
              style: TextStyle(fontSize: 20),
            )),
            Tab(
                child: Text(
              'Sessions',
              style: TextStyle(fontSize: 20),
            )),
            Tab(
                child: Text(
              'Records',
              // used to be overview
              style: TextStyle(fontSize: 20),
            ))
          ],
          onTap: (index) {
            setState(() {
              _selectedTabMedical = index;
            });
          },
        ),
        const SizedBoxh10(),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (_) {
              switch (_selectedTabMedical) {
                case 0:
                  return MedsRoutinePage(
                    petData: petData,
                  );
                case 1:
                  return MedsSessionsPage(
                    petData: petData,
                  );
                case 2:
                  return MedsOverviewPage(
                    petData: petData,
                  );
                default:
                  return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}
