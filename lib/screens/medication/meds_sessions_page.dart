import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/utils.dart';

class MedsSessionsPage extends StatefulWidget {
  final Pet petData;

  const MedsSessionsPage({super.key, required this.petData});

  @override
  State<MedsSessionsPage> createState() => _MedsSessionsPageState();
}

class _MedsSessionsPageState extends State<MedsSessionsPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    List<DateTimeStringPair> sessionRecords = widget.petData.sessionRecords;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vaccinations
          Text(
            'Appointment Records',
            style: textStyles.headlineMedium,
          ),
          const SizedBoxh20(),
          Column(
            children: List.generate(
              sessionRecords.length,
              (index) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              sessionRecords[index].value,
                              style: textStyles.bodyLarge,
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
