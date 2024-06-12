import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';

class AddSymptoms extends StatefulWidget {
  const AddSymptoms({super.key});

  @override
  State<AddSymptoms> createState() => _AddSymptomsState();
}

class _AddSymptomsState extends State<AddSymptoms> {
  late String selectedCategory = "General Symptoms";
  late String selectedSymptoms = "Lethargy";
  late String startDate = "";
  late String endDate = "";
  late DateTime startDateTime;
  late DateTime endDateTime;

  late List<String> filteredSymptoms = getSymptomsForCategory(selectedCategory);
  late String filteredSymptomsDesc =
      "Lethargy: Decreased energy or activity level.";

  late double _currentSliderValue = 5;

  TextEditingController factorsController = TextEditingController(text: null);

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final List<String> symptomCategories = petSymptoms
        .map<String>((symptomCategory) => symptomCategory['category'] as String)
        .toList();
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Add Symptoms",
              style: textStyles.bodyLarge,
            ),
          ],
        ),
        actions: const <Widget>[],
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
            selectedText: selectedSymptoms,
            onChanged: (String? value) {
              setState(() {
                selectedSymptoms = value!;
                filteredSymptomsDesc = getDescByName(selectedSymptoms);
              });
            },
          ),
          const SizedBoxh10(),
          Text(
            filteredSymptomsDesc,
            style: textStyles.bodyMedium,
          ),
          const SizedBoxh20(),
          Text(
            'Severity',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
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
                  value: _currentSliderValue,
                  max: 10,
                  divisions: 10,
                  label: _currentSliderValue.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _currentSliderValue = value;
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
                        _currentSliderValue.toInt().toString(),
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
          // Video By AVS END
          AppTextFormField(
            controller: factorsController,
            hintText: 'Possible Factors',
            prefixIcon: const Icon(Icons.brush_rounded),
          ),
          const SizedBoxh20(),
          InkWell(
            onTap: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2024, 1, 1),
                  maxTime: DateTime.now(), onConfirm: (date) {
                setState(() {
                  startDateTime = date;
                  startDate = "${date.hour} : ${date.minute}  "
                      "\n${date.day} / ${date.month} / ${date.year}";
                });
              }, onCancel: () {
                setState(() {
                  startDate = "";
                });
              }, currentTime: DateTime.now(), locale: LocaleType.en);
            },
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  child: SizedBox(
                    width: 170,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      child: startDate == ""
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Set Start Date",
                                  style: textStyles.bodyLarge!
                                      .copyWith(color: colorScheme.primary),
                                ),
                                Icon(Icons.date_range_rounded,
                                    size: 20, color: colorScheme.primary),
                              ],
                            )
                          : RichText(
                              text: TextSpan(
                                text: 'Start Date\n',
                                style: textStyles.bodyMedium!
                                    .copyWith(color: colorScheme.primary),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: startDate,
                                      style: textStyles.bodyMedium),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // End Date
          InkWell(
            onTap: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2024, 1, 1),
                  maxTime: DateTime.now(), onConfirm: (date) {
                setState(() {
                  endDateTime = date;
                  endDate = "${date.hour} : ${date.minute}  "
                      "\n${date.day} / ${date.month} / ${date.year}";
                });
              }, onCancel: () {
                setState(() {
                  endDate = "";
                });
              }, currentTime: DateTime.now(), locale: LocaleType.en);
            },
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  child: SizedBox(
                    width: 170,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      child: endDate == ""
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Set End Date",
                                      style: textStyles.bodyLarge!
                                          .copyWith(color: colorScheme.primary),
                                    ),
                                    Icon(Icons.date_range_rounded,
                                        size: 20, color: colorScheme.primary),
                                  ],
                                ),
                                Text("Ongoing (default)",
                                    style: textStyles.bodyMedium),
                              ],
                            )
                          : RichText(
                              text: TextSpan(
                                text: 'End Date\n',
                                style: textStyles.bodyMedium!
                                    .copyWith(color: colorScheme.primary),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: endDate,
                                      style: textStyles.bodyMedium),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBoxh20(),
          const SizedBoxh20(),

          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 300,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const Center(
                    child: Text(
                      'Add Symptoms',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
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
