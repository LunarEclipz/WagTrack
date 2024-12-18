import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/medication_model.dart';
import 'package:wagtrack/models/notification_model.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/screens/symptoms/symptoms.dart';
import 'package:wagtrack/services/medication_service.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class MedsEditRoutine extends StatefulWidget {
  final MedicationRoutine routineData;
  const MedsEditRoutine({
    super.key,
    required this.routineData,
  });

  @override
  State<MedsEditRoutine> createState() => _MedsEditRoutineState();
}

class _MedsEditRoutineState extends State<MedsEditRoutine> {
  // Form Keys
  final _medicationFormKey = GlobalKey<FormState>();
  final _medicationFreqFormKey = GlobalKey<FormState>();
  final _routineFormKey = GlobalKey<FormState>();
  final _addInfoFormKey = GlobalKey<FormState>();

  // Text Controllers - init
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

  /// Controllers for medication frequency
  final TextEditingController _dosageCountController = TextEditingController();
  final TextEditingController _intervalValueController =
      TextEditingController();
  late String _selectedInterval = "day";
  bool takeAsNeeded = true;
  bool isFrequencyValid = true;

  /// Lists
  late List<Symptom> symptomsTagged = [];
  late List<Medication> medicationList = [];

  // State booleans
  bool _showMedicationsRequired = false;
  AutovalidateMode _overrideMedAutovalidateMode =
      AutovalidateMode.onUserInteraction;

  // TODO this doesn't work atm
  void _resetMedAutovalidateMode() {
    setState(() {
      _overrideMedAutovalidateMode = AutovalidateMode.disabled;
    });

    // Delay re-enabling the auto-validation to ensure the UI is updated
    Future.delayed(const Duration(milliseconds: 10), () {
      setState(() {
        _overrideMedAutovalidateMode = AutovalidateMode.onUserInteraction;
      });
    });
  }

  /// sets frequency validadity and updates state
  void _setFrequencyValid(bool isValid) {
    setState(() {
      isFrequencyValid = isValid;
    });
  }

