import 'package:wagtrack/models/pet_model.dart';

class PetSymptomModel {
  late Pet pet;
  late List<Symptom> symptoms;
}

class Symptom {
  late String category;
  late String symptom;
  late String factors;

  late int severity;
  late DateTime startDate;
  late bool hasEnd;
  late DateTime? endDate;

  Symptom(
      {required this.category,
      required this.symptom,
      required this.factors,
      required this.startDate,
      required this.severity,
      this.endDate,
      required this.hasEnd});
}
