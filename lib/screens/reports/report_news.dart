import 'package:flutter/material.dart';
import 'package:wagtrack/models/report_model.dart';
import 'package:wagtrack/screens/reports/news_card.dart';
import 'package:wagtrack/screens/reports/reports.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/utils.dart';

class ReportNews extends StatefulWidget {
  final List<AVSNews> allNews;
  const ReportNews({super.key, required this.allNews});

  @override
  State<ReportNews> createState() => _ReportNewsState();
}

class _ReportNewsState extends State<ReportNews> {
  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // App Bar
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[],
        ),

        // to remove the change of color when scrolling
        forceMaterialTransparency: true,
      ),
      body: BackgroundImageWrapper(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "All News & Events",
                  style: textStyles.headlineMedium,
                ),
                Column(
                  children: List.generate(widget.allNews.length, (index) {
                    return NewsCard(
                        displayTitle: widget.allNews[index].title,
                        displayOrgURL: widget.allNews[index].orgUrl,
                        displayCaption: widget.allNews[index].caption,
                        displayDate:
                            formatDateTime(widget.allNews[index].date).date,
                        displayURL: widget.allNews[index].url);
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
