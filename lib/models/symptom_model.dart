import 'package:wagtrack/models/pet_model.dart';

class PetSymptomModel {
  late Pet pet;
  late List<Symptom> symptoms;
}

class Symptom {
  /// Category of symptom.
  late String category;

  /// Exact name of symptom.
  late String symptom;

  /// Possible factors for symptom.
  late String factors;

  /// List of tags.
  late List<String> tags;

  /// Level of symptom severity.
  late int severity;

  /// Start date of symptom. Always required.
  late DateTime startDate;

  /// Whether this symptom has an end date.
  late bool hasEnd;

  /// End date of symptom.
  late DateTime? endDate;

  /// PetID of Pet which is associated with this symptom
  late String petID;

  /// Document id that represents symptom
  String? oid;

  /// medication ids
  List<String> mid;

  /// medication mNames
  List<String> mName;

  Symptom(
      {required this.category,
      required this.symptom,
      required this.factors,
      required this.startDate,
      required this.severity,
      required this.tags,
      required this.petID,
      this.endDate,
      this.oid,
      List<String>? mid,
      List<String>? mName,
      required this.hasEnd})
      : mid = mid ?? [],
        mName = mName ?? [];

// Converts Object to JSON for uploading into Firebase
  Map<String, dynamic> toJSON() {
    final symptomData = {
      "category": category,
      "symptom": symptom,
      "factors": factors,
      "startDate": startDate.millisecondsSinceEpoch,
      "severity": severity,
      "tags": tags,
      "endDate": endDate?.millisecondsSinceEpoch,
      "hasEnd": hasEnd,
      "petID": petID,
    };

    return symptomData;
  }

  static Symptom fromJson(Map<String, dynamic> json) {
    return Symptom(
      category: json['category'] as String,
      symptom: json['symptom'] as String,
      factors: json['factors'] as String,
      tags:
          (json['tags'] as List).cast<String>(), // Convert tags to String list
      severity: json['severity'] as int,
      startDate: DateTime.fromMillisecondsSinceEpoch(json['startDate'] as int),
      hasEnd: json['hasEnd'] as bool,
      endDate: json['endDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['endDate'] as int)
          : null,
      petID: json['petID'] as String,
      mid: (json['mid'] as List).cast<String>(), // Convert tags to String list
      mName:
          (json['mName'] as List).cast<String>(), // Convert tags to String list
    );
  }
}
