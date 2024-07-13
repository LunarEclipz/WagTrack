import 'package:flutter/material.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class FaqsPage extends StatefulWidget {
  const FaqsPage({super.key});

  @override
  State<FaqsPage> createState() => _FaqsPageState();
}

class _FaqsPageState extends State<FaqsPage> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // TODO: "Question", "Section", "Answer" widgets

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Frequently Asked Questions',
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
            const Text('test'),
          ]),
        ));
  }
}
