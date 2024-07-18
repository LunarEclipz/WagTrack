import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/post_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/user_service.dart';

class PostService with ChangeNotifier {
  // Instance of Firebase Firestore for interacting with the database
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();

  // Reference to Firebase Storage for potential future storage needs
  static final Reference _storageRef = GetIt.I<FirebaseStorage>().ref();
  static final FirebaseStorage _firebaseStorage = GetIt.I<FirebaseStorage>();

  List<Post> _posts = [];

  List<Post> get posts => _posts;

  /// Adds Post to Firestore
  void addPost({required Post postData, required List<XFile> imgs}) async {
    AppLogger.d("[POST] Adding Post");
    try {
      // upload pet image and wait
      postData.media = [];
      for (var i = 0; i < imgs.length; i++) {
        String? imgPath =
            await uploadPostImage(image: imgs[i], petID: postData.petID.first);
        postData.media!.add(imgPath!);
      }

      // WAIT for pet to be added to db!!!
      await _db.collection("posts").add(postData.toJSON());

      AppLogger.i("[POST] Post added successfully");
      // List<Post> posts = await PetService().getAllPetsByUID(uid: uid);
      // setPersonalCommunityPets(pets: pets);
    } catch (e) {
      AppLogger.e("[POST] Error adding pet: $e", e);
    }

    notifyListeners();
  }

  /// Sets internal lists of posts.
  void setPosts({required List<Post> posts}) {
    AppLogger.d("[POST] Setting Personal and Community Pets");
    _posts = posts;
    notifyListeners();
  }

  /// Gets Post from Firestore
  Future<List<Post>> getAllPostsByPetID({required List<String> petIDs}) async {
    final List<Post> posts = [];

    try {
      for (var i = 0; i < petIDs.length; i++) {
        final querySnapshot = await _db
            .collection("posts")
            .where("petID", arrayContains: petIDs[i])
            .get();

        for (final docSnapshot in querySnapshot.docs) {
          final postData = docSnapshot.data();
          final post = Post.fromJson(postData);
          post.oid = docSnapshot.id;
          posts.add(post);
        }
      }
      AppLogger.i("[POST] Posts fetched (by uid) successfully");
      notifyListeners();
      return posts;
    } catch (e) {
      AppLogger.e("[POST] Error fetching posts for PetID $petIDs: $e", e);
      notifyListeners();
      return []; // Return an empty list on error
    }
  }

  Future<String?> uploadPostImage(
      {required XFile? image, required String petID}) async {
    AppLogger.d("[PET] Uploading pet image");
    if (image != null) {
      try {
        var file = File(image.path);

        //Upload to Firebase
        // var snapshot =
        await _firebaseStorage
            .ref("petPosts/$petID/")
            .child(basename(image.path))
            .putFile(file);
        AppLogger.t("[POST] File uploaded to Firebase storage");
        final imageUrl = await _storageRef
            .child("petPosts/$petID/${basename(image.path)}")
            .getDownloadURL();
        AppLogger.i("[POST] Image added succesfully");
        return imageUrl;
      } catch (e) {
        AppLogger.e("[POST] Error uploading Image: $e", e);
        return null;
      }
    } else {
      AppLogger.w("[POST] Image is null");
      return null;
    }
  }
}
