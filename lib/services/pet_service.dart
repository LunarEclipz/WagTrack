// Communication to FireStore Pet Collection
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wagtrack/models/pet_model.dart';

class PetService {
  FirebaseFirestore db = FirebaseFirestore.instance;

  void addPet({required Pet pet}) {
    db.collection("pets").add(pet.toJSON());
    // .then((documentSnapshot) =>
    //     print("Added Data with ID: ${documentSnapshot.id}"));
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
}
