import 'package:flutter/material.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class HelpReport extends StatefulWidget {
  const HelpReport({super.key});

  @override
  State<HelpReport> createState() => _HelpReportState();
}

class _HelpReportState extends State<HelpReport> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // App Bar
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Help (Reports)",
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
                "Pinch to Zoom in or out on the map."
                "\n\nClick on the area you are interested in."
                "\n\nYou can now see the number of reports in that area for the given month!",
                style: textStyles.bodyMedium,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
