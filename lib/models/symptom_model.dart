import 'package:wagtrack/models/pet_model.dart';

class PetSymptomModel {
  late Pet pet;
  late List<Symptom> symptoms;
}

class Symptom {
  late String category;
  late String symptom;
  late String factors;
  late List<String> tags;
  late int severity;
  late DateTime startDate;
  late bool hasEnd;
  late DateTime? endDate;
  late String petID;
  String? oid;
  List<String>? mid = [];
  List<String>? mName = [];

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
      this.mid,
      this.mName,
      required this.hasEnd});

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
