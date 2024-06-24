import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

class SymptomsPage extends StatefulWidget {
  final Pet petData;
  const SymptomsPage({super.key, required this.petData});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  List<Symptom> symptoms = [];

  // TODO: Split by current & past
  Future<void> getInitData() async {
    try {
      final retrivedSymptoms =
          await SymptomService().getAllPetsByUID(petID: widget.petData.petID!);
      setState(() {
        symptoms = retrivedSymptoms;
      });
    } catch (e) {
      // print("Error fetching pets: $e");
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    // TODO: Need help ensuring that when Add Symptom is done, this function is called
    getInitData();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Ongoing Symptoms',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          if (symptoms.isNotEmpty)
            Column(
              children: List.generate(symptoms.length, (index) {
                return SymptomsCard(
                  symptom: symptoms[index],
                );
              }),
            ),
          const SizedBoxh20(),
          const Divider(),
          const SizedBoxh20(),
          Text(
            'Past Symptoms',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
        ]),
      ),
    );
  }
}

class SymptomsCard extends StatefulWidget {
  final Symptom symptom;
  const SymptomsCard({super.key, required this.symptom});

  @override
  State<SymptomsCard> createState() => _SymptomsCardState();
}

class _SymptomsCardState extends State<SymptomsCard> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final symptom = widget.symptom;

    return InkWell(
        onTap: () {},
        child: Card(
          color: Colors.white,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          side: const BorderSide(style: BorderStyle.none),
                          avatar: CircleAvatar(
                            backgroundColor: customColors.green,
                          ),
                          label: Text(
                            '#Medication378',
                            style: textStyles.bodyMedium,
                          ),
                        ),
                        CircleAvatar(
                          radius: 15,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            symptom.severity.toString(),
                            style: textStyles.bodyLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      symptom.symptom,
                      style: textStyles.bodyLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (!symptom.hasEnd)
                          Text(
                            "${formatDateTime(symptom.startDate).date} (${formatDateTime(symptom.startDate).time}) to Now",
                            style: textStyles.bodyMedium,
                          ),
                        if (symptom.hasEnd)
                          Text(
                            "${formatDateTime(symptom.startDate).date} (${formatDateTime(symptom.startDate).time}) to \n${symptom.endDate})",
                            style: textStyles.bodyMedium,
                          ),
                        const Icon(Icons.expand_more_rounded)
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
