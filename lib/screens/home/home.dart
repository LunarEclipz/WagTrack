import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/home/add_pet.dart';
import 'package:wagtrack/screens/settings/app_settings.dart';
import 'package:wagtrack/shared/components/call_to_action.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/mock_data.dart';
import 'package:wagtrack/shared/themes.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;

  /// Loads username - MOVE TODO:
  void getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('user_name');
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    getName();
    return AppScrollablePage(children: <Widget>[
      Text(
        "Welcome Back ${name ?? ''}",
        style: textStyles.headlineMedium,
      ),
      const SizedBoxh20(),
      CallToActionButton(
        icon: Icons.book_rounded,
        title: "Pet Care Resources",
        text: "Pet Care Resources at Your Fingertips! Click to learn more ...",
        color: AppTheme.customColors.pastelBlue,
        onTap: () {},
      ),
      const SizedBoxh20(),
      Text(
        "My Pets",
        style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(
        "You have not added a personal pet",
        style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      ),
      // List of Personal Pets
      Column(
        children: List.generate(
            personalPets.length,
            (int index) => BuildPetCard(
                  petData: personalPets[index],
                )),
      ),
      const SizedBoxh20(),
      Text(
        "Community Pets",
        style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(
        "You have not added a community pet",
        style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      ),
      // List of Community Pets
      Column(
        children: List.generate(
            communityPets.length,
            (int index) => BuildPetCard(
                  petData: personalPets[index],
                )),
      ),
    ]);
  }
}

// Cards to display both Community and Personal pets in home

class BuildPetCard extends StatefulWidget {
  final Pet petData;
  const BuildPetCard({super.key, required this.petData});

  @override
  State<BuildPetCard> createState() => _PetCardState();
}

class _PetCardState extends State<BuildPetCard> {
  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;
    final TextTheme textStyles = Theme.of(context).textTheme;
    final CustomColors customColors = AppTheme.customColors;

    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 41, 41, 41),
              radius: 60,
            ),
            const SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Text(
                      petData.name,
                      style: textStyles.bodyLarge,
                    ),
                    if (petData.sex == "Male") const Icon(Icons.male),
                    if (petData.sex == "Female") const Icon(Icons.female),
                  ],
                ),
                Text(
                  petData.description,
                  style: textStyles.bodyMedium!
                      .copyWith(fontStyle: FontStyle.italic),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 75,
                      child: Card(
                          child: Column(
                        children: <Widget>[
                          Text(
                            petData.posts.toString(),
                            style: textStyles.bodyLarge,
                          ),
                          Text(
                            "Posts",
                            style: textStyles.bodyMedium,
                          ),
                        ],
                      )),
                    ),
                    SizedBox(
                      width: 75,
                      child: Card(
                          child: Column(
                        children: <Widget>[
                          Text(
                            petData.fans.toString(),
                            style: textStyles.bodyLarge,
                          ),
                          Text(
                            "Fans",
                            style: textStyles.bodyMedium,
                          ),
                        ],
                      )),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
