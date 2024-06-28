import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

class SymptomsPage extends StatefulWidget {
  final Pet petData;
  const SymptomsPage({super.key, required this.petData});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  List<Symptom> pastSymptoms = [];
  List<Symptom> currentSymptoms = [];

  bool loaded = false;

  void getAllSymptoms() async {
    final SymptomService symptomService = context.watch<SymptomService>();
    List<Symptom> symptoms = await symptomService.getAllSymptomsByPetID(
        // The only way to access a Pet Page is if the Pet has an ID
        petID: widget.petData.petID!);
    symptomService.setPastCurrentSymptoms(symptoms: symptoms);
    pastSymptoms = symptomService.pastSymptoms;
    currentSymptoms = symptomService.currentSymptoms;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    if (!loaded) {
      getAllSymptoms();
      setState(() {
        loaded = true;
      });
    }
    final SymptomService symptomService = context.watch<SymptomService>();
    pastSymptoms = symptomService.pastSymptoms;
    currentSymptoms = symptomService.currentSymptoms;
    print("Hiii $pastSymptoms");

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Ongoing Symptoms',
          style: textStyles.headlineMedium,
        ),
        const SizedBoxh10(),
        if (currentSymptoms.isNotEmpty)
          Column(
            children: List.generate(currentSymptoms.length, (index) {
              return SymptomsCard(
                symptom: currentSymptoms[index],
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
        if (pastSymptoms.isNotEmpty)
          Column(
            children: List.generate(pastSymptoms.length, (index) {
              return SymptomsCard(
                symptom: pastSymptoms[index],
              );
            }),
          ),
      ]),
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
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final symptom = widget.symptom;

    return InkWell(
        onTap: _toggleExpansion,
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
                            "${formatDateTime(symptom.startDate).date} (${formatDateTime(symptom.startDate).time}) to \n${formatDateTime(symptom.startDate).date} (${formatDateTime(symptom.endDate!).time})",
                            style: textStyles.bodyMedium,
                          ),
                        _isExpanded
                            ? const Icon(Icons.expand_less)
                            : const Icon(Icons.expand_more)
                      ],
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBoxh10(),
                          Text(
                            getShortDescBySymptomName(symptom.symptom),
                            style: textStyles.bodyMedium!
                                .copyWith(fontStyle: FontStyle.italic),
                          ),
                          Wrap(
                            spacing: 10,
                            children:
                                List.generate(symptom.tags.length, (index) {
                              return Chip(
                                side: const BorderSide(style: BorderStyle.none),
                                label: Text("#${symptom.tags[index]}"),
                              );
                            }),
                          ),
                          if (symptom.factors != "")
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Text(
                                '\n"${symptom.factors}"',
                                style: textStyles.bodyMedium,
                              ),
                            ),
                          // const SizedBoxh10(),
                          // SizedBox(
                          //   width: double.infinity,
                          //   child: Text(
                          //     "hold for more options ...",
                          //     style: textStyles.bodySmall!
                          //         .copyWith(fontStyle: FontStyle.italic),
                          //   ),
                          // )
                        ],
                      ),
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 200),
                    ),
                  ]),
            ),
          ),
        ));
  }
}
