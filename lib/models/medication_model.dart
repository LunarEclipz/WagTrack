import 'package:uuid/uuid.dart';
import 'package:wagtrack/models/pet_model.dart';

class PetMedicationModel {
  late Pet pet;
  late List<MedicationRoutine> medicationRoutines;
}

class MedicationRoutine {
  late String title;
  late String clinicName;
  late String appointmentNumber;
  late String diagnosis;
  late String comments;

  late List<String> symptomsID;
  late List<String> symptomsName;

  late List<Medication> medications;

  /// Id of pet that this medication routine is associated to.
  late String petID;

  /// Document id that represents medication routine.
  late String? oid;

  MedicationRoutine({
    required this.title,
    required this.clinicName,
    required this.appointmentNumber,
    required this.diagnosis,
    required this.comments,
    required this.symptomsID,
    required this.symptomsName,
    required this.medications,
    required this.petID,
    this.oid,
  });

// Converts Object to JSON for uploading into Firebase
  Map<String, dynamic> toJSON() {
    final medicationRoutineData = {
      "title": title,
      "clinicName": clinicName,
      "appointmentNumber": appointmentNumber,
      "diagnosis": diagnosis,
      "comments": comments,
      "symptomsID": symptomsID,
      "symptomsName": symptomsName,
      "petID": petID,
      "medications":
          medications.map((medication) => medication.toJSON()).toList(),
    };

    return medicationRoutineData;
  }

  static MedicationRoutine fromJson(Map<String, dynamic> json) {
    MedicationRoutine medRoutine = MedicationRoutine(
        title: json["title"] as String,
        clinicName: json["clinicName"] as String,
        appointmentNumber: json["appointmentNumber"] as String,
        diagnosis: json["diagnosis"] as String,
        comments: json["comments"] as String,
        symptomsID: (json["symptomsID"] as List).cast<String>(),
        symptomsName: (json["symptomsName"] as List).cast<String>(),
        medications: (json["medications"] as List)
            .map((medication) => Medication.fromJson(medication))
            .toList(),
        petID: json["petID"] as String);

    return medRoutine;
  }
}

/// Wraps a medication
class Medication {
  static const uuid = Uuid();

  /// UUID V4
  late final String id;

  /// Name of medication
  final String name;
  final String quantity;
  final String desc;

  /// Whether it's taken as needed (no set intervals)
  ///
  /// will automatically set if interval fields are empty.
  bool takeAsNeeded;

  /// frequencies: dosageCount per intervalValue intervalUnit
  final int? dosageCount;
  final int? intervalValue;

  /// second, minute, hour, day, week, month
  final String? intervalUnit;

  Medication({
    String? id,
    required this.name,
    required this.quantity,
    required this.desc,
    this.takeAsNeeded = false,
    this.dosageCount,
    this.intervalValue,
    this.intervalUnit,
  }) : id = id ?? uuid.v4() {
    // if there is no set date, this medication is set to take as needed
    if (dosageCount == null || intervalValue == null || intervalValue == null) {
      takeAsNeeded = true;
    }
  }

  // Converts Object to JSON for uploading into Firebase
  Map<String, dynamic> toJSON() {
    final medicationRoutineData = {
      "id": id,
      "name": name,
      "quantity": quantity,
      "desc": desc,
      "takeAsNeeded": takeAsNeeded,
      "dosageCount": dosageCount,
      "intervalValue": intervalValue,
      "intervalUnit": intervalUnit,
    };

    return medicationRoutineData;
  }

  static Medication fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] ?? uuid.v4(),
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      desc: json['desc'] as String,
      takeAsNeeded: json['takeAsNeeded'] as bool,
      dosageCount: json['dosageCount'] as int?,
      intervalValue: json['intervalValue'] as int?,
      intervalUnit: json['intervalUnit'] as String?,
    );
  }

  /// Returns a string description of the frequency
  String frequencyString() {
    if (takeAsNeeded) {
      return 'Take as needed';
    }

    final tempInternalValueWithSpace = '$intervalValue ';

    return 'Take ${dosageCount ?? 0} times every '
        '${(intervalValue ?? 0) == 1 ? "" : tempInternalValueWithSpace}'
        '${intervalUnit ?? ""}${intervalValue != 1 ? "s" : ""}';
  }
}
