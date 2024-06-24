import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:wagtrack/models/symptom_model.dart';

/// Communication to Firebase for Symptom-related data.

class SymptomService {
  // Instance of Firebase Firestore for interacting with the database
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Reference to Firebase Storage for potential future storage needs
  final Reference storageRef = FirebaseStorage.instance.ref();

  /// Adds a new symptom document to the "symptoms" collection in Firestore
  void addSymptoms({required Symptom formData}) {
    db.collection("symptoms").add(formData.toJSON());
  }

  /// Fetches all symptoms associated with a specific pet ID
  Future<List<Symptom>> getAllPetsByUID({required String petID}) async {
    try {
      // Query Firestore for documents in the "symptoms" collection where "petID" field matches the provided petID
      final querySnapshot = await db
          .collection("symptoms")
          .where("petID", isEqualTo: petID)
          .get();

      final List<Symptom> symptoms = [];
      for (final docSnapshot in querySnapshot.docs) {
        // Extract data from the document
        final symptomData = docSnapshot.data();

        // Convert the data to a Symptom object
        final symptom = Symptom.fromJson(symptomData);

        // Assign the document ID as the object's ID (assuming "oid" is a custom field for internal use)
        symptom.oid = docSnapshot.id;

        // Add the converted symptom object to the list
        symptoms.add(symptom);
      }
      return symptoms;
    } catch (e) {
      // **Bold Error Message**
      print("**Error fetching symptoms for pet ID $petID: $e**");
      return []; // Return an empty list on error
    }
  }
}
