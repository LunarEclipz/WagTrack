import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

/// This page is called "Records" in the App UI
class MedsOverviewPage extends StatefulWidget {
  final Pet petData;

  const MedsOverviewPage({super.key, required this.petData});

  @override
  State<MedsOverviewPage> createState() => _MedsOverviewPageState();
}

class _MedsOverviewPageState extends State<MedsOverviewPage> {
  late TextEditingController vaccineController = TextEditingController();

  // Form key for vaccine input
  final _vaccineInputFormKey = GlobalKey<FormState>();
  bool showVaccineDateRequired = false;

  late bool isVaccineDateSet = false;
  late DateTime vaccineDateTime;

  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;
    final TextTheme textStyles = Theme.of(context).textTheme;

    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final PetService petService = context.watch<PetService>();

    // DO NOT wrap this in an unconstrained container
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vaccinations
          Text(
            'Vaccination Records',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () {
              DatePicker.showDatePicker(context,
                  showTitleActions: true,
                  minTime: DateTime(1999, 1, 1),
                  maxTime: DateTime.now(), onConfirm: (date) {
                setState(() {
                  vaccineDateTime = date;
                  isVaccineDateSet = true;
                });
              }, onCancel: () {
                setState(() {
                  isVaccineDateSet = false;
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
                      child: isVaccineDateSet == false
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Set Vaccination Date",
                                      style: textStyles.bodyLarge!
                                          .copyWith(color: colorScheme.primary),
                                    ),
                                    Icon(Icons.vaccines_rounded,
                                        size: 20, color: colorScheme.primary),
                                  ],
                                ),
                                if (showVaccineDateRequired)
                                  Text(
                                    "Required*",
                                    style: textStyles.bodyMedium!
                                        .copyWith(color: colorScheme.primary),
                                  ),
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
                                      "Vaccination Date",
                                      style: textStyles.bodyLarge!
                                          .copyWith(color: colorScheme.primary),
                                    ),
                                    Icon(Icons.vaccines_rounded,
                                        size: 20, color: colorScheme.primary),
                                  ],
                                ),
                                Text(formatDateTime(vaccineDateTime).date,
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
          Form(
            key: _vaccineInputFormKey,
            child: AppTextFormField(
              controller: vaccineController,
              hintText: 'Vaccine Name',
              prefixIcon: const Icon(Icons.vaccines_rounded),
              autovalidateMode: AutovalidateMode.disabled,
            ),
          ),

          const SizedBoxh10(),
          InkWell(
            onTap: () async {
              if (!isVaccineDateSet) {
                // naughty naughty
                setState(() {
                  showVaccineDateRequired = true;
                });
              }

              if (_vaccineInputFormKey.currentState!.validate() &&
                  isVaccineDateSet) {
                List<DateTimeStringPair> vaccineData = petData.vaccineRecords;
                vaccineData.add(DateTimeStringPair(
                    dateTime: vaccineDateTime, value: vaccineController.text));
                petService.updateVaccineRecords(
                    petData: petData, vaccineRecords: vaccineData);
                setState(() {
                  petData.weight = vaccineData;
                  vaccineController.text = "";

                  FocusScope.of(context).unfocus();

                  // reset bools
                  showVaccineDateRequired = false;
                  isVaccineDateSet = false;
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
                    ' Add Vaccine',
                    style: textStyles.bodyMedium!
                        .copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBoxh20(),

          // list of vaccines
          if (petData.vaccineRecords.isNotEmpty)
            Column(
              children: List.generate(petData.vaccineRecords.length, (index) {
                return Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.vaccines_rounded,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "${petData.vaccineRecords[index].value.toString()}\n${formatDateTime(petData.vaccineRecords[index].dateTime).date}",
                            style: textStyles.bodyLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
