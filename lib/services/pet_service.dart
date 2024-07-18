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
        onError: (e) => AppLogger.e("[PET] Error Updating Weight Log: $e"));

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
            AppLogger.e("[PET] Error Updating Vaccine Records: $e"));

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
            AppLogger.e("[PET] Error Updating Session Records: $e"));

    notifyListeners();
  }

  /// Gets a pet from local using the given id. Returns null if no pet is found.
  Pet? getPetFromLocalWithID({required String petID}) {
// first find pet
    final List<Pet> foundPets = [];
    foundPets.addAll(_personalPets.where((pet) => pet.petID == petID));
    foundPets.addAll(_communityPets.where((pet) => pet.petID == petID));

    if (foundPets.isEmpty) {
      // no pet with given ID found
      return null;
    }

    return foundPets.first;
  }

  /// Updates the pet with the given id locally and in firebase
  Future<void> updatePet({
    required String id,
    String? location,
    String? name,
    String? description,
    String? sex,
    String? species,
    String? petType,
    String? idNumber,
    String? breed,
    DateTime? birthDate,
    List<DateTimeStringPair>? weight,
    List<Caretaker>? caretakers,
    List<String>? caretakerIDs,
    List<DateTimeStringPair>? sessionRecords,
    File? img,
  }) async {
    AppLogger.d("[PET] Updating pet $id");

    // we search a list to properly do a null check!
    final Pet? pet = getPetFromLocalWithID(petID: id);
    // exit if empty
    if (pet == null) {
      AppLogger.w("[PET] No pets found with id $id");
      return;
    }

    try {
      // apply changes
      pet.location = location ?? pet.location;
      pet.name = name ?? pet.name;
      pet.description = description ?? pet.description;
      pet.sex = sex ?? pet.sex;
      pet.species = species ?? pet.species;
      pet.petType = petType ?? pet.petType;
      pet.idNumber = idNumber ?? pet.idNumber;
      pet.breed = breed ?? pet.breed;
      pet.birthDate = birthDate ?? pet.birthDate;
      pet.weight = weight ?? pet.weight;
      pet.caretakers = caretakers ?? pet.caretakers;
      pet.caretakerIDs = caretakerIDs ?? pet.caretakerIDs;
      pet.sessionRecords = sessionRecords ?? pet.sessionRecords;

      // IMAGE - only if image is present
      if (img != null) {
        // upload pet image and wait
        String? imgPath =
            await uploadPetImage(image: img, uid: pet.caretakers[0].uid);

        // set pet image path
        pet.imgPath = imgPath;
      }

      // then apply updates to Firestore
      final petDocRef = _firestorePetCollection.doc(id);

      await petDocRef.update(pet.toJSON()).then(
          (value) => AppLogger.d("[PET] Successfully updated pet $id"),
          onError: (e) => AppLogger.d("[PET] Error updating pet $id: $e", e));
    } catch (e) {
      AppLogger.e("[PET] Error updating pet $id", e);
    }

    notifyListeners();
  }

  /// Checks for the role of the given user with the given pet and returns the role
  /// as a string. Returns `null` if there is no role.
  ///
  /// Checks against local pets.
  String? checkUserPetRole({required String petID, required String userID}) {
    final checkPet = getPetFromLocalWithID(petID: petID);

    if (checkPet == null) {
      return null;
    }

    // now look through pet caretakers
    final caretakerMatches = checkPet.caretakers.where((c) => c.uid == userID);

    if (caretakerMatches.isEmpty) {
      // no user found for this pet.
      return null;
    }

    return caretakerMatches.first.role;
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
