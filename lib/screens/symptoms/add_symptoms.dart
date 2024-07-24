import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/components/button_components.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/utils.dart';

class AddSymptomsPage extends StatefulWidget {
  final Pet petData;
  const AddSymptomsPage({super.key, required this.petData});

  @override
  State<AddSymptomsPage> createState() => _AddSymptomsPageState();
}

class _AddSymptomsPageState extends State<AddSymptomsPage> {
  // Selections
  late String selectedCategory = "General Symptoms";
  late String selectedSymptom = "Lethargy";
  late String selectedTag = "";
  late List<String> tags = [];

  late bool isStartDateSet = false;
  late bool isEndDateSet = false;

  // Date picks
  late DateTime startDateTime;
  late DateTime endDateTime;

  // symptom selections
  late List<String> filteredSymptoms = getSymptomsForCategory(selectedCategory);
  late String filteredSymptomsDesc =
      "Lethargy: Decreased energy or activity level.";

  late double _currentSeveritySliderValue = 5;

  TextEditingController factorsController = TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final List<String> symptomCategories = petSymptoms
        .map<String>((symptomCategory) => symptomCategory['category'] as String)
        .toList();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final SymptomService symptomService = context.watch<SymptomService>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Add Symptoms",
              // style: textStyles.bodyLarge,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: AppScrollablePage(
        children: [
          Text(
            'Symptoms',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          AppDropdown(
            optionsList: symptomCategories,
            selectedText: selectedCategory,
            onChanged: (String? value) {
              setState(() {
                selectedCategory = value!;
                filteredSymptoms = getSymptomsForCategory(selectedCategory);
              });
            },
          ),
          const SizedBoxh10(),
          AppDropdown(
            optionsList: filteredSymptoms,
            selectedText: selectedSymptom,
            onChanged: (String? value) {
              setState(() {
                selectedSymptom = value!;
                filteredSymptomsDesc = getDescBySymptomName(selectedSymptom);
              });
            },
          ),
          const SizedBoxh10(),
          Text(
            filteredSymptomsDesc,
            style: textStyles.bodyMedium,
          ),

          const SizedBoxh10(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2024, 1, 1),
                        maxTime: DateTime.now(), onConfirm: (date) {
                      setState(() {
                        startDateTime = date;
                        isStartDateSet = true;
                      });
                    }, onCancel: () {
                      setState(() {
                        isStartDateSet = false;
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                            8,
                          ),
                          child: isStartDateSet == false
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Set Start",
                                          style: textStyles.bodyLarge!.copyWith(
                                              color: colorScheme.primary),
                                        ),
                                        Icon(Icons.date_range_rounded,
                                            size: 20,
                                            color: colorScheme.primary),
                                      ],
                                    ),
                                    Text("Mandatory*",
                                        style: textStyles.bodyMedium!.copyWith(
                                            color: colorScheme.primary)),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Set Start",
                                          style: textStyles.bodyLarge!.copyWith(
                                              color: colorScheme.primary),
                                        ),
                                        Icon(Icons.date_range_rounded,
                                            size: 20,
                                            color: colorScheme.primary),
                                      ],
                                    ),
                                    Text(formatDateTime(startDateTime).time,
                                        style: textStyles.bodyLarge),
                                    Text(formatDateTime(startDateTime).date,
                                        style: textStyles.labelLarge),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ), // End Date
              Flexible(
                flex: 1,
                child: InkWell(
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        minTime: DateTime(2024, 1, 1),
                        maxTime: DateTime.now(), onConfirm: (date) {
                      setState(() {
                        endDateTime = date;
                        isEndDateSet = true;
                      });
                    }, onCancel: () {
                      setState(() {
                        isEndDateSet = false;
                      });
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(
                            8,
                          ),
                          child: isEndDateSet == false
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Set End",
                                          style: textStyles.bodyLarge!.copyWith(
                                              color: colorScheme.primary),
                                        ),
                                        Icon(Icons.date_range_rounded,
                                            size: 20,
                                            color: colorScheme.primary),
                                      ],
                                    ),
                                    Text("Ongoing (default)",
                                        style: textStyles.bodyMedium),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Ended On",
                                          style: textStyles.bodyLarge!.copyWith(
                                              color: colorScheme.primary),
                                        ),
                                        Icon(Icons.date_range_rounded,
                                            size: 20,
                                            color: colorScheme.primary),
                                      ],
                                    ),
                                    Text(formatDateTime(endDateTime).time,
                                        style: textStyles.bodyLarge),
                                    Text(formatDateTime(endDateTime).date,
                                        style: textStyles.labelLarge),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBoxh20(),
          Text(
            'Notes',
            style: textStyles.headlineMedium,
          ),

          AppTextFormField(
            controller: factorsController,
            hintText: 'Possible Factors',
            prefixIcon: const Icon(Icons.brush_rounded),
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () {
              // Dropdown Options
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Possible Factors"),
                      content: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children:
                              List.generate(tagFactorsList.length, (index) {
                            return InkWell(
                              onTap: () {
                                if (!tags.contains(tagFactorsList[index])) {
                                  setState(() {
                                    tags.add(tagFactorsList[index]);
                                  });
                                }
                                Navigator.of(context).pop();
                              },
                              child: DropdownMenuItem(
                                  child: Text(tagFactorsList[index])),
                            );
                          }),
                        ),
                      ),
                    );
                  });
            },
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Add a Tag ',
                    style: textStyles.bodyMedium!
                        .copyWith(color: colorScheme.primary),
                  ),
                ),
                Icon(
                  Icons.add_circle_rounded,
                  color: colorScheme.primary,
                  size: 15,
                )
              ],
            ),
          ),
          Wrap(
            spacing: 10,
            children: List.generate(tags.length, (index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    tags.removeAt(index);
                  });
                },
                child: Chip(
                  side: const BorderSide(style: BorderStyle.none),
                  label: Text("#${tags[index]}"),
                ),
              );
            }),
          ),
          const SizedBoxh20(),
          Text(
            'Severity',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),

          // Video By AVS START
          Card(
            color: Colors.black54,
            child: SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        _currentSeveritySliderValue.toInt().toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBoxh20(),
                    const Text(
                      "Pending Video of different symptoms severity from AVS",
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Flexible(
                flex: 1,
                child: Text(
                  '1',
                  style: textStyles.bodyLarge,
                ),
              ),
              Flexible(
                flex: 12,
                child: Slider(
                  value: _currentSeveritySliderValue,
                  max: 10,
                  divisions: 10,
                  label: _currentSeveritySliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSeveritySliderValue = value;
                    });
                  },
                ),
              ),
              Flexible(
                flex: 1,
                child: Text(
                  '10',
                  style: textStyles.bodyLarge,
                ),
              ),
            ],
          ),

          // Video By AVS END
          const SizedBoxh20(),
          const SizedBoxh20(),

          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: AppButtonLarge(
                onTap: () {
                  // category and symptom has been set, start date has been set
                  if (selectedCategory != "" &&
                      selectedSymptom != "" &&
                      isStartDateSet == true) {
                    Symptom formData = !isEndDateSet
                        ? Symptom(
                            petID: widget.petData.petID!,
                            // Add symptom can only be accessed through PetID
                            category: selectedCategory,
                            symptom: selectedSymptom,
                            factors: factorsController.text,
                            startDate: startDateTime,
                            severity: _currentSeveritySliderValue.toInt(),
                            tags: tags,
                            // end date is not set - ongoing
                            hasEnd: isEndDateSet,
                          )
                        : Symptom(
                            petID: widget.petData.petID!,
                            // Add symptom can only be accessed through PetID
                            category: selectedCategory,
                            symptom: selectedSymptom,
                            factors: factorsController.text,
                            startDate: startDateTime,
                            severity: _currentSeveritySliderValue.toInt(),
                            tags: tags,
                            // end date is set
                            hasEnd: isEndDateSet,
                            endDate: endDateTime);
                    symptomService.addSymptom(formData: formData);
                    Navigator.pop(context);
                  }
                },
                width: 300,
                height: 40,
                text: 'Add Symptoms',
              ),
            ),
          ),
          // Possible Env Factors
          // Vet Care
          // Severity Scale Description
        ],
      ),
    );
  }
}
