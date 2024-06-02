// Communication to FireStore Pet Collection
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:path/path.dart';

class PetService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Reference storageRef = FirebaseStorage.instance.ref();

  void addPet({required Pet pet, required File? img}) {
    try {
      uploadPetImage(image: img, uid: pet.uid).then((imgPath) {
        pet.imgPath = imgPath;
        db.collection("pets").add(pet.toJSON());
      });
    } catch (e) {
      db.collection("pets").add(pet.toJSON());
    }
  }

  Future<List<Pet>> getAllPetsByUID({required String uid}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("pets")
          .where("uid", isEqualTo: uid)
          .get();

      final List<Pet> pets = [];
      for (final docSnapshot in querySnapshot.docs) {
        final petData = docSnapshot.data();
        final pet = Pet.fromJson(petData);
        pet.oid = docSnapshot.id;
        pets.add(pet);
      }
      return pets;
    } catch (e) {
      // print("Error fetching pets for uid $uid: $e");
      return []; // Return an empty list on error
    }
  }

  Future<List<Pet>> getAllCommunityPetsByRegion(
      {required String location}) async {
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
      return pets;
    } catch (e) {
      // print("Error fetching community pets for  $location: $e");
      return []; // Return an empty list on error
    }
  }

  // Uploads Image to Fire Storage
  uploadPetImage({required File? image, required String uid}) async {
    if (image != null) {
      final firebaseStorage = FirebaseStorage.instance;
      var file = File(image.path);
      //Upload to Firebase
      var snapshot = await firebaseStorage
          .ref("petProfile/$uid/")
          .child(basename(image.path))
          .putFile(file);
      final imageUrl = await storageRef
          .child("petProfile/$uid/${basename(image.path)}")
          .getDownloadURL();
      return imageUrl;
    }
  }
}
