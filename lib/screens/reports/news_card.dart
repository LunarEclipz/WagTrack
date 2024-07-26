import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class NewsCard extends StatefulWidget {
  final String displayTitle;
  final String displayOrgURL;

  final String displayCaption;
  final String displayDate;
  final String displayURL;
  const NewsCard({
    super.key,
    required this.displayTitle,
    required this.displayOrgURL,
    required this.displayCaption,
    required this.displayDate,
    required this.displayURL,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isExpanded = false;

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: _toggleExpansion,
      child: Card(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    widget.displayOrgURL,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(child: Text('Error loading image'));
                    },
                  ),
                  Text(
                    widget.displayDate,
                    style: textStyles.bodySmall!
                        .copyWith(fontStyle: FontStyle.italic),
                  ),
                ],
              ),
              Row(
                children: [
                  Flexible(
                    flex: 20,
                    child: Text(
                      widget.displayTitle,
                      style: textStyles.bodyLarge,
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: _isExpanded
                        ? const Icon(Icons.expand_less)
                        : const Icon(Icons.expand_more),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const SizedBoxh10(),
                    Text(widget.displayCaption, style: textStyles.bodyMedium!),
                    const SizedBoxh10(),
                    InkWell(
                      onTap: () async {
                        final Uri url = Uri.parse(widget.displayURL);
                        if (!await launchUrl(url)) {
                          throw Exception('Could not launch $url');
                        }
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.link,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text("Read more ...",
                              style: textStyles.bodySmall!
                                  .copyWith(color: colorScheme.primary)),
                        ],
                      ),
                    ),
                  ],
                ),
                crossFadeState: _isExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
