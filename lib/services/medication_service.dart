import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:wagtrack/models/medication_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/symptom_service.dart';

/// Communication to Firebase for Medication-related data.
class MedicationService with ChangeNotifier {
  final SymptomService _symptomService;

  // Instance of Firebase Firestore for interacting with the database
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();
  static final _firestoreMedicationCollection =
      _db.collection("medication routines");

  // Reference to Firebase Storage for potential future storage needs
  // static final Reference _storageRef = GetIt.I<FirebaseStorage>().ref();

  List<MedicationRoutine> _medicationRoutines = [];
  List<MedicationRoutine> get medicationRoutines => _medicationRoutines;

  /// Constructor
  MedicationService(this._symptomService);

  /// Adds a new medication document to the "medication" collection in Firestore
  void addMedicationRoutines({required MedicationRoutine formData}) {
    AppLogger.d("[MED] Adding Medication Routine to Firebase");

    _firestoreMedicationCollection.add(formData.toJSON());
    List<MedicationRoutine> medicationRoutines = [
      ..._medicationRoutines,
      ...[formData]
    ];
    getAllMedicationRoutineByPetID(petID: formData.petID, first: true);
    setMedicationRoutines(medicationRoutines: medicationRoutines);
  }

  /// Sets MedicationRoutines.
  void setMedicationRoutines(
      {required List<MedicationRoutine> medicationRoutines}) async {
    AppLogger.d("[MED] Setting medicationRoutines");
    _medicationRoutines = medicationRoutines;
    notifyListeners();
  }

  /// Fetches all Medication Routine associated with a specific pet ID
  Future<List<MedicationRoutine>> getAllMedicationRoutineByPetID(
      {required String petID, required bool first}) async {
    try {
      // Query Firestore for documents in the "symptoms" collection where "petID" field matches the provided petID
      final querySnapshot = await _firestoreMedicationCollection
          .where("petID", isEqualTo: petID)
          .get();

      final List<MedicationRoutine> medRoutines = [];
      for (final docSnapshot in querySnapshot.docs) {
        // Extract data from the document
        final medRoutinesData = docSnapshot.data();

        // Convert the data to a Symptom object
        final MedicationRoutine medRoutine =
            MedicationRoutine.fromJson(medRoutinesData);

        // Assign the document ID as the object's ID (assuming "oid" is a custom field for internal use)
        medRoutine.oid = docSnapshot.id;
        if (first) {
          for (String symptomID in medRoutine.symptomsID) {
            _symptomService.updateMID(
                symptomID: symptomID,
                mID: medRoutine.oid!,
                mName: medRoutine.title);
          }
        }

        // Add the converted symptom object to the list
        medRoutines.add(medRoutine);
      }
      return medRoutines;
    } catch (e) {
      // **Bold Error Message**
      AppLogger.e("[MED] Error fetching medRoutines for pet ID $petID: $e", e);
      return []; // Return an empty list on error
    }
  }

  /// Deletes the medication routine with the given id from Firebase
  Future<void> deleteMedicationRoutine({required String id}) async {
    AppLogger.d("[MED] Deleting symptom with id $id");
    try {
      // remove from local med routine lists. needed to reset the UI of the home page!
      _medicationRoutines.removeWhere((routine) => routine.oid == id);

      // delete from firestore
      await _firestoreMedicationCollection.doc(id).delete();
    } catch (e) {
      AppLogger.e("[MED] Error deleting medication routine", e);
    }

    notifyListeners();
  }

  /// Resets medicationService
  ///
  /// clears lists of medication routines
  void resetService() {
    AppLogger.t("[MEDS] Resetting medication service");
    _medicationRoutines = [];
  }
}
