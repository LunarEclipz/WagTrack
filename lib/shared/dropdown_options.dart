// For Milestone 1, our location will be the following 5. In future, we
// may transit to using postal codes.

List<String> locationList = <String>[
  "North",
  "North East",
  "South",
  "West",
  "Central"
];

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
        'description': 'Decreased energy or activity level.'
      },
      {
        'name': 'Loss of appetite',
        'description': 'Refusal to eat or eat significantly less than usual.'
      },
      {'name': 'Fever', 'description': 'Higher than normal body temperature.'},
      {
        'name': 'Weight loss or gain',
        'description': 'Unexplained changes in weight.'
      },
      {'name': 'Vomiting', 'description': 'Forcing out stomach contents.'},
      {'name': 'Diarrhoea', 'description': 'Loose or watery stools.'},
      {
        'name': 'Difficulty breathing',
        'description': 'Laboured or rapid breathing.'
      },
      {
        'name': 'Excessive thirst or urination',
        'description': 'Drinking or urinating more than usual.'
      },
      {
        'name': 'Behavioural changes',
        'description': 'Unusual aggression, anxiety, hiding, or vocalisation.'
      },
    ],
  },
  {
    'category': 'Skin and Coat',
    'symptoms': [
      {
        'name': 'Itching',
        'description': 'Excessive scratching, licking, or biting at the skin.'
      },
      {
        'name': 'Hair loss',
        'description': 'Patchy bald spots or overall thinning fur.'
      },
      {
        'name': 'Redness, swelling, or irritation',
        'description': 'Inflammation on the skin\'s surface.'
      },
      {
        'name': 'Rashes or bumps',
        'description': 'Skin abnormalities like pimples or scabs.'
      },
    ],
  },
  {
    'category': 'Eyes',
    'symptoms': [
      {
        'name': 'Squinting or redness',
        'description': 'Discomfort or irritation in the eyes.'
      },
      {
        'name': 'Discharge',
        'description': 'Pus or watery drainage from the eyes.'
      },
      {
        'name': 'Cloudy eyes',
        'description': 'Loss of transparency in the lens.'
      },
    ],
  },
  {
    'category': 'Ears',
    'symptoms': [
      {
        'name': 'Head shaking or tilting',
        'description': 'Signs of discomfort or pain in the ear.'
      },
      {
        'name': 'Redness, swelling, or discharge',
        'description': 'Inflammation or infection in the ear canal.'
      },
      {
        'name': 'Bad odour',
        'description': 'Unpleasant smell coming from the ears.'
      },
    ],
  },
  {
    'category': 'Digestive System',
    'symptoms': [
      {'name': 'Vomiting blood', 'description': 'Red or bloody vomit.'},
      {
        'name': 'Diarrhoea with blood or mucus',
        'description': 'Presence of blood or mucus in stool.'
      },
      {'name': 'Constipation', 'description': 'Difficulty passing stool.'},
      {
        'name': 'Abdominal pain',
        'description': 'Signs of discomfort when touched in the belly area.'
      },
    ],
  },
  {
    'category': 'Urinary System',
    'symptoms': [
      {
        'name': 'Straining to urinate',
        'description': 'Difficulty passing urine.'
      },
      {
        'name': 'Urinary accidents',
        'description': 'Inability to control urination.'
      },
      {'name': 'Blood in the urine', 'description': 'Reddish tint to urine.'},
    ],
  },
  {
    'category': 'Musculoskeletal System',
    'symptoms': [
      {
        'name': 'Limping or lameness',
        'description': 'Difficulty walking or putting weight on a leg.'
      },
      {
        'name': 'Swelling or stiffness',
        'description': 'Inflammation or pain in joints or muscles.'
      },
      {
        'name': 'Difficulty getting up or down',
        'description': 'Struggling with basic movements.'
      },
    ],
  },
  {
    'category': 'Neurological System',
    'symptoms': [
      {
        'name': 'Seizures',
        'description': 'Uncontrolled shaking or jerking movements.'
      },
      {'name': 'Head tremors', 'description': 'Shaking of the head.'},
      {
        'name': 'Disorientation or confusion',
        'description': 'Seeming lost or unaware of surroundings.'
      },
      {
        'name': 'Walking in circles',
        'description': 'Repetitive circling behaviour.'
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

String getDescByName(String chosenSymptom) {
  if (petSymptoms.isEmpty) return ""; // Handle empty petSymptoms list

  for (var category in petSymptoms) {
    final matchingSymptom = category['symptoms'].firstWhere(
        (symptom) => symptom['name'] == chosenSymptom,
        orElse: () => {'name': '', 'description': ''}); // Return empty map
    print(matchingSymptom);
    if (matchingSymptom["description"] != '') {
      return matchingSymptom['name'] +
          ": " +
          matchingSymptom['description']; // Return description
    }
  }

  return ""; // Symptom not found
}

List<String> rolesList = <String>[
  "Caretaker",
  "Co-Owner",
  "Owner",
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
