import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/shared/components/text_components.dart';

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

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                child: petData.imgPath == null
                    ? const CircleAvatar(
                        backgroundColor: Color.fromARGB(255, 41, 41, 41),
                        radius: 80,
                      )
                    : CircleAvatar(
                        backgroundImage: Image.network(
                          petData.imgPath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ).image,
                        radius: 80,
                      ),
              ), // Age, Weight, Post, Fans
            ],
          ),
          const SizedBoxh20(),
          Text(
            'Pet Details',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh20(),
          Text(
            'Weight Log',
            style: textStyles.headlineMedium,
          ),
        ],
      ),
    );
  }
}