  // set up autofilled data
  @override
  void initState() {
    super.initState();

    final routineData = widget.routineData;

    titleController.text = routineData.title;
    clinicNameController.text = routineData.clinicName;
    appointmentNumberController.text = routineData.appointmentNumber;
    diagnosisController.text = routineData.diagnosis;
    commentsController.text = routineData.comments;

    // medicationList is cloned so the original is not edited
    medicationList = routineData.medications.toList();

    // To get the symptoms - need to use SymptomService
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      SymptomService symptomService =
          Provider.of<SymptomService>(context, listen: false);

      // need to ste state after the symptoms are obtained
      setState(() {
        symptomsTagged =
            symptomService.getSymptomsFromIDs(routineData.symptomsID);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // final CustomColors customColors = AppTheme.customColors;
    final SymptomService symptomService = context.watch<SymptomService>();
    final MedicationService medicationService =
        context.watch<MedicationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Routine',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: DefaultTextStyle.merge(
        style: textStyles.bodyLarge,
        child: AppScrollablePage(
          children: [
            // SECTION: Routine Details
            Text(
              'Routine Details',
              style: textStyles.headlineMedium,
            ),
            Form(
              key: _routineFormKey,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: titleController,
                    hintText: 'Routine Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                  AppTextFormField(
                    controller: clinicNameController,
                    hintText: 'Clinic Name',
                    prefixIcon: const Icon(Icons.local_hospital_rounded),
                    showOptional: true,
                  ),
                  AppTextFormField(
                    controller: appointmentNumberController,
                    hintText: 'Appointment Number',
                    prefixIcon: const Icon(Icons.app_registration_outlined),
                    showOptional: true,
                  ),
                ],
              ),
            ),

            // SECTION: Medications =======================================================
            const SizedBoxh20(),
            Text(
              'Medications',
              style: textStyles.headlineMedium,
            ),
            if (_showMedicationsRequired && medicationList.isEmpty)
              Text(
                "At least one medication required",
                style:
                    textStyles.bodyMedium!.copyWith(color: colorScheme.primary),
              ),
            Form(
              key: _medicationFormKey,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: medNameController,
                    hintText: 'Medication Name (incl. Volume)',
                    prefixIcon: const Icon(Icons.medication_liquid_rounded),
                    validator: (value) => value == null || value.isEmpty
                        ? "Please enter a medication name"
                        : null,
                    autovalidateMode: _overrideMedAutovalidateMode,
                  ),
                  AppTextFormField(
                    controller: medQuantityController,
                    hintText: 'Quantity',
                    prefixIcon: const Icon(Icons.numbers_rounded),
                    autovalidateMode: _overrideMedAutovalidateMode,
                    // no validator for qnty:
                    // siknce a valid medication qnty could be like 2 tablets 3 times a day
                  ),
                  AppTextFormField(
                    controller: medDescController,
                    hintText: 'Description',
                    prefixIcon: const Icon(Icons.description),
                    showOptional: true,
                    autovalidateMode: _overrideMedAutovalidateMode,
                  ),
                ],
              ),
            ),
            const SizedBoxh10(),

            // setting the frequency
            _medicationFrequencyForm(context),
            Text(
              'Leave empty if the medication is meant to be taken as needed.',
              style: textStyles.bodyMedium,
            ),

            const SizedBoxh10(),

            // "Add Medication" Button
            InkWell(
              onTap: () {
                // form validations
                bool medValidation =
                    _medicationFormKey.currentState!.validate();
                bool medFreqValidation =
                    _medicationFreqFormKey.currentState!.validate();

                // first do the frequency validation
                // so the duration checks will run even if medValidation doesn't
                // pass
                if (!medFreqValidation) return;

                // do duration checks
                int? dosageCount = _dosageCountController.text.isEmpty
                    ? null
                    : int.parse(_dosageCountController.text);
                int? intervalValue = _intervalValueController.text.isEmpty
                    ? null
                    : int.parse(_intervalValueController.text);

                // first check if the duration is valid
                final intervalDuration = recurringFrequencyToInterval(
                  dosageCount: dosageCount,
                  intervalValue: intervalValue,
                  intervalUnit: _selectedInterval,
                );
                // debugPrint('${intervalDuration!.inSeconds}');
                if (!isDurationValidForRecurringNotification(
                  intervalDuration,
                )) {
                  // invalid:
                  // set isFrequencyValid
                  _setFrequencyValid(false);
                  return;
                } else {
                  _setFrequencyValid(true);
                }

                if (!medValidation) return;

                // all validations pass! Add to medication list
                setState(() {
                  medicationList.add(Medication(
                    name: medNameController.text,
                    quantity: medQuantityController.text,
                    desc: medDescController.text,
                    dosageCount: dosageCount,
                    intervalValue: intervalValue,
                    intervalUnit: _selectedInterval,
                  ));

                  // reset controllers
                  medNameController.text = "";
                  medQuantityController.text = "";
                  medDescController.text = "";
                  _dosageCountController.text = "";
                  _intervalValueController.text = "";

                  // reset bools
                  takeAsNeeded = true;
                  isFrequencyValid = true;

                  // temporarily reset autovalidationmode. not really working
                  _resetMedAutovalidateMode();

                  // unfocus fields
                  FocusScope.of(context).unfocus();
                });
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

            // SECTION: Additional Information
            Text(
              'Addional Information',
              style: textStyles.headlineMedium,
            ),
            Form(
              key: _addInfoFormKey,
              child: Column(
                children: [
                  AppTextFormField(
                    controller: diagnosisController,
                    hintText: 'Diagnosis',
                    prefixIcon: const Icon(Icons.sick_rounded),
                  ),
                  AppTextFormField(
                    controller: commentsController,
                    hintText: 'Comments',
                    prefixIcon: const Icon(Icons.chat_bubble_rounded),
                    showOptional: true,
                  ),
                ],
              ),
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
                                            if (!symptomsTagged
                                                .contains(allSymptoms[index])) {
                                              setState(() {
                                                symptomsTagged
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
              children: List.generate(symptomsTagged.length, (index) {
                return SymptomsCard(
                    buttonText: "Remove",
                    buttonFn: () {
                      setState(() {
                        symptomsTagged.remove(symptomsTagged[index]);
                      });
                    },
                    symptom: symptomsTagged[index]);
              }),
            ),
            const SizedBoxh20(), const SizedBoxh20(),

            // "Add Routine" Button
            Center(
              child: InkWell(
                onTap: () {
                  setState(() {
                    // sets states that need to show stuff post-validation
                    // for validations that don't rely on the forms
                    _showMedicationsRequired = true;
                  });

                  // validate
                  bool routineValidation =
                      _routineFormKey.currentState!.validate();
                  bool addInfoValidation =
                      _addInfoFormKey.currentState!.validate();

                  if (routineValidation &&
                      addInfoValidation &&
                      medicationList.isNotEmpty) {
                    // Update routine
                    medicationService.updateMedicationRoutine(
                      id: widget.routineData.oid ?? "",
                      title: titleController.text,
                      clinicName: clinicNameController.text,
                      appointmentNumber: appointmentNumberController.text,
                      diagnosis: diagnosisController.text,
                      comments: commentsController.text,
                      symptomsID: symptomsTagged
                          .map((symptoms) => symptoms.oid!)
                          .toList(),
                      symptomsName: symptomsTagged
                          .map((symptoms) => symptoms.symptom)
                          .toList(),
                      medications: medicationList,
                    );

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
                          'Update Routine',
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

  Widget _medicationFrequencyForm(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Form(
      key: _medicationFreqFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFrequencyValid)
            Text(
              'Interval must be at least 1 minute long.',
              style: textStyles.bodySmall!.copyWith(
                color: colorScheme.primary,
              ),
            ),

          // main medicationFreq input
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Take',
                style: textStyles.bodyLarge!
                    .copyWith(color: AppTheme.customColors.secondaryText),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                // height: 50,
                // width: 20,
                child: AppTextFormField(
                  controller: _dosageCountController,
                  hintText: '',
                  validator: (value) =>
                      (value != null && value.isNotEmpty && !_isInt(value))
                          ? ""
                          : null,
                  autovalidateMode: AutovalidateMode.disabled,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                'times every',
                style: textStyles.bodyLarge!
                    .copyWith(color: AppTheme.customColors.secondaryText),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                // height: 50,
                // width: 20,
                child: AppTextFormField(
                  controller: _intervalValueController,
                  hintText: '',
                  validator: (value) =>
                      (value != null && value.isNotEmpty && !_isInt(value))
                          ? ""
                          : null,
                  autovalidateMode: AutovalidateMode.disabled,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              SizedBox(
                  width: 100,
                  height: 80,
                  child: AppDropdown(
                    optionsList: const <String>[
                      'minute',
                      'hour',
                      'day',
                      'month',
                      'year'
                    ],
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedInterval = newValue!;
                      });
                    },
                    selectedText: _selectedInterval,
                  ))
            ],
          ),
        ],
      ),
    );
  }

  // TODO Temporary numeric validators
  bool _isInt(String str) {
    return int.tryParse(str) != null;
  }
}
