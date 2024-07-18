import 'package:wagtrack/models/pet_model.dart';

class PetPostModel {
  late Pet pet;
  late List<Post> posts;
}

class Post {
  /// Post ID
  String? oid;

  /// List of Pet IDs this post belongs to
  late List<String> petID;

  /// Name of Pets this post belongs to
  late List<String> petName;

  /// Boolean of whether the post is hidden or public
  late bool visibility;

  /// Image of Pet this post belongs to
  late List<String> petImgUrl;

  /// Number of likes this post has
  late int likes;

  /// Number of saves this post has
  late int saves;

  /// Category of this Post
  late String category;

  /// Title of this Post
  late String title;

  /// Caption of this Post
  late String caption;

  /// List of Media of this Post
  late List<String>? media;

  /// Location of this Post
  late String location;

  /// Date of this Post
  late DateTime date;

  /// Comments of this Post
  late List<Comment> comments;

  /// Constructor
  Post({
    this.oid,
    required this.petID,
    required this.petName,
    required this.visibility,
    required this.petImgUrl,
    required this.likes,
    required this.saves,
    required this.category,
    required this.title,
    required this.caption,
    this.media,
    required this.location,
    required this.date,
    required this.comments,
  });
}

class Comment {
  /// Content of Comment
  late String comment;

  /// Name of Commentor
  late String commentor;

  /// ID of Commentor
  late String commentorID;

  Comment(
      {required this.comment,
      required this.commentor,
      required this.commentorID});
}
