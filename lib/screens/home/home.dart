import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/screens/home/pet_resources.dart';
import 'package:wagtrack/screens/pet_details/pet_details_wrapper.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/post_service.dart';
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
  String name = "";
  String? uid;
  List<Pet> personalPets = [];
  List<Pet> communityPets = [];
  List<Pet> allPets = [];

  List<Post> allPosts = [];

  /// Init
  @override
  void initState() {
    super.initState();

    /// load pets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userService = Provider.of<UserService>(context, listen: false);
      final petService = Provider.of<PetService>(context, listen: false);
      final postService = Provider.of<PostService>(context, listen: false);
      allPosts = postService.posts;
      uid = userService.user.uid;
      name = userService.user.name!;
      getAllPets(uid, petService);
    });
  }

  void getAllPosts({required List<String> petIDs}) async {
    List<Post> posts = await PostService().getAllPostsByPetID(petIDs: petIDs);
    setState(() {
      allPosts = posts;
      PostService().setPosts(listOfPosts: posts);
    });
  }

  void getAllPets(String? uid, PetService petService) async {
    List<Pet> pets = await petService.getAllPetsByUID(uid: uid!);
    petService.setPersonalCommunityPets(pets: pets);
    personalPets = petService.personalPets;
    communityPets = petService.communityPets;
    allPets = personalPets + communityPets;
    List<String> allPetIDs = allPets.map((pet) => pet.petID!).toList();
    getAllPosts(petIDs: allPetIDs);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    // always have to initialise these for the PostFrameCallback
    final UserService userService = context.watch<UserService>();
    final PetService petService = context.watch<PetService>();
    personalPets = petService.personalPets;
    communityPets = petService.communityPets;

    return AppScrollablePage(children: <Widget>[
      Text(
        name.isEmpty
            ? "Welcome Back ${name ?? ''}"
            : "Welcome Back ${name ?? ''}",
        style: textStyles.headlineMedium,
      ),
      const SizedBoxh20(),
      CallToActionButton(
        icon: Icons.book_rounded,
        title: "Pet Care Resources",
        text: "Pet Care Resources at Your Fingertips! Click to learn more ...",
        color: AppTheme.customColors.pastelBlue,
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
                  const Duration(milliseconds: 300), // Adjust the duration here
              pageBuilder: (context, a, b) => const PetCareResourcesPage(),
            ),
          );
        },
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
                  revPosts: PostService().getPostsByPetId(
                      targetPetID: personalPets[index].petID!, posts: allPosts),
                  petData: personalPets[index],
                )),
      ),
      const SizedBoxh20(),
      // ListView.separated(
      //   itemBuilder: (BuildContext context, int index) => BuildPetCard(
      //     petData: personalPets[index],
      //   ),
      //   separatorBuilder: (BuildContext context, int index) => Container(),
      //   itemCount: personalPets.length,
      //   physics: const ClampingScrollPhysics(),
      //   shrinkWrap: true,
      // ),
      // const SizedBoxh20(),

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
                  revPosts: context.read<PostService>().getPostsByPetId(
                      targetPetID: communityPets[index].petID!,
                      posts: allPosts),
                  petData: communityPets[index],
                )),
      ),
    ]);
  }
}

// Cards to display both Community and Personal pets in home

class BuildPetCard extends StatefulWidget {
  final Pet petData;
  final List<Post> revPosts;
  const BuildPetCard(
      {super.key, required this.petData, required this.revPosts});

  @override
  State<BuildPetCard> createState() => _PetCardState();
}

class _PetCardState extends State<BuildPetCard> {
  late String likes;
  late String posts;

  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;
    final TextTheme textStyles = Theme.of(context).textTheme;
    final CustomColors customColors = AppTheme.customColors;
    try {
      likes = widget.revPosts
          .map((item) => item.likes.length)
          .reduce((a, b) => a + b)
          .toString();
    } catch (e) {
      likes = "0";
    }
    posts = widget.revPosts.length.toString();
    // print(petData.toJSON());
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
                                    posts,
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
                                    likes,
                                    style: textStyles.bodyLarge!
                                        .copyWith(color: Colors.white),
                                  ),
                                  Text(
                                    "Likes",
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
