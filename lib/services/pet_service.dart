import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/logging.dart';

/// Communication to Firebase for Pet-related data.
class PetService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Reference storageRef = FirebaseStorage.instance.ref();

  void addPet({required Pet pet, required File? img}) {
    AppLogger.d("Adding pet");
    try {
      uploadPetImage(image: img, uid: pet.uid).then((imgPath) {
        pet.imgPath = imgPath;
        db.collection("pets").add(pet.toJSON());
      });
      AppLogger.i("Pet added");
    } catch (e) {
      // TODO is there a specific error that you want to catch?
      db.collection("pets").add(pet.toJSON());
      AppLogger.d("Error adding pet: $e", e);
    }
  }

  Future<List<Pet>> getAllPetsByUID({required String uid}) async {
    AppLogger.d("Getting all pets by uid");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("pets")
          .where("uid", isEqualTo: uid)
          .get();

      final List<Pet> pets = [];
      for (final docSnapshot in querySnapshot.docs) {
        final petData = docSnapshot.data();
        final pet = Pet.fromJson(petData);
        pet.petID = docSnapshot.id;
        pets.add(pet);
      }
      AppLogger.i("pets fetched (by uid) successfully");
      return pets;
    } catch (e) {
      AppLogger.e("Error fetching pets for uid $uid: $e", e);
      return []; // Return an empty list on error
    }
  }

  Future<List<Pet>> getAllCommunityPetsByRegion(
      {required String location}) async {
    AppLogger.d("Getting all community pets by location");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("pets")
          .where("location", isEqualTo: location)
          .where("petType", isEqualTo: "community")
          .get();

      final List<Pet> pets = [];
      for (final docSnapshot in querySnapshot.docs) {
        final petData = docSnapshot.data();
        final pet = Pet.fromJson(petData);
        pets.add(pet);
      }
      AppLogger.i("Community pets fetched (by loc) successfully");
      return pets;
    } catch (e) {
      AppLogger.e("Error fetching community pets for location: $e", e);
      return []; // Return an empty list on error
    }
  }

  /// Uploads Image to Firebase Storage.
  uploadPetImage({required File? image, required String uid}) async {
    AppLogger.d("Uploading pet image");
    if (image != null) {
      try {
        final firebaseStorage = FirebaseStorage.instance;
        var file = File(image.path);

        //Upload to Firebase
        // var snapshot =
        await firebaseStorage
            .ref("petProfile/$uid/")
            .child(basename(image.path))
            .putFile(file);
        AppLogger.t("File uploaded to Firebase storage");
        final imageUrl = await storageRef
            .child("petProfile/$uid/${basename(image.path)}")
            .getDownloadURL();
        AppLogger.i("Pet image added succesfully");
        return imageUrl;
      } catch (e) {
        AppLogger.e("Error uploading pet image: $e", e);
      }
    } else {
      AppLogger.w("Pet image is null");
    }
  }
}
