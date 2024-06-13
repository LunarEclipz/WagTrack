import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wagtrack/models/symptom_model.dart';

class SymptomService {
  FirebaseFirestore db = FirebaseFirestore.instance;
  Reference storageRef = FirebaseStorage.instance.ref();

  // Adding Symptoms to Firestore
  void addSymptoms({required Symptom formData}) {
    db.collection("symptoms").add(formData.toJSON());
  }

  Future<List<Symptom>> getAllPetsByUID({required String petID}) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("symptoms")
          .where("petID", isEqualTo: petID)
          .get();

      final List<Symptom> symptoms = [];
      for (final docSnapshot in querySnapshot.docs) {
        final petData = docSnapshot.data();
        final symptom = Symptom.fromJson(petData);
        symptom.oid = docSnapshot.id;
        symptoms.add(symptom);
      }
      return symptoms;
    } catch (e) {
      // print("Error fetching pets for uid $uid: $e");
      return []; // Return an empty list on error
    }
  }
}
