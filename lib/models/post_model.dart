import 'package:wagtrack/models/pet_model.dart';

class PetPostModel {
  late Pet pet;
  late List<Post> posts;
}

class Post {
  /// Post ID
  String? oid;

  /// User's ID
  String uid;

  /// List of Pet IDs this post belongs to
  late List<String> petID;

  /// Name of Pets this post belongs to
  late List<String> petName;

  /// Boolean of whether the post is hidden or public
  late bool visibility;

  /// Image of Pet this post belongs to
  late List<String> petImgUrl;

  /// Number of likes this post has
  late List<String> likes;

  /// Number of saves this post has
  late List<String> saves;

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
    required this.uid,
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

  Map<String, dynamic> toJSON() {
    final postData = {
      "petID": petID,
      "uid": uid,
      "petName": petName,
      "petImgUrl": petImgUrl,
      "visibility": visibility,
      "likes": likes,
      "saves": saves,
      "category": category,
      "title": title,
      "caption": caption,
      "media": media,
      "location": location,
      "date": date.millisecondsSinceEpoch,
      "comments": comments.map((comment) => comment.toJSON()).toList(),
    };
    return postData;
  }

  static Post fromJson(Map<String, dynamic> json) {
    Post post = Post(
      petID: (json["petID"] as List).cast<String>(),
      petName: (json["petName"] as List).cast<String>(),
      visibility: json["visibility"] as bool,
      petImgUrl: (json["petImgUrl"] as List).cast<String>(),
      likes: (json["likes"] as List).cast<String>(),
      saves: (json["saves"] as List).cast<String>(),
      uid: json["uid"] as String,
      category: json["category"] as String,
      title: json["title"] as String,
      caption: json["caption"] as String,
      location: json["location"] as String,
      date: DateTime.fromMillisecondsSinceEpoch(json["date"] as int),
      comments: (json["comments"] as List)
          .map((commentData) => Comment.fromJson(commentData))
          .toList(),
      media: (json["media"] as List).cast<String>(),
    );
    return post;
  }
}

class Comment {
  /// Content of Comment
  late String comment;

  /// Name of Commentor
  late String commentor;

  /// ID of Commentor
  late String commentorID;

  /// List of Sub Comments
  late List<SubComment> subComments;

  Comment(
      {required this.comment,
      required this.commentor,
      required this.commentorID,
      required this.subComments});

  Map<String, dynamic> toJSON() {
    final commentData = {
      "comment": comment,
      "commentor": commentor,
      "commentorID": commentorID,
      "subComments": subComments,
    };
    return commentData;
  }

  static Comment fromJson(Map<String, dynamic> json) {
    Comment comment = Comment(
      comment: json["comment"] as String,
      commentor: json["commentor"] as String,
      commentorID: json["commentorID"] as String,
      subComments: (json["subComments"] as List)
          .map((subCommentsData) => SubComment.fromJson(subCommentsData))
          .toList(),
    );

    return comment;
  }
}

class SubComment {
  /// Content of Comment
  late String comment;

  /// Name of Commentor
  late String commentor;

  /// ID of Commentor
  late String commentorID;

  SubComment(
      {required this.comment,
      required this.commentor,
      required this.commentorID});

  Map<String, dynamic> toJSON() {
    final commentData = {
      "comment": comment,
      "commentor": commentor,
      "commentorID": commentorID,
    };
    return commentData;
  }

  static SubComment fromJson(Map<String, dynamic> json) {
    SubComment subComment = SubComment(
      comment: json["comment"] as String,
      commentor: json["commentor"] as String,
      commentorID: json["commentorID"] as String,
    );

    return subComment;
  }
}
