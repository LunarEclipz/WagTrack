import 'package:flutter/material.dart';
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
  late List<String> filteredSymptoms = getSymptomsForCategory(selectedCategory);
  late double _currentSliderValue = 5;

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final List<String> symptomCategories = petSymptoms
        .map<String>((symptomCategory) => symptomCategory['category'] as String)
        .toList();

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
              });
            },
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
          // Vet Care
          // Severity Scale Description
        ],
      ),
    );
  }
}
