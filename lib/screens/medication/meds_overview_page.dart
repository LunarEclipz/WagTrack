import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class MedsOverviewPage extends StatefulWidget {
  final Pet petData;

  const MedsOverviewPage({super.key, required this.petData});

  @override
  State<MedsOverviewPage> createState() => _MedsOverviewPageState();
}

class _MedsOverviewPageState extends State<MedsOverviewPage> {
  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;
    final TextTheme textStyles = Theme.of(context).textTheme;

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
          const SizedBoxh20(),
          Wrap(
            spacing: 20,
            children: [
              const Icon(
                Icons.vaccines_rounded,
              ),
              Text(
                "Beer",
                style: textStyles.bodyLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
