import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/services/post_service.dart';
import 'package:wagtrack/services/user_service.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/utils.dart';

class PostDetailPage extends StatefulWidget {
  final Post postData;
  const PostDetailPage({super.key, required this.postData});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  late Post post;
  late int _carouselIndex = 0;
  late bool liked = false;
  late bool saved = false;
  late String uid = "";
  late String name = "";
  late String replyToName = "";
  late String replyTouid = "";
  late int commentIndex = 0;

  late TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    post = widget.postData;

    final userService = Provider.of<UserService>(context, listen: false);
    final postService = Provider.of<PostService>(context, listen: false);
    uid = userService.user.uid;
    name = userService.user.name!;
    liked = post.likes.contains(uid);

    return Scaffold(
        resizeToAvoidBottomInset: true,

        // App Bar
        appBar: AppBar(
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[],
          ),

          // to remove the change of color when scrolling
          forceMaterialTransparency: true,
        ),
        body: Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: BackgroundImageWrapper(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.media!.isNotEmpty)
                        Column(
                          children: [
                            SizedBox(
                              height: 300,
                              width: double.infinity,
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  autoPlay: true,
                                  aspectRatio: 1,
                                  enlargeCenterPage: true,
                                  enlargeStrategy:
                                      CenterPageEnlargeStrategy.scale,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      _carouselIndex = index;
                                    });
                                  },
                                ),
                                items: post.media!
                                    .map((item) => SizedBox(
                                          height: 300,
                                          child: Center(
                                            child: Image(
                                              image: NetworkImage(item),
                                              fit: BoxFit.fitWidth,
                                              width: double.infinity,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                            // Carousel Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: post.media!.map(
                                (image) {
                                  int index = post.media!.indexOf(image);
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _carouselIndex == index
                                            ? const Color.fromRGBO(0, 0, 0, 0.9)
                                            : const Color.fromRGBO(
                                                0, 0, 0, 0.4)),
                                  );
                                },
                              ).toList(),
                            ),
                          ],
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: textStyles.bodyLarge,
                            ),
                            const SizedBoxh10(),
                            Text(
                              post.caption,
                              style: textStyles.bodyMedium,
                            ),
                            const SizedBoxh20(),
                            Text(
                              formatDateTime(post.date).date,
                              style: textStyles.bodySmall,
                            ),
                            const SizedBoxh20(),
                            const SizedBoxh20(),
                            const SizedBoxh20(),
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              runSpacing: 10,
                              spacing: 10,
                              children:
                                  List.generate(post.petImgUrl.length, (index) {
                                return post.petImgUrl[index] == null
                                    ? const CircleAvatar(
                                        radius: 30,
                                        backgroundColor:
                                            Color.fromARGB(255, 41, 41, 41),
                                      )
                                    : CircleAvatar(
                                        radius: 30,
                                        backgroundColor: const Color.fromARGB(
                                            255, 41, 41, 41),
                                        backgroundImage: Image.network(
                                          post.petImgUrl[index],
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        ).image,
                                      );
                              }),
                            ),
                            const SizedBoxh10(),

                            // Comment Section Starts
                            Text(
                              "${post.comments.length} comments",
                              style: textStyles.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBoxh20(),

                            if (post.comments.isNotEmpty)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(post.comments.length,
                                    (index) {
                                  return InkWell(
                                    onTap: () {
                                      setState(() {
                                        replyTouid =
                                            post.comments[index].commentorID;
                                        replyToName =
                                            post.comments[index].commentor;
                                        commentIndex = index;
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: post
                                                          .comments[index]
                                                          .commentorID ==
                                                      uid
                                                  ? Colors.amber
                                                  : Colors.blue,
                                              child: const Icon(
                                                Icons.person_2_rounded,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      post.comments[index]
                                                          .commentor,
                                                      style: textStyles
                                                          .bodyMedium!
                                                          .copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    if (post.comments[index]
                                                            .commentorID ==
                                                        uid)
                                                      Container(
                                                        decoration: const BoxDecoration(
                                                            color: Colors.amber,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            10))),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(
                                                                  8, 0, 8, 0),
                                                          child: Text(
                                                            "Creator",
                                                            style: textStyles
                                                                .bodySmall!
                                                                .copyWith(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                          ),
                                                        ),
                                                      )
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      100,
                                                  child: Text(post
                                                      .comments[index].comment),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        // SUB Comments Start
                                        if (post.comments[index].subComments
                                            .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              left: 60.0,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: List.generate(
                                                  post
                                                      .comments[index]
                                                      .subComments
                                                      .length, (sindex) {
                                                return Column(
                                                  children: [
                                                    const SizedBoxh20(),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        CircleAvatar(
                                                          backgroundColor: post
                                                                      .comments[
                                                                          index]
                                                                      .subComments[
                                                                          sindex]
                                                                      .commentorID ==
                                                                  uid
                                                              ? Colors.amber
                                                              : Colors.blue,
                                                          child: const Icon(
                                                            Icons
                                                                .person_2_rounded,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(
                                                                  post
                                                                      .comments[
                                                                          index]
                                                                      .subComments[
                                                                          sindex]
                                                                      .commentor,
                                                                  style: textStyles
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                ),
                                                                const SizedBox(
                                                                  width: 10,
                                                                ),
                                                                if (post
                                                                        .comments[
                                                                            index]
                                                                        .subComments[
                                                                            sindex]
                                                                        .commentorID ==
                                                                    uid)
                                                                  Container(
                                                                    decoration: const BoxDecoration(
                                                                        color: Colors
                                                                            .amber,
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(10))),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                          .fromLTRB(
                                                                          8,
                                                                          0,
                                                                          8,
                                                                          0),
                                                                      child:
                                                                          Text(
                                                                        "Creator",
                                                                        style: textStyles.bodySmall!.copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  160,
                                                              child: Text(post
                                                                  .comments[
                                                                      index]
                                                                  .subComments[
                                                                      sindex]
                                                                  .comment),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                              }),
                                            ),
                                          ),
                                        const SizedBoxh20()
                                      ],
                                    ),
                                  );
                                }),
                              )
                          ],
                        ),
                        // Comment Section Ends
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 4,
                      )
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Material(
                elevation: 20,
                child: Container(
                  height: 110,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Comment box
                        AppTextFormField(
                          showOptional: true,
                          controller: commentController,
                          hintText: replyToName == ""
                              ? "Comment ..."
                              : "Reply to $replyToName",
                        ),
                        // Actions : Like, Save, Share
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                // InkWell(
                                //   onTap: () {
                                //     setState(() {
                                //       saved = !saved;
                                //     });
                                //   },
                                //   child: Icon(
                                //     saved
                                //         ? Icons.bookmark_rounded
                                //         : Icons.bookmark_border_rounded,
                                //     size: 30,
                                //     color: saved
                                //         ? colorScheme.primary
                                //         : Colors.black,
                                //   ),
                                // ),
                                // const SizedBox(
                                //   width: 20,
                                // ),
                                InkWell(
                                  onTap: () {
                                    Share.share('${post.media}');
                                  },
                                  child: const Icon(
                                    Icons.share_rounded,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                            if (replyToName != "")
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    replyToName = "";
                                    replyTouid = "";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10))),
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 0, 12, 0),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.clear_rounded,
                                          size: 25,
                                          color: Colors.white,
                                        ),
                                        Text("Reply",
                                            style: textStyles.bodyLarge!
                                                .copyWith(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (liked) {
                                        post.likes.remove(uid);
                                      } else {
                                        post.likes.add(uid);
                                      }
                                      PostService().updateLikes(postData: post);
                                    });
                                  },
                                  child: Icon(
                                    liked
                                        ? Icons.favorite_rounded
                                        : Icons.favorite_border_rounded,
                                    size: 30,
                                    color: liked
                                        ? colorScheme.primary
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (commentController.text != "" &&
                                        replyToName == "") {
                                      setState(() {
                                        post.comments.add(Comment(
                                            comment: commentController.text,
                                            commentor: name,
                                            commentorID: uid,
                                            subComments: []));
                                        commentController.text = "";
                                        PostService()
                                            .updateComment(postData: post);
                                      });
                                    }
                                    if (commentController.text != "" &&
                                        replyToName != "") {
                                      setState(() {
                                        post.comments[commentIndex].subComments
                                            .add(SubComment(
                                          comment: commentController.text,
                                          commentor: replyToName,
                                          commentorID: replyTouid,
                                        ));
                                        commentController.text = "";
                                        PostService()
                                            .updateComment(postData: post);
                                      });
                                    }
                                  },
                                  child: const Icon(
                                    Icons.send_rounded,
                                    size: 30,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}
