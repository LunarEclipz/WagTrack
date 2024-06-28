import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

class MedsSessionsPage extends StatefulWidget {
  final Pet petData;

  const MedsSessionsPage({super.key, required this.petData});

  @override
  State<MedsSessionsPage> createState() => _MedsSessionsPageState();
}

class _MedsSessionsPageState extends State<MedsSessionsPage> {
  late TextEditingController apptController = TextEditingController();

  late bool apptDate = false;
  late DateTime apptDateTime;
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    List<DateTimeStringPair> sessionRecords = widget.petData.sessionRecords;
    Pet petData = widget.petData;

    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final PetService petService = context.watch<PetService>();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Appointments
          Text(
            'Appointment Records',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () {
              DatePicker.showDateTimePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(2024, 1, 1),
                  maxTime: DateTime(2040, 1, 1), onConfirm: (date) {
                setState(() {
                  apptDateTime = date;
                  apptDate = true;
                });
              }, onCancel: () {
                setState(() {
                  apptDate = false;
                });
              }, currentTime: DateTime.now(), locale: LocaleType.en);
            },
            child: Column(
              children: [
                Card(
                  color: Colors.white,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Padding(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      child: apptDate == false
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Set Appointment Date",
                                  style: textStyles.bodyLarge!
                                      .copyWith(color: colorScheme.primary),
                                ),
                                Icon(Icons.calendar_month_rounded,
                                    size: 20, color: colorScheme.primary),
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
                                      "Appointment Date",
                                      style: textStyles.bodyLarge!
                                          .copyWith(color: colorScheme.primary),
                                    ),
                                    Icon(Icons.calendar_month_rounded,
                                        size: 20, color: colorScheme.primary),
                                  ],
                                ),
                                Text(
                                    "${formatDateTime(apptDateTime).date}   (${formatDateTime(apptDateTime).time})",
                                    style: textStyles.labelLarge),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBoxh10(),
          AppTextFormField(
            controller: apptController,
            hintText: 'Appointment Name',
            prefixIcon: const Icon(Icons.calendar_month_rounded),
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () async {
              if (apptController.text != "" && apptDate) {
                List<DateTimeStringPair> apptData = petData.sessionRecords;
                apptData.add(DateTimeStringPair(
                    dateTime: apptDateTime, value: apptController.text));
                petService.updateSessionRecords(
                    petData: petData, sessionRecords: apptData);
                setState(() {
                  petData.weight = apptData;
                  apptController.text = "";
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
                    ' Add appt',
                    style: textStyles.bodyMedium!
                        .copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBoxh20(),
          if (petData.sessionRecords.isNotEmpty)
            Column(
              children: List.generate(
                sessionRecords.length,
                (index) {
                  return Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_month_rounded),
                                  Text(
                                    "  ${sessionRecords[index].value}",
                                    style: textStyles.bodyLarge,
                                  ),
                                ],
                              ),
                              Text(
                                "${formatDateTime(sessionRecords[index].dateTime).date}\n${formatDateTime(sessionRecords[index].dateTime).time}",
                                style: textStyles.bodyMedium,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
