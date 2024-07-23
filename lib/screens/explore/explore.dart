import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/screens/posts/pet_post.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/post_service.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';

class Explore extends StatefulWidget {
  const Explore({super.key});

  @override
  State<Explore> createState() => _ExploreState();
}

class _ExploreState extends State<Explore> with TickerProviderStateMixin {
  late final TabController _tabController;

  int _selectedTab = 0;

  late List<Post> posts = [];
  late List<Post> tempPosts = [];
  late List<Post> evenPosts = [];
  late List<Post> oddPosts = [];
  late List<Post> forMe = [];
  late List<Post> forMetempPosts = [];
  late List<Post> forMeevenPosts = [];
  late List<Post> forMeoddPosts = [];
  List<Pet> personalPets = [];
  List<Pet> communityPets = [];
  List<Pet> allPets = [];
  late String filterSelected = "All";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final petService = Provider.of<PetService>(context, listen: false);
    personalPets = petService.personalPets;
    communityPets = petService.communityPets;
    allPets = personalPets + communityPets;
    List<String> allPetIDs = allPets.map((pet) => pet.petID!).toList();
    getAllPosts(petIDs: allPetIDs);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void getAllPosts({required List<String> petIDs}) async {
    posts = await PostService().getAllPostsByPetID(petIDs: petIDs);
    List<Post> forMePosts = await PostService().getAllPostsByTime();

    setState(() {
      posts = posts;
      tempPosts = posts;
      forMe = forMePosts;
      forMetempPosts = forMePosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    evenPosts = [];
    oddPosts = [];
    forMeevenPosts = [];
    forMeoddPosts = [];
    if (filterSelected == "All") {
      posts = tempPosts;
      for (int i = 0; i < posts.length; i++) {
        if (i % 2 == 0) {
          evenPosts.add(posts[i]);
        } else {
          oddPosts.add(posts[i]);
        }
      }
    } else {
      posts = tempPosts
          .where((object) => object.category == filterSelected)
          .toList();
      for (int i = 0; i < posts.length; i++) {
        if (i % 2 == 0) {
          evenPosts.add(posts[i]);
        } else {
          oddPosts.add(posts[i]);
        }
      }
    }
    if (filterSelected == "All") {
      forMe = forMetempPosts;
      for (int i = 0; i < forMe.length; i++) {
        if (i % 2 == 0) {
          forMeevenPosts.add(forMe[i]);
        } else {
          forMeoddPosts.add(forMe[i]);
        }
      }
    } else {
      forMe = forMetempPosts
          .where((object) => object.category == filterSelected)
          .toList();
      for (int i = 0; i < forMe.length; i++) {
        if (i % 2 == 0) {
          forMeevenPosts.add(forMe[i]);
        } else {
          forMeoddPosts.add(forMe[i]);
        }
      }
    }
    return AppScrollableNoPaddingPage(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0.0),
          child: Text(
            "Explore",
            style: textStyles.headlineMedium,
          ),
        ),
        Column(
          children: [
            TabBar(
              controller: _tabController,
              unselectedLabelColor: Colors.grey,
              labelColor: colorScheme.tertiary,
              indicatorColor: colorScheme.tertiary,
              tabs: const [
                Tab(
                    child: Text(
                  'For Me',
                  style: TextStyle(fontSize: 20),
                )),
                // Tab(
                //     child: Text(
                //   'Following',
                //   style: TextStyle(fontSize: 20),
                // )),
                Tab(
                    child: Text(
                  'My Posts',
                  style: TextStyle(fontSize: 20),
                ))
              ],
              onTap: (index) {
                setState(() {
                  _selectedTab = index;
                });
              },
            ), // Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(postCategory.length + 1, (index) {
                  return index == 0
                      ? InkWell(
                          onTap: () {
                            setState(() {
                              filterSelected = "All";
                            });
                          },
                          child: Text(
                            "All",
                            style: filterSelected == "All"
                                ? textStyles.bodyLarge
                                : textStyles.bodyMedium,
                          ))
                      : InkWell(
                          onTap: () {
                            setState(() {
                              filterSelected = postCategory[index - 1];
                            });
                          },
                          child: Text(
                            postCategory[index - 1],
                            style: filterSelected == postCategory[index - 1]
                                ? textStyles.bodyLarge
                                : textStyles.bodyMedium,
                          ));
                }),
              ),
            ),
            const SizedBoxh10(),

            Builder(
              builder: (_) {
                switch (_selectedTab) {
                  case 0:
                    // For Me
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            children:
                                List.generate(forMeevenPosts.length, (index) {
                          return PetPost(
                            post: forMeevenPosts[index],
                          );
                        })),
                        Column(
                            children:
                                List.generate(forMeoddPosts.length, (index) {
                          return PetPost(
                            post: forMeoddPosts[index],
                          );
                        })),
                      ],
                    );
                  case 1:
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            children: List.generate(evenPosts.length, (index) {
                          return PetPost(
                            post: evenPosts[index],
                          );
                        })),
                        Column(
                            children: List.generate(oddPosts.length, (index) {
                          return PetPost(
                            post: oddPosts[index],
                          );
                        })),
                      ],
                    );
                  default:
                    return Container();
                }
              },
            ),

            // SizedBox(
            //   height: screenHeight,
            //   width: screenWidth,
            //   child: TabBarView(
            //     controller: _tabController,
            //     children: [
            //       // For Me
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Column(
            //               children:
            //                   List.generate(forMeevenPosts.length, (index) {
            //             return PetPost(
            //               post: forMeevenPosts[index],
            //             );
            //           })),
            //           Column(
            //               children:
            //                   List.generate(forMeoddPosts.length, (index) {
            //             return PetPost(
            //               post: forMeoddPosts[index],
            //             );
            //           })),
            //         ],
            //       ),
            //       // // Following
            //       // const Padding(
            //       //   padding: EdgeInsets.all(8.0),
            //       //   child: SizedBox(),
            //       // ),
            //       // My Posts
            //       Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Column(
            //               children: List.generate(evenPosts.length, (index) {
            //             return PetPost(
            //               post: evenPosts[index],
            //             );
            //           })),
            //           Column(
            //               children: List.generate(oddPosts.length, (index) {
            //             return PetPost(
            //               post: oddPosts[index],
            //             );
            //           })),
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ],
        )
      ],
    );
  }
}
