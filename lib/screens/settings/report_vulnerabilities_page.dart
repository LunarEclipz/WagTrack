import 'package:flutter/material.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class ReportVulnerabilities extends StatefulWidget {
  const ReportVulnerabilities({super.key});

  @override
  State<ReportVulnerabilities> createState() => _ReportVulnerabilitiesState();
}

class _ReportVulnerabilitiesState extends State<ReportVulnerabilities> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Report Vulnerabilities',
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
              'Contact Us',
              style: textStyles.headlineMedium,
            ),
            const SizedBoxh10(),
            const Text('Email: wagtracksg@gmail.com'),
          ]),
        ));
  }
}
