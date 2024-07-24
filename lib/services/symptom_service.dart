import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/services/logging.dart';
import 'package:wagtrack/services/notification_service.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/utils.dart';

/// Communication to Firebase for Symptom-related data.
class SymptomService with ChangeNotifier {
  final PetService _petService;
  final NotificationService _notificationService;

  // Instance of Firebase Firestore for interacting with the database
  static final FirebaseFirestore _db = GetIt.I<FirebaseFirestore>();
  static final _firestoreSymptomCollection = _db.collection("symptoms");

  // Reference to Firebase Storage for potential future storage needs
  // static final Reference _storageRef = GetIt.I<FirebaseStorage>().ref();

  /// Constructor for `SymptomService`
  SymptomService(this._petService, this._notificationService);

  List<Symptom> _currentSymptoms = [];
  List<Symptom> _pastSymptoms = [];

  List<Symptom> get currentSymptoms => _currentSymptoms;
  List<Symptom> get pastSymptoms => _pastSymptoms;

  /// Adds a new symptom document to the "symptoms" collection in Firestore
  ///
  /// Also creates a new symptom notification
  void addSymptom({required Symptom formData}) {
    _firestoreSymptomCollection
        .add(formData.toJSON())
        .then((docRef) => formData.oid = docRef.id);
    List<Symptom> symptoms = [
      ...currentSymptoms,
      ...pastSymptoms,
      ...[formData]
    ];

    /// create new symptom notification for this symptom IF it is an ongoing symptom
    /// or if (somehow) the end date is set to the future...
    if (formData.endDate == null ||
        DateTime.now().compareTo(formData.endDate!) == -1) {
      createSymptomNotification(formData);
    }

    setPastCurrentSymptoms(symptoms: symptoms);
  }

  /// Sets List of pastSymptoms and currentSymptoms based from the input list of
  /// symptoms.
  void setPastCurrentSymptoms({required List<Symptom> symptoms}) async {
    AppLogger.d("[SYMP] Setting pastSymptoms and currentSymptoms");
    _pastSymptoms =
        symptoms.where((symptom) => symptom.endDate != null).toList();
    _currentSymptoms =
        symptoms.where((symptom) => symptom.endDate == null).toList();
    notifyListeners();
  }

  /// Fetches all symptoms from Firestore associated with a specific pet ID
  Future<List<Symptom>> getAllSymptomsByPetID({required String petID}) async {
    try {
      // Query Firestore for documents in the "symptoms" collection where "petID" field matches the provided petID
      final querySnapshot = await _firestoreSymptomCollection
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

  /// Fetches all symptoms locally
  ///
  /// I swear why aren't the symptoms like just a hashmap goddamnit TODO
  List<Symptom> getSymptomsFromIDs(List<String> symptomIDs) {
    // most efficient, since length of desired IDs << total symptoms, is to
    // go through each desired ID and find that symptom
    final List<Symptom> symptoms = [];

    // too lazy to use maps - or is that actually faster
    for (String id in symptomIDs) {
      symptoms.addAll(_currentSymptoms.where((symptom) => symptom.oid == id));
      symptoms.addAll(_pastSymptoms.where((symptom) => symptom.oid == id));
    }

    return symptoms;
  }

  /// Update Medication Routines
  void updateMID(
      {required String symptomID, required String mID, required String mName}) {
    AppLogger.d("Updating Session Records");
    final symptomRef = _firestoreSymptomCollection.doc(symptomID);

    symptomRef.update({
      "mid": FieldValue.arrayUnion([mID]),
      "mName": FieldValue.arrayUnion([mName]),
    }).then(
        (value) => AppLogger.d("[SYMP] Successfully Updated Session Records"),
        onError: (e) =>
            AppLogger.d("[SYMP] Error Updating Session Records: $e", e));

    notifyListeners();
  }

  /// Deletes the symptom with the given id from Firebase
  Future<void> deleteSymptom({required String id}) async {
    if (id.isEmpty) {
      AppLogger.w("[SYMP] Symptom id for deletion is empty");
      return;
    }

    AppLogger.d("[SYMP] Deleting symptom with id $id");
    try {
      // remove from local symptom lists. needed to reset the UI of the home page!
      _currentSymptoms.removeWhere((symptom) => symptom.oid == id);
      _pastSymptoms.removeWhere((symptom) => symptom.oid == id);

      // delete from firestore
      await _firestoreSymptomCollection.doc(id).delete();
    } catch (e) {
      AppLogger.e("[SYMP] Error deleting symptom", e);
    }

    notifyListeners();
  }

  /// Updates the symptom with the given id locally and in firebase
  Future<void> updateSymptom({
    required String id,
    String? category,
    String? symptom,
    String? factors,
    int? severity,
    List<String>? tags,
    bool? hasEnd,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    AppLogger.d("[SYMP] Updating symptom with id $id");

    // we search a list to properly do a null check!
    final List<Symptom> foundSymptoms = getSymptomsFromIDs([id]);
    // exit if empty
    if (foundSymptoms.isEmpty) {
      AppLogger.w("[SYMP] No symptoms found with id $id");
      return;
    }

    try {
      // get symptom object
      final Symptom symptomToEdit = foundSymptoms[0];

      // apply changes
      symptomToEdit.category = category ?? symptomToEdit.category;
      symptomToEdit.symptom = symptom ?? symptomToEdit.symptom;
      symptomToEdit.factors = factors ?? symptomToEdit.factors;
      symptomToEdit.severity = severity ?? symptomToEdit.severity;
      symptomToEdit.tags = tags ?? symptomToEdit.tags;
      symptomToEdit.hasEnd = hasEnd ?? symptomToEdit.hasEnd;
      symptomToEdit.startDate = startDate ?? symptomToEdit.startDate;
      symptomToEdit.endDate = endDate ?? symptomToEdit.endDate;

      // then apply updates to Firestore
      final symptomDocRef = _firestoreSymptomCollection.doc(id);

      await symptomDocRef.update(symptomToEdit.toJSON()).then(
          (value) => AppLogger.d("[SYMP] Successfully updated symptom $id"),
          onError: (e) =>
              AppLogger.d("[SYMP] Error updating symptom $id: $e", e));
    } catch (e) {
      AppLogger.e("[SYMP] Error updating symptom $id", e);
    }

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

  /// Creates a new symptom notification. Takes in a `Symptom`.
  ///
  /// For now: Shows a new notification now with type determined on the symptom'
  /// severity
  void createSymptomNotification(Symptom symptomData) {
    final type = symptomData.level.notifType;

    final pet = _petService.getPetFromLocalWithID(petID: symptomData.petID);
    final petName = pet?.name ?? "Your Pet";

    /// Title
    final title = '${symptomData.level.desc}: $petName';

    /// Body
    final body =
        '${symptomData.symptom} of severity level ${symptomData.severity}. \n'
        'Started ${timeAgo(symptomData.startDate).toLowerCase()}.';

    _notificationService.showNotification(title, body, type);
  }
}
