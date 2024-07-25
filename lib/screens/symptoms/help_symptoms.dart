import 'package:flutter/material.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class HelpSymptoms extends StatefulWidget {
  const HelpSymptoms({super.key});

  @override
  State<HelpSymptoms> createState() => _HelpSymptomsState();
}

class _HelpSymptomsState extends State<HelpSymptoms> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    const Color colorRed = SeverityColors.red;
    const Color colorOrange = SeverityColors.orange;
    const Color colorYellow = SeverityColors.yellow;
    const Color colorGreen = SeverityColors.green;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // App Bar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Help (Symptoms)",
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
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "How it works ?",
                style: textStyles.headlineMedium,
              ),
              const SizedBoxh10(),
              Text(
                "Keep track of your pets symptoms with this Symptom Tracker."
                "\n\nTag each symptom with one or more Medical Routines, to ensure it is constantly being treated for."
                "\n\nYou will be notified if any symptoms logged requires immediate veterinary attention.",
                style: textStyles.bodyMedium,
              ),
              const SizedBoxh20(),
              Text(
                "Symptoms Triage",
                style: textStyles.headlineMedium,
              ),
              const SizedBoxh10(),
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  side: BorderSide(
                    color: colorRed,
                    width: 2.0,
                  ),
                ),
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: colorRed,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "True Emergency",
                              style: textStyles.headlineSmall!.copyWith(
                                  color: colorRed, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                            "Bring to a vet immediately. Target waiting time 0 min.",
                            style: textStyles.headlineSmall!),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBoxh10(),
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  side: BorderSide(
                    color: colorOrange,
                    width: 2.0,
                  ),
                ),
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning, color: colorOrange),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Urgent",
                              style: textStyles.headlineSmall!.copyWith(
                                  color: colorOrange,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                            "Bring to a vet immediately.  Target waiting time 15 min.",
                            style: textStyles.headlineSmall!),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBoxh10(),
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  side: BorderSide(
                    color: colorYellow,
                    width: 2.0,
                  ),
                ),
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: colorYellow,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Semi-Urgent",
                              style: textStyles.headlineSmall!.copyWith(
                                  color: colorYellow,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text(
                            "Bring to a vet immediately. Target waiting time 30-60 min.",
                            style: textStyles.headlineSmall!),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBoxh10(),
              Card(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  side: BorderSide(
                    color: colorGreen,
                    width: 2.0,
                  ),
                ),
                color: Colors.white,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: colorGreen,
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Text(
                              "Standard",
                              style: textStyles.headlineSmall!.copyWith(
                                  color: colorGreen,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Text("Recommended to be seen by Primary Care Vet.",
                            style: textStyles.headlineSmall!),
                      ],
                    ),
                  ),
                ),
              )
            ]),
          ),
        ),
      ),
    );
  }
}
