import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/components/call_to_action.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
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
  String? uid;
  List<Pet> personalPets = [];
  List<Pet> communityPets = [];
  List<Pet>? allPets;

  Future<void> getInitData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('user_name');
    uid = prefs.getString('uid');

    try {
      final pets = await PetService().getAllPetsByUID(uid: uid!);
      setState(() {
        allPets = pets;
        personalPets =
            allPets!.where((pet) => pet.petType == "personal").toList();
        communityPets =
            allPets!.where((pet) => pet.petType == "community").toList();
      });
    } catch (e) {
      // print("Error fetching pets: $e");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    // TODO: Need help ensuring that when Add Pet is done, this function is called
    getInitData();

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
      if (personalPets.isEmpty)
        Text(
          "You have not added a personal pet",
          style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      // // List of Personal Pets
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
      const SizedBoxh10(),
      if (communityPets.isEmpty)
        Text(
          "You have not added a community pet",
          style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
        ),
      // List of Community Pets
      Column(
        children: List.generate(
            communityPets.length,
            (int index) => BuildPetCard(
                  petData: communityPets[index],
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

    // print(petData.imgPath);
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            petData.imgPath == null
                ? const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 41, 41, 41),
                    radius: 60,
                  )
                : CircleAvatar(
                    backgroundImage: Image.network(
                      petData.imgPath!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ).image,
                    radius: 60,
                  ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Post & Fans Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Card(
                            color: customColors.pastelOrange,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  petData.posts.toString(),
                                  style: textStyles.bodyLarge!
                                      .copyWith(color: Colors.white),
                                ),
                                Text(
                                  "Posts",
                                  style: textStyles.bodyMedium!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            )),
                      ),
                      SizedBox(
                        width: 90,
                        child: Card(
                            color: customColors.pastelPurple,
                            child: Column(
                              children: <Widget>[
                                Text(
                                  petData.fans.toString(),
                                  style: textStyles.bodyLarge!
                                      .copyWith(color: Colors.white),
                                ),
                                Text(
                                  "Fans",
                                  style: textStyles.bodyMedium!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                  // Name & Icon
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
                  // Description
                  Text(
                    petData.description,
                    style: textStyles.bodyMedium!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
