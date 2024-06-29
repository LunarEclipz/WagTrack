import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/logging.dart';

/// Communication to Firebase for Pet-related data.
class PetService with ChangeNotifier {
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();
  static final FirebaseStorage _firebaseStorage = GetIt.I<FirebaseStorage>();
  static final Reference _storageRef = _firebaseStorage.ref();

  List<Pet> _communityPets = [];
  List<Pet> _personalPets = [];

  List<Pet> get communityPets => _communityPets;
  List<Pet> get personalPets => _personalPets;

  void addPet(
      {required Pet pet, required File? img, required String uid}) async {
    AppLogger.d("Adding pet");
    try {
      uploadPetImage(image: img, uid: pet.caretakers[0].uid).then((imgPath) {
        pet.imgPath = imgPath;
        _db.collection("pets").add(pet.toJSON());
      });
      AppLogger.i("Pet added");
      List<Pet> pets = await PetService().getAllPetsByUID(uid: uid);
      setPersonalCommunityPets(pets: pets);
    } catch (e) {
      // TODO is there a specific error that you want to catch?
      _db.collection("pets").add(pet.toJSON());
      AppLogger.d("Error adding pet: $e", e);
    }
  }

  /// Sets List of Personal and Community Pets.
  void setPersonalCommunityPets({required List<Pet> pets}) async {
    AppLogger.d("Setting Personal and Community Pets");
    _personalPets = pets.where((pet) => pet.petType == "personal").toList();
    _communityPets = pets.where((pet) => pet.petType == "community").toList();
    notifyListeners();
  }

  Future<List<Pet>> getAllPetsByUID({required String uid}) async {
    AppLogger.d("Getting all pets by uid");
    try {
      final querySnapshot = await _db
          .collection("pets")
          .where("caretakerIDs", arrayContains: uid)
          .get();

      final List<Pet> pets = [];
      for (final docSnapshot in querySnapshot.docs) {
        final petData = docSnapshot.data();
        final pet = Pet.fromJson(petData);
        pet.petID = docSnapshot.id;
        pets.add(pet);
      }
      AppLogger.i("Pets fetched (by uid) successfully");
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
      final querySnapshot = await _db
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
        var file = File(image.path);

        //Upload to Firebase
        // var snapshot =
        await _firebaseStorage
            .ref("petProfile/$uid/")
            .child(basename(image.path))
            .putFile(file);
        AppLogger.t("File uploaded to Firebase storage");
        final imageUrl = await _storageRef
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

  /// Update weight log
  void updateWeightLog(
      {required Pet petData, required List<DateTimeStringPair> weightLog}) {
    AppLogger.d("Updating Weight Log");
    final petRef = _db.collection("pets").doc(petData.petID);

    petRef.update({
      "weight": weightLog.map((weight) => weight.toJSON()).toList(),
    }).then((value) => AppLogger.d("Successfully Updated Weight Log"),
        onError: (e) => AppLogger.d("Error Updating Weight Log: $e"));
  }

  /// Update Vaccine Records
  void updateVaccineRecords(
      {required Pet petData,
      required List<DateTimeStringPair> vaccineRecords}) {
    AppLogger.d("Updating Vaccine Records");
    final petRef = _db.collection("pets").doc(petData.petID);

    petRef.update({
      "vaccineRecords": vaccineRecords
          .map((vaccineRecord) => vaccineRecord.toJSON())
          .toList(),
    }).then((value) => AppLogger.d("Successfully Updated Vaccine Records"),
        onError: (e) => AppLogger.d("Error Updating Vaccine Records: $e"));
  }

  /// Update Session Records
  void updateSessionRecords(
      {required Pet petData,
      required List<DateTimeStringPair> sessionRecords}) {
    AppLogger.d("Updating Session Records");
    final petRef = _db.collection("pets").doc(petData.petID);

    petRef.update({
      "sessionRecords": sessionRecords
          .map((sessionRecord) => sessionRecord.toJSON())
          .toList(),
    }).then((value) => AppLogger.d("Successfully Updated Session Records"),
        onError: (e) => AppLogger.d("Error Updating Session Records: $e"));
  }
}
