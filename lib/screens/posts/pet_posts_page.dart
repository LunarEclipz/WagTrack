import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/screens/posts/pet_post.dart';
import 'package:wagtrack/services/pet_service.dart';
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
  late Post dummy1 = Post(
      oid: "oid",
      petID: "petID",
      petName: "Maxx",
      visibility: true,
      petImgUrl:
          "https://firebasestorage.googleapis.com/v0/b/wagtrack-41427.appspot.com/o/petProfile%2FLmXcbMc2dsNjLvamMufoAhYZJDu2%2F1000048086.png?alt=media&token=f31e2ebc-358c-4f17-ae39-8407d6916dc3",
      likes: 32,
      saves: 1,
      category: "Health",
      title:
          "My dog is so crazy, he is having the time of his life! Go... Buddy!",
      caption: "caption",
      location: "location",
      date: "date",
      comments: [],
      media: [
        "https://assets3.thrillist.com/v1/image/2721811/335x596/scale;webp=auto;jpeg_quality=60.jpg"
      ]);
  late Post dummy2 = Post(
      oid: "oid",
      petID: "petID",
      petName: "Coco Licious Deli Crazy Orphie Tan",
      visibility: true,
      petImgUrl:
          "https://firebasestorage.googleapis.com/v0/b/wagtrack-41427.appspot.com/o/petProfile%2FLmXcbMc2dsNjLvamMufoAhYZJDu2%2F1000048086.png?alt=media&token=f31e2ebc-358c-4f17-ae39-8407d6916dc3",
      likes: 3412,
      saves: 1,
      category: "Health",
      title:
          "My dog is so crazy, he is having the time of his life! Go... Buddy!",
      caption: "caption",
      location: "location",
      date: "date",
      comments: [],
      media: [
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRicMrz0JAkVSzEmUeaaMXd1ZpIZjNjxiBngA&s"
      ]);
  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;

    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textStyles = Theme.of(context).textTheme;

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
              children: [
                PetPost(post: dummy1),
                PetPost(post: dummy2),
                PetPost(post: dummy2),
                PetPost(post: dummy1),
                PetPost(post: dummy2)
              ],
            ),
            Column(
              children: [
                PetPost(post: dummy2),
                PetPost(post: dummy2),
                PetPost(post: dummy1),
                PetPost(post: dummy2),
                PetPost(post: dummy2)
              ],
            ),
          ],
        )
      ],
    );
  }
}
