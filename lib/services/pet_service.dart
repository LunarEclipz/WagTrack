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
  static final _firestorePetCollection = _db.collection("pets");

  static final FirebaseStorage _firebaseStorage = GetIt.I<FirebaseStorage>();
  static final Reference _storageRef = _firebaseStorage.ref();

  List<Pet> _communityPets = [];
  List<Pet> _personalPets = [];

  List<Pet> get communityPets => _communityPets;
  List<Pet> get personalPets => _personalPets;

  void addPet(
      {required Pet pet, required File? img, required String uid}) async {
    AppLogger.d("[PET] Adding pet");
    try {
      // upload pet image and wait
      String? imgPath =
          await uploadPetImage(image: img, uid: pet.caretakers[0].uid);

      // set pet image path
      pet.imgPath = imgPath;

      // WAIT for pet to be added to db!!!
      await _firestorePetCollection
          .add(pet.toJSON())
          .then((docRef) => pet.petID = docRef.id);

      AppLogger.i("[PET] Pet added successfully");
      List<Pet> pets = await PetService().getAllPetsByUID(uid: uid);
      setPersonalCommunityPets(pets: pets);
    } catch (e) {
      // TODO is there a specific error that you want to catch?
      _firestorePetCollection.add(pet.toJSON());
      AppLogger.e("[PET] Error adding pet: $e", e);
    }

    notifyListeners();
  }

  /// Sets internal lists of Personal and Community Pets.
  void setPersonalCommunityPets({required List<Pet> pets}) {
    AppLogger.d("[PET] Setting Personal and Community Pets");
    _personalPets = pets.where((pet) => pet.petType == "personal").toList();
    _communityPets = pets.where((pet) => pet.petType == "community").toList();
    notifyListeners();
  }

  Future<List<Pet>> getAllPetsByUID({required String uid}) async {
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
      AppLogger.i("[PET] Pets fetched (by uid) successfully");
      notifyListeners();
      return pets;
    } catch (e) {
      AppLogger.e("[PET] Error fetching pets for uid $uid: $e", e);
      notifyListeners();
      return []; // Return an empty list on error
    }
  }

  Future<List<Pet>> getAllCommunityPetsByRegion(
      {required String location}) async {
    AppLogger.d("[PET] Getting all community pets by location");
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
      AppLogger.i("[PET] Community pets fetched (by loc) successfully");
      return pets;
    } catch (e) {
      AppLogger.e("[PET] Error fetching community pets for location: $e", e);
      return []; // Return an empty list on error
    }
  }

  /// Deletes the pet with the given id from Firebase
  Future<void> deletePet({required String id}) async {
    if (id.isEmpty) {
      AppLogger.w("[PET] Pet id for deletion is empty");
      return;
    }

    AppLogger.d("[PET] Deleting pet with id $id");
    try {
      // remove from local pet lists. needed to reset the UI of the home page!
      _communityPets.removeWhere((pet) => pet.petID == id);
      _personalPets.removeWhere((pet) => pet.petID == id);

      // delete from firestore
      await _firestorePetCollection.doc(id).delete();
    } catch (e) {
      AppLogger.e("[PET] Error deleting pet", e);
    }

    notifyListeners();
  }

  /// Uploads Image to Firebase Storage.
  ///
  /// Returns the url to the image
  Future<String?> uploadPetImage(
      {required File? image, required String uid}) async {
    AppLogger.d("[PET] Uploading pet image");
    if (image != null) {
      try {
        var file = File(image.path);

        //Upload to Firebase
        // var snapshot =
        await _firebaseStorage
            .ref("petProfile/$uid/")
            .child(basename(image.path))
            .putFile(file);
        AppLogger.t("[PET] File uploaded to Firebase storage");
        final imageUrl = await _storageRef
            .child("petProfile/$uid/${basename(image.path)}")
            .getDownloadURL();
        AppLogger.i("[PET] Pet image added succesfully");
        return imageUrl;
      } catch (e) {
        AppLogger.e("[PET] Error uploading pet image: $e", e);
        return null;
      }
    } else {
      AppLogger.w("[PET] Pet image is null");
      return null;
    }
  }

  /// Update weight log
  void updateWeightLog(
      {required Pet petData, required List<DateTimeStringPair> weightLog}) {
    AppLogger.d("[PET] Updating Weight Log");
    final petRef = _firestorePetCollection.doc(petData.petID);

    petRef.update({
      "weight": weightLog.map((weight) => weight.toJSON()).toList(),
    }).then((value) => AppLogger.d("[PET] Successfully Updated Weight Log"),
        onError: (e) => AppLogger.d("[PET] Error Updating Weight Log: $e"));

    notifyListeners();
  }

  /// Update Vaccine Records
  void updateVaccineRecords(
      {required Pet petData,
      required List<DateTimeStringPair> vaccineRecords}) {
    AppLogger.d("[PET] Updating Vaccine Records");
    final petRef = _firestorePetCollection.doc(petData.petID);

    petRef.update({
      "vaccineRecords": vaccineRecords
          .map((vaccineRecord) => vaccineRecord.toJSON())
          .toList(),
    }).then(
        (value) => AppLogger.d("[PET] Successfully Updated Vaccine Records"),
        onError: (e) =>
            AppLogger.d("[PET] Error Updating Vaccine Records: $e"));

    notifyListeners();
  }

  /// Update Session Records
  void updateSessionRecords(
      {required Pet petData,
      required List<DateTimeStringPair> sessionRecords}) {
    AppLogger.d("[PET] Updating Session Records");
    final petRef = _firestorePetCollection.doc(petData.petID);

    petRef.update({
      "sessionRecords": sessionRecords
          .map((sessionRecord) => sessionRecord.toJSON())
          .toList(),
    }).then(
        (value) => AppLogger.d("[PET] Successfully Updated Session Records"),
        onError: (e) =>
            AppLogger.d("[PET] Error Updating Session Records: $e"));

    notifyListeners();
  }

  /// Resets petService
  ///
  /// clears lists of pets
  void resetService() {
    AppLogger.t("[PET] Resetting pet service");
    _personalPets = [];
    _communityPets = [];
  }
}
