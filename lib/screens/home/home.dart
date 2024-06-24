import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/home/pet_details_wrapper.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/user_service.dart';
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
  bool loaded = false;

  @override
  void initState() {
    super.initState();
  }

  void getAllPets() async {
    final UserService userService = context.watch<UserService>();
    uid = userService.user.uid;
    final PetService petService = context.watch<PetService>();
    List<Pet> pets = await PetService().getAllPetsByUID(uid: uid!);
    petService.setPersonalCommunityPets(pets: pets);
    personalPets = petService.personalPets;
    communityPets = petService.communityPets;
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final UserService userService = context.watch<UserService>();
    final PetService petService = context.watch<PetService>();

    name = userService.user.name;
    uid = userService.user.uid;
    if (!loaded) {
      getAllPets();
      setState(() {
        loaded = true;
      });
    }
    personalPets = petService.personalPets;
    communityPets = petService.communityPets;

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

    print(petData.toJSON());
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            transitionDuration:
                const Duration(milliseconds: 500), // Adjust the duration here
            pageBuilder: (context, a, b) => PetDetailsWrapper(
              petData: petData,
            ),
          ),
        );
      },
      child: Card(
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
      ),
    );
  }
}
