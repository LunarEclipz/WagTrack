import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/main.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/screens/posts/pet_post.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/services/post_service.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';

class PetPostsPage extends StatefulWidget {
  final Pet petData;

  const PetPostsPage({super.key, required this.petData});

  @override
  State<PetPostsPage> createState() => _PetPostsPageState();
}

class _PetPostsPageState extends State<PetPostsPage> {
  late String filterSelected = "All";
  late List<Post> posts = [];
  late List<Post> tempPosts = [];
  late List<Post> evenPosts = [];
  late List<Post> oddPosts = [];

  void getAllPosts({required List<String> petIDs}) async {
    posts =
        await PostService().getAllPostsByPetID(petIDs: [widget.petData.petID!]);
    tempPosts = posts;
  }

  @override
  void initState() {
    super.initState();
    getAllPosts(petIDs: [widget.petData.petID!]);
  }

  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;

    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textStyles = Theme.of(context).textTheme;
    evenPosts = [];
    oddPosts = [];
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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

        // Posts
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
                children: List.generate(evenPosts.length, (index) {
              return PetPost(post: evenPosts[index], petData: petData);
            })),
            Column(
                children: List.generate(oddPosts.length, (index) {
              return PetPost(post: oddPosts[index], petData: petData);
            })),
          ],
        )
      ],
    );
  }
}
