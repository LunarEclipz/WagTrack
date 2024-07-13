import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/services/logging.dart';

/// Communication to Firebase for Symptom-related data.
class SymptomService with ChangeNotifier {
  // Instance of Firebase Firestore for interacting with the database
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();

  // Reference to Firebase Storage for potential future storage needs
  static final Reference _storageRef = GetIt.I<FirebaseStorage>().ref();

  List<Symptom> _currentSymptoms = [];
  List<Symptom> _pastSymptoms = [];

  List<Symptom> get currentSymptoms => _currentSymptoms;
  List<Symptom> get pastSymptoms => _pastSymptoms;

  /// Adds a new symptom document to the "symptoms" collection in Firestore
  void addSymptoms({required Symptom formData}) {
    _db.collection("symptoms").add(formData.toJSON());
    List<Symptom> symptoms = [
      ...currentSymptoms,
      ...pastSymptoms,
      ...[formData]
    ];
    setPastCurrentSymptoms(symptoms: symptoms);
  }

  /// Sets List of pastSymptoms and currentSymptoms.
  void setPastCurrentSymptoms({required List<Symptom> symptoms}) async {
    AppLogger.d("[SYMP] Setting pastSymptoms and currentSymptoms");
    _pastSymptoms =
        symptoms.where((symptom) => symptom.endDate != null).toList();
    _currentSymptoms =
        symptoms.where((symptom) => symptom.endDate == null).toList();
    notifyListeners();
  }

  /// Fetches all symptoms associated with a specific pet ID
  Future<List<Symptom>> getAllSymptomsByPetID({required String petID}) async {
    try {
      // Query Firestore for documents in the "symptoms" collection where "petID" field matches the provided petID
      final querySnapshot = await _db
          .collection("symptoms")
          .where("petID", isEqualTo: petID)
          .get();

      final List<Symptom> symptoms = [];
      for (final docSnapshot in querySnapshot.docs) {
        // Extract data from the document
        final symptomData = docSnapshot.data();
        if (symptomData["mid"] == null) {
          symptomData["mid"] = [];
        }
        if (symptomData["mName"] == null) {
          symptomData["mName"] = [];
        }
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
      AppLogger.e("[SYMP] Error fetching symptoms for pet ID $petID: $e", e);
      return []; // Return an empty list on error
    }
  }

  /// Update Medication Routines
  void updateMID(
      {required String symptomID, required String mID, required String mName}) {
    AppLogger.d("Updating Session Records");
    final symptomRef = _db.collection("symptoms").doc(symptomID);

    symptomRef.update({
      "mid": FieldValue.arrayUnion([mID]),
      "mName": FieldValue.arrayUnion([mName]),
    }).then(
        (value) => AppLogger.d("[SYMP] Successfully Updated Session Records"),
        onError: (e) =>
            AppLogger.d("[SYMP] Error Updating Session Records: $e", e));

    notifyListeners();
  }

  /// Resets symptomService
  ///
  /// clears lists of symptoms
  void resetService() {
    AppLogger.t("[SYMP] Resetting symptom service");
    _currentSymptoms = [];
    _pastSymptoms = [];
  }
}
