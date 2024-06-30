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

  late String petID;
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

class Medication {
  late String name;
  late String quantity;
  late String desc;
  Medication({
    required this.name,
    required this.quantity,
    required this.desc,
  });
  // next milestone
  // late String repeat;
  // late DateTime start;
  // late DateTime end;

  // Converts Object to JSON for uploading into Firebase
  Map<String, dynamic> toJSON() {
    final medicationRoutineData = {
      "name": name,
      "quantity": quantity,
      "desc": desc,
    };

    return medicationRoutineData;
  }

  static Medication fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] as String,
      quantity: json['quantity'] as String,
      desc: json['desc'] as String,
    );
  }
}
