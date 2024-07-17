import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wagtrack/models/post_model.dart';

class PetPost extends StatefulWidget {
  final Post post;
  const PetPost({super.key, required this.post});

  @override
  State<PetPost> createState() => _PetPostState();
}

class _PetPostState extends State<PetPost> {
  late Post post;
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    post = widget.post;
    print(post.media[0]);

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
      child: Card(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            if (post.media.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(4.0)),
                child: Image(
                  image: NetworkImage(post.media[0]),
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
                post.petImgUrl == null
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
                            post.petImgUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ).image,
                        ),
                      ),

                // Name
                SizedBox(
                  width: 75,
                  child: Text(
                    post.petName,
                    style: textStyles.bodySmall,
                  ),
                ),
                // Likes
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      const Icon(Icons.favorite, color: Colors.pink),
                      Text(
                        post.likes.toString(),
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
    );
  }
}
