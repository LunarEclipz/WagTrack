import 'package:flutter/material.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class DataPolicyPage extends StatefulWidget {
  const DataPolicyPage({super.key});

  @override
  State<DataPolicyPage> createState() => _DataPolicyPageState();
}

class _DataPolicyPageState extends State<DataPolicyPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Data Policy',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: colorScheme.primary,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: DefaultTextStyle.merge(
          style: textStyles.bodyLarge,
          child: AppScrollablePage(children: [
            // SECTION: PERSONAL INFORMATION
            Text(
              'Section',
              style: textStyles.headlineMedium,
            ),
            const SizedBoxh10(),
            const Text('text'),
          ]),
        ));
  }
}
