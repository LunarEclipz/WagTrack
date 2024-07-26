// For Milestone 1, our location will be the following 5. In future, we
// may transit to using postal codes.

import 'package:wagtrack/shared/sg_geo.dart';

List<String> locationList = sgGeo["features"]
    .map((obg) => obg["properties"]["Name"] as String)
    .toList()
    .cast<String>();

List<String> sexList = <String>[
  "Female",
  "Female Spayed",
  "Male",
  "Male Neutered",
];

List<String> speciesList = <String>[
  "Cat",
  "Dog",
];

final List<Map<String, dynamic>> petSymptoms = [
  {
    'category': 'General Symptoms',
    'symptoms': [
      {
        'name': 'Lethargy',
        'description': 'Decreased energy or activity level.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Loss of appetite',
        'description': 'Refusal to eat or eat significantly less than usual.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Fever',
        'description': 'Higher than normal body temperature.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Weight loss or gain',
        'description': 'Unexplained changes in weight.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Vomiting',
        'description': 'Forcing out stomach contents.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Diarrhoea',
        'description': 'Loose or watery stools.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Difficulty breathing',
        'description': 'Laboured or rapid breathing.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Excessive thirst or urination',
        'description': 'Drinking or urinating more than usual.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Behavioural changes',
        'description': 'Unusual aggression, anxiety, hiding, or vocalisation.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Skin and Coat',
    'symptoms': [
      {
        'name': 'Itching',
        'description': 'Excessive scratching, licking, or biting at the skin.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Hair loss',
        'description': 'Patchy bald spots or overall thinning fur.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Redness, swelling, or irritation',
        'description': 'Inflammation on the skin\'s surface.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Rashes or bumps',
        'description': 'Skin abnormalities like pimples or scabs.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Eyes',
    'symptoms': [
      {
        'name': 'Squinting or redness',
        'description': 'Discomfort or irritation in the eyes.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Discharge',
        'description': 'Pus or watery drainage from the eyes.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Cloudy eyes',
        'description': 'Loss of transparency in the lens.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Ears',
    'symptoms': [
      {
        'name': 'Head shaking or tilting',
        'description': 'Signs of discomfort or pain in the ear.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Redness, swelling, or discharge',
        'description': 'Inflammation or infection in the ear canal.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Bad odour',
        'description': 'Unpleasant smell coming from the ears.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Digestive System',
    'symptoms': [
      {
        'name': 'Vomiting blood',
        'description': 'red or bloody vomit.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Diarrhoea with blood or mucus',
        'description': 'Presence of blood or mucus in stool.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Constipation',
        'description': 'Difficulty passing stool.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Abdominal pain',
        'description': 'Signs of discomfort when touched in the belly area.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Urinary System',
    'symptoms': [
      {
        'name': 'Straining to urinate',
        'description': 'Difficulty passing urine.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Urinary accidents',
        'description': 'Inability to control urination.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Blood in the urine',
        'description': 'Reddish tint to urine.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Musculoskeletal System',
    'symptoms': [
      {
        'name': 'Limping or lameness',
        'description': 'Difficulty walking or putting weight on a leg.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Swelling or stiffness',
        'description': 'Inflammation or pain in joints or muscles.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Difficulty getting up or down',
        'description': 'Struggling with basic movements.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
  {
    'category': 'Neurological System',
    'symptoms': [
      {
        'name': 'Seizures',
        'description': 'Uncontrolled shaking or jerking movements.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Head tremors',
        'description': 'Shaking of the head.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Disorientation or confusion',
        'description': 'Seeming lost or unaware of surroundings.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
      {
        'name': 'Walking in circles',
        'description': 'Repetitive circling behaviour.',
        'red': 7,
        'orange': 5,
        'yellow': 3,
        'green': 0,
      },
    ],
  },
];

List<String> getSymptomsForCategory(String chosenCategory) {
  if (petSymptoms.isEmpty) return []; // Handle empty petSymptoms list

  final matchingCategory = petSymptoms.firstWhere(
      (symptomCategory) => symptomCategory['category'] == chosenCategory,
      orElse: () => {'symptoms': []}); // Return empty symptom list

  return matchingCategory['symptoms']
      .map<String>((symptom) => symptom['name'] as String)
      .toList();
}

String getDescBySymptomName(String chosenSymptom) {
  if (petSymptoms.isEmpty) return ""; // Handle empty petSymptoms list

  for (var category in petSymptoms) {
    final matchingSymptom = category['symptoms'].firstWhere(
        (symptom) => symptom['name'] == chosenSymptom,
        orElse: () => {'name': '', 'description': ''}); // Return empty map
    if (matchingSymptom["description"] != '') {
      return matchingSymptom['name'] +
          ": " +
          matchingSymptom['description']; // Return description
    }
  }

  return ""; // Symptom not found
}

String getShortDescBySymptomName(String chosenSymptom) {
  if (petSymptoms.isEmpty) return ""; // Handle empty petSymptoms list

  for (var category in petSymptoms) {
    final matchingSymptom = category['symptoms'].firstWhere(
        (symptom) => symptom['name'] == chosenSymptom,
        orElse: () => {'name': '', 'description': ''}); // Return empty map
    if (matchingSymptom["description"] != '') {
      return matchingSymptom['description']; // Return description
    }
  }

  return ""; // Symptom not found
}

List<String> rolesList = <String>[
  "Caretaker",
  "Co-Owner",
];

List<String> tagFactorsList = [
  "Diet",
  "Exposure to Toxins",
  "Infectious Disease",
  "Parasites",
  "Stress",
  "Underlying Medical Condition",
  "Vaccinations",
  "Medications",
  "Age-related Changes",
  "Genetics",
  "Injury",
  "Foreign Object Ingestion",
  "Reproductive Issues",
  "Behavioral Problems",
  "Others",
];

List<String> postCategory = [
  "Play",
  "Diet",
  "Lifestyle",
  "Health",
  "Fashion",
];
