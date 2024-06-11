import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class SymptomsPage extends StatefulWidget {
  const SymptomsPage({super.key});

  @override
  State<SymptomsPage> createState() => _SymptomsPageState();
}

class _SymptomsPageState extends State<SymptomsPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Current Symptoms',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
          const SymptomsCard(),
          const SizedBoxh20(),
          const Divider(),
          const SizedBoxh20(),
          Text(
            'Past Symptoms',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh10(),
        ]),
      ),
    );
  }
}

class SymptomsCard extends StatefulWidget {
  const SymptomsCard({super.key});

  @override
  State<SymptomsCard> createState() => _SymptomsCardState();
}

class _SymptomsCardState extends State<SymptomsCard> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
        onTap: () {},
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
                            "9",
                            style: textStyles.bodyLarge!
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "Lethargy",
                      style: textStyles.bodyLarge,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "13/8/24 to Now",
                          style: textStyles.bodyMedium,
                        ),
                        const Icon(Icons.expand_more_rounded)
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
