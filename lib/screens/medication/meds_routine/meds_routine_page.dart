import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/medication_model.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/medication/meds_routine/meds_add_routine.dart';
import 'package:wagtrack/screens/medication/meds_routine/meds_edit_routine.dart';
import 'package:wagtrack/services/medication_service.dart';
import 'package:wagtrack/shared/components/button_components.dart';
import 'package:wagtrack/shared/components/dialogs.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class MedsRoutinePage extends StatefulWidget {
  final Pet petData;
  const MedsRoutinePage({super.key, required this.petData});

  @override
  State<MedsRoutinePage> createState() => _MedsRoutinePageState();
}

class _MedsRoutinePageState extends State<MedsRoutinePage> {
  List<MedicationRoutine> medicationRoutine = [];
  bool loaded = false;

  void getAllMedicationRoutine() async {
    final MedicationService medicationService =
        context.watch<MedicationService>();
    List<MedicationRoutine> medicationRoutine =
        await medicationService.getAllMedicationRoutineByPetID(
            first: false,
            // The only way to access a Pet Page is if the Pet has an ID
            petID: widget.petData.petID!);
    medicationService.setMedicationRoutines(
        medicationRoutines: medicationRoutine);
  }

  @override
  Widget build(BuildContext context) {
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (!loaded) {
      getAllMedicationRoutine();
      setState(() {
        loaded = true;
      });
    }
    final MedicationService medicationService =
        context.watch<MedicationService>();
    medicationRoutine = medicationService.medicationRoutines;
    // print(medicationRoutine);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: AppButtonLarge(
              onTap: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.ease;
                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(
                        milliseconds: 300), // Adjust the duration here
                    pageBuilder: (context, a, b) => MedsAddRoutine(
                      petData: widget.petData,
                    ),
                  ),
                );
              },
              buttonTextPrefix: const Icon(
                Icons.add_rounded,
                color: Colors.white,
              ),
              text: 'Add Routine',
            ),
          ),
          const SizedBoxh20(),
          if (medicationRoutine.isNotEmpty)
            Column(
              children: List.generate(medicationRoutine.length, (index) {
                return MedicationRoutineCard(
                  medicationRoutine: medicationRoutine[index],
                );
              }),
            )
        ],
      ),
    );
  }
}

class MedicationRoutineCard extends StatefulWidget {
  final MedicationRoutine medicationRoutine;
  const MedicationRoutineCard({super.key, required this.medicationRoutine});

  @override
  State<MedicationRoutineCard> createState() => _MedicationRoutineCardState();
}

class _MedicationRoutineCardState extends State<MedicationRoutineCard> {
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
    // final ColorScheme colorScheme = Theme.of(context).colorScheme;
    MedicationRoutine medicationRoutine = widget.medicationRoutine;
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (medicationRoutine.symptomsID.isNotEmpty)
                      Wrap(
                        spacing: 10,
                        children: List.generate(
                            medicationRoutine.symptomsID.length, (index) {
                          return Chip(
                            side: const BorderSide(style: BorderStyle.none),
                            avatar: CircleAvatar(
                              backgroundColor: customColors.green,
                            ),
                            label: Text(
                              '#${medicationRoutine.symptomsName[index]}',
                              style: textStyles.bodyMedium,
                            ),
                          );
                        }),
                      ),
                  ],
                ),
                Text(
                  medicationRoutine.title,
                  style: textStyles.bodyLarge,
                ),
                Text(
                  medicationRoutine.diagnosis,
                  style: textStyles.bodyMedium,
                ),
                const SizedBoxh10(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 250,
                      child: Text(
                        "\"${medicationRoutine.comments}\"",
                        style: textStyles.bodyMedium!
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
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
                        // Clinic Name
                        Wrap(
                          spacing: 20,
                          children: [
                            const Icon(
                              Icons.local_hospital_rounded,
                            ),
                            Text(
                              medicationRoutine.clinicName,
                              style: textStyles.bodyMedium,
                            ),
                          ],
                        ),
                        // Appointment Number
                        Wrap(
                          spacing: 20,
                          children: [
                            const Icon(
                              Icons.app_registration_outlined,
                            ),
                            Text(
                              medicationRoutine.appointmentNumber,
                              style: textStyles.bodyMedium,
                            ),
                          ],
                        ),
                        // Medications
                        const SizedBoxh20(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                              medicationRoutine.medications.length, (index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "#${index + 1} ${medicationRoutine.medications[index].name}",
                                  style: textStyles.bodyLarge,
                                ),
                                Text(
                                  "Quantity : ${medicationRoutine.medications[index].quantity}",
                                  style: textStyles.bodyMedium,
                                ),
                                if (medicationRoutine
                                    .medications[index].desc.isNotEmpty)
                                  Text(
                                    medicationRoutine.medications[index].desc,
                                    style: textStyles.bodyMedium,
                                  ),
                                Text(
                                  medicationRoutine.medications[index]
                                      .frequencyString(),
                                  style: textStyles.bodyMedium,
                                ),
                              ],
                            );
                          }),
                        ),
                        // EDIT AND DELETE BUTTONS - MOVE TODO?
                        Row(
                          children: [
                            AppIconButtonSmall(
                                icon: const Icon(Icons.edit_rounded),
                                onPressed: () => Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (context, a, b) =>
                                          MedsEditRoutine(
                                        routineData: medicationRoutine,
                                      ),
                                    ))),
                            AppIconButtonSmall(
                              icon: const Icon(Icons.delete_rounded),
                              onPressed: () => showAppConfirmationDialog(
                                context: context,
                                titleString: 'Confirm Deletion',
                                contentString:
                                    'Are you sure you want to delete this routine?',
                                continueAction: () {
                                  context
                                      .read<MedicationService>()
                                      .deleteMedicationRoutine(
                                          id: medicationRoutine.oid ?? "");
                                },
                              ),
                            ),
                          ],
                        ),
                      ]),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
