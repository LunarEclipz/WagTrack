import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/screens/posts/post_detail_page.dart';
import 'package:wagtrack/services/post_service.dart';
import 'package:wagtrack/services/user_service.dart';

class PetPost extends StatefulWidget {
  final Post post;
  final Pet petData;

  const PetPost({super.key, required this.post, required this.petData});

  @override
  State<PetPost> createState() => _PetPostState();
}

class _PetPostState extends State<PetPost> {
  late Post post;
  late Pet pet;

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final userService = Provider.of<UserService>(context, listen: false);
    var uid = userService.user.uid;

    post = widget.post;
    pet = widget.petData;

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
            pageBuilder: (context, a, b) => PostDetailPage(
              postData: post,
            ),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 2,
        child: Card(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4.0)),
                child: Image(
                  image: NetworkImage(post.media![0]),
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Text(
                  post.title,
                  style: textStyles.bodyMedium,
                ),
              ),
              // Icon, Name, Likes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //Icon
                  pet.imgPath == null
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 41, 41, 41),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            backgroundColor:
                                const Color.fromARGB(255, 41, 41, 41),
                            backgroundImage: Image.network(
                              pet.imgPath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ).image,
                          ),
                        ),

                  // Name
                  SizedBox(
                    width: 75,
                    child: Text(
                      pet.name,
                      style: textStyles.bodySmall,
                    ),
                  ),
                  // Likes
                  SizedBox(
                    width: 40,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (post.likes.contains(uid)) {
                                post.likes.remove(uid);
                              } else {
                                post.likes.add(uid);
                              }
                              PostService().updateLikes(postData: post);
                            });
                          },
                          child: Icon(
                            post.likes.contains(uid)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 30,
                            color: post.likes.contains(uid)
                                ? colorScheme.primary
                                : Colors.black,
                          ),
                        ),
                        Text(
                          post.likes.length.toString(),
                          style: textStyles.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
