import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/medication_model.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/screens/symptoms/symptoms.dart';
import 'package:wagtrack/services/medication_service.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class MedsAddRoutine extends StatefulWidget {
  final Pet petData;
  const MedsAddRoutine({super.key, required this.petData});

  @override
  State<MedsAddRoutine> createState() => _MedsAddRoutineState();
}

class _MedsAddRoutineState extends State<MedsAddRoutine> {
  late TextEditingController titleController =
      TextEditingController(text: null);
  late TextEditingController clinicNameController =
      TextEditingController(text: null);
  late TextEditingController appointmentNumberController =
      TextEditingController(text: null);
  late TextEditingController diagnosisController =
      TextEditingController(text: null);
  late TextEditingController commentsController =
      TextEditingController(text: null);
  late TextEditingController medNameController =
      TextEditingController(text: null);
  late TextEditingController medQuantityController =
      TextEditingController(text: null);
  late TextEditingController medDescController =
      TextEditingController(text: null);
  late List<Symptom> symtomsTagged = [];
  late List<Medication> medicationList = [];

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final CustomColors customColors = AppTheme.customColors;
    final SymptomService symptomService = context.watch<SymptomService>();
    final MedicationService medicationService =
        context.watch<MedicationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Routine',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: AppScrollablePage(
          children: [
            // Section A : Pet Type
            Text(
              'Routine Details',
              style: textStyles.headlineMedium,
            ),
            AppTextFormField(
              controller: titleController,
              hintText: 'Routine Title',
              prefixIcon: const Icon(Icons.title_rounded),
            ),
            AppTextFormField(
              controller: clinicNameController,
              hintText: 'Clinic Name',
              prefixIcon: const Icon(Icons.local_hospital_rounded),
            ),
            AppTextFormField(
              controller: appointmentNumberController,
              hintText: 'Appointment Number',
              prefixIcon: const Icon(Icons.app_registration_outlined),
            ),

            // List all symptoms card, or add a new symptom
            const SizedBoxh20(),
            Text(
              'Medications',
              style: textStyles.headlineMedium,
            ),
            AppTextFormField(
              controller: medNameController,
              hintText: 'Medication Name (incl. Volume)',
              prefixIcon: const Icon(Icons.medication_liquid_rounded),
            ),
            AppTextFormField(
              controller: medQuantityController,
              hintText: 'Quantity',
              prefixIcon: const Icon(Icons.numbers_rounded),
            ),
            AppTextFormField(
              controller: medDescController,
              hintText: 'Description',
              prefixIcon: const Icon(Icons.description),
            ),
            const SizedBoxh10(),
            InkWell(
              onTap: () {
                if (medNameController.text != "" &&
                    medDescController.text != "" &&
                    medQuantityController.text != "") {
                  setState(() {
                    medicationList.add(Medication(
                        name: medNameController.text,
                        quantity: medQuantityController.text,
                        desc: medDescController.text));
                    medNameController.text = "";
                    medQuantityController.text = "";
                    medDescController.text = "";
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: colorScheme.primary,
                    ),
                    Text(
                      '   Add Medication',
                      style: textStyles.bodyMedium!
                          .copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            if (medicationList.isNotEmpty)
              Column(
                children: List.generate(medicationList.length, (index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        medicationList.remove(medicationList[index]);
                      });
                    },
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.medication_liquid_rounded),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicationList[index].name,
                                    style: textStyles.bodyLarge,
                                  ),
                                  Text(
                                    medicationList[index].quantity,
                                    style: textStyles.bodyMedium,
                                  ),
                                  Text(
                                    "\"${medicationList[index].desc}\"",
                                    style: textStyles.bodyMedium,
                                  ),
                                ],
                              ),
                              const Icon(Icons.close_rounded),
                            ]),
                      ),
                    ),
                  );
                }),
              ),
            const SizedBoxh20(),

            // Additional Information
            Text(
              'Addional Information',
              style: textStyles.headlineMedium,
            ),
            AppTextFormField(
              controller: diagnosisController,
              hintText: 'Diagnosis',
              prefixIcon: const Icon(Icons.sick_rounded),
            ),
            AppTextFormField(
              controller: commentsController,
              hintText: 'Comments',
              prefixIcon: const Icon(Icons.chat_bubble_rounded),
            ),

            // Symptoms
            const SizedBoxh20(),
            Text(
              'Symptoms Tagging',
              style: textStyles.headlineMedium,
            ),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (BuildContext thisContext) {
                      List<Symptom> allSymptoms = symptomService.pastSymptoms +
                          symptomService.currentSymptoms;
                      return AlertDialog(
                        title: const Text("Symptoms"),
                        content: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  '${allSymptoms.length} symptom records.',
                                  style: textStyles.bodyMedium!
                                      .copyWith(color: colorScheme.primary),
                                ),
                              ),
                              if (allSymptoms.isEmpty)
                                Text(
                                  'You have not recorded any symptom',
                                  style: textStyles.bodyMedium!
                                      .copyWith(color: colorScheme.primary),
                                ),
                              Column(
                                children:
                                    List.generate(allSymptoms.length, (index) {
                                  return DropdownMenuItem(
                                      child: SymptomsCard(
                                          buttonText: "Select",
                                          buttonFn: () {
                                            if (!symtomsTagged
                                                .contains(allSymptoms[index])) {
                                              setState(() {
                                                symtomsTagged
                                                    .add(allSymptoms[index]);
                                              });
                                            }
                                            Navigator.of(thisContext).pop();
                                          },
                                          symptom: allSymptoms[index]));
                                }),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: colorScheme.primary,
                    ),
                    Text(
                      '   Search All Symptoms',
                      style: textStyles.bodyMedium!
                          .copyWith(color: colorScheme.primary),
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: List.generate(symtomsTagged.length, (index) {
                return SymptomsCard(
                    buttonText: "Remove",
                    buttonFn: () {
                      setState(() {
                        symtomsTagged.remove(symtomsTagged[index]);
                      });
                    },
                    symptom: symtomsTagged[index]);
              }),
            ),
            const SizedBoxh20(), const SizedBoxh20(),

            // Add Button
            Center(
              child: InkWell(
                onTap: () {
                  // TODO: Add validations
                  if (titleController.text != "" &&
                      clinicNameController.text != "" &&
                      appointmentNumberController.text != "" &&
                      diagnosisController.text != "" &&
                      commentsController.text != "" &&
                      medicationList != []) {
                    MedicationRoutine formData = MedicationRoutine(
                        title: titleController.text,
                        clinicName: clinicNameController.text,
                        appointmentNumber: appointmentNumberController.text,
                        diagnosis: diagnosisController.text,
                        comments: commentsController.text,
                        symptomsID: symtomsTagged
                            .map((symptoms) => symptoms.oid!)
                            .toList(),
                        symptomsName: symtomsTagged
                            .map((symptoms) => symptoms.symptom)
                            .toList(),
                        medications: medicationList,
                        petID: widget.petData.petID!);
                    medicationService.addMedicationRoutines(formData: formData);
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          'Add Routine',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
