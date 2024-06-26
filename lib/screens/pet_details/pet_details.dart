import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
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
  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;
    final TextTheme textStyles = Theme.of(context).textTheme;
    String petAge = DateTime.now().year - petData.birthDate.year == 0
        ? "${DateTime.now().month - petData.birthDate.month} Months"
        : "${DateTime.now().year - petData.birthDate.year} Years";
    final CustomColors customColors = AppTheme.customColors;

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
          // Temp Weight
          Wrap(
            spacing: 20,
            children: [
              const Icon(
                Icons.monitor_weight_rounded,
              ),
              Text(
                "${petData.weight.toString()} KG",
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

          // TODO :Future Implementation Weight Log
          // const SizedBoxh20(),
          // Text(
          //   'Weight Log',
          //   style: textStyles.headlineMedium,
          // ),
        ],
      ),
    );
  }
}
