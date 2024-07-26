import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/screens/symptoms/symptoms.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class PastSymptoms extends StatefulWidget {
  const PastSymptoms({
    super.key,
  });

  @override
  State<PastSymptoms> createState() => _PastSymptomsState();
}

class _PastSymptomsState extends State<PastSymptoms> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final SymptomService symptomService = context.watch<SymptomService>();
    var pastSymptoms = symptomService.pastSymptoms;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // App Bar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Archives (Symptoms)",
              style: textStyles.bodyLarge,
            ),
          ],
        ),

        // to remove the change of color when scrolling
        forceMaterialTransparency: true,
      ),
      body: BackgroundImageWrapper(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
