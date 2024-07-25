import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/components/button_components.dart';
import 'package:wagtrack/shared/components/dialogs.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

class PetDetails extends StatefulWidget {
  final Pet petData;
  const PetDetails({super.key, required this.petData});

  @override
  State<PetDetails> createState() => _PetDetailsState();
}

class _PetDetailsState extends State<PetDetails> {
  late TextEditingController weightController = TextEditingController();

  /// Deletes pet.
  void _deletePet({required String id}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final petService = Provider.of<PetService>(context, listen: false);
      petService.deletePet(id: id);
    });
  }

  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;
    final TextTheme textStyles = Theme.of(context).textTheme;
    String petAge = DateTime.now().year - petData.birthDate.year == 0
        ? "${DateTime.now().month - petData.birthDate.month} Months"
        : "${DateTime.now().year - petData.birthDate.year} Years";
    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final PetService petService = context.watch<PetService>();

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                child: petData.imgPath == null
                    ? const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        radius: 100,
                      )
                    : CircleAvatar(
                        backgroundImage: Image.network(
                          petData.imgPath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ).image,
                        radius: 100,
                      ),
              ),
              // Age, Weight, Post, Fans
              Column(
                children: [
                  // Age
                  Chip(
                    backgroundColor: customColors.pastelOrange,
                    side: const BorderSide(style: BorderStyle.none),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          petAge,
                          style: textStyles.bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          "Age",
                          style: textStyles.bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBoxh10(),
                  // Fans
                  Chip(
                    backgroundColor: customColors.pastelBlue,
                    side: const BorderSide(style: BorderStyle.none),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          petData.fans.toString(),
                          style: textStyles.bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          "Fans",
                          style: textStyles.bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBoxh10(),

                  // Posts
                  Chip(
                    backgroundColor: customColors.hint,
                    side: const BorderSide(style: BorderStyle.none),
                    label: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(
                          width: 80,
                        ),
                        Text(
                          petData.posts.toString(),
                          style: textStyles.bodyLarge!
                              .copyWith(color: Colors.white),
                        ),
                        Text(
                          "Posts",
                          style: textStyles.bodyMedium!
                              .copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBoxh20(),
          Text(
            'Pet Details',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh20(),
          // ID
          Wrap(
            spacing: 20,
            children: [
              const Icon(Icons.card_membership_rounded),
              Text(
                petData.idNumber,
                style: textStyles.bodyLarge,
              ),
            ],
          ),
          // Birthday
          Wrap(
            spacing: 20,
            children: [
              const Icon(
                Icons.cake_rounded,
              ),
              Text(
                formatDateTime(petData.birthDate).date,
                style: textStyles.bodyLarge,
              ),
            ],
          ),

          const SizedBoxh20(),
          Text(
            'Ownership',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          // Posts
          // TODO: Zyon to redo caretake list, include MAIN, form as well
          Wrap(
            spacing: 20,
            children: List.generate(petData.caretakers.length, (index) {
              return Chip(
                backgroundColor: customColors.pastelPurple,
                side: const BorderSide(style: BorderStyle.none),
                label: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      petData.caretakers[index].username,
                      style:
                          textStyles.bodyLarge!.copyWith(color: Colors.white),
                    ),
                    Text(
                      petData.caretakers[index].role,
                      style:
                          textStyles.bodyMedium!.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBoxh20(),
          Text(
            'Weight Log',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          AppTextFormField(
            controller: weightController,
            hintText: 'Weight',
            prefixIcon: const Icon(Icons.scale_rounded),
          ),
          const SizedBoxh10(),
          InkWell(
            onTap: () async {
              if (weightController.text != "") {
                List<DateTimeStringPair> newWeight = petData.weight;
                newWeight.add(DateTimeStringPair(
                    dateTime: DateTime.now(), value: weightController.text));
                petService.updateWeightLog(
                    petData: petData, weightLog: newWeight);
                setState(() {
                  petData.weight = newWeight;
                  weightController.text = "";
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
                    ' Add Weight',
                    style: textStyles.bodyMedium!
                        .copyWith(color: colorScheme.primary),
                  ),
                ],
              ),
            ),
          ),
          const SizedBoxh10(),

          Column(
            children: List.generate(petData.weight.length, (index) {
              return Row(
                children: [
                  const Icon(
                    Icons.monitor_weight_rounded,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      "${petData.weight[index].value.toString()} KG",
                      style: textStyles.bodyLarge,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(children: [
                      Text(
                        "(${formatDateTime(petData.weight[index].dateTime).date})",
                        style: textStyles.bodyLarge,
                      ),
                      const SizedBox(width: 80),
                    ]),
                  ),
                ],
              );
            }),
          ),

          const SizedBoxh20(),

          // DELETE PET BUTTON
          Center(
            child: AppButtonLarge(
              onTap: () => showAppConfirmationDialog(
                context: context,
                titleString: 'Confirm Deletion',
                contentString:
                    'Are you sure you want to delete this pet? \nThis action is irreversible!',
                continueAction: () {
                  _deletePet(id: petData.petID ?? "");
                  Navigator.pop(context);
                },
              ),
              width: 200,
              height: 40,
              text: 'Delete Pet',
            ),
          ),
        ],
      ),
    );
  }
}
