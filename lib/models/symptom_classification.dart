import 'package:wagtrack/models/symptom_enums.dart';
import 'package:wagtrack/models/symptom_model.dart';

/// Symptom classifier that takes in a `PetSymptomModel` and classifies it based on the triage
/// https://www.fourpawspetvet.com/sites/site-7145/images/main.jpg
///
/// Needs to be `PetSymptomModel` since it needs the list of symptoms of a pet.
SymptomLevel classifySymptom(Symptom symptom) {
  return SymptomLevel.green;
}
