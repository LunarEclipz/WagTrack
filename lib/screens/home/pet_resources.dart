import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wagtrack/models/pet_resources.dart';
import 'package:wagtrack/shared/background_img.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/pet_care_resouces.dart';

class PetCareResourcesPage extends StatefulWidget {
  const PetCareResourcesPage({super.key});

  @override
  State<PetCareResourcesPage> createState() => _PetCareResourcesPageState();
}

class _PetCareResourcesPageState extends State<PetCareResourcesPage> {
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
                Image.network(
                  'https://www.nparks.gov.sg/-/media/avs/images/homepage/logo.jpg?h=708&w=1261&la=en',
                  height: 100,
                ),
                const SizedBoxh10(),
                Text(
                  "Pet Care Resources",
                  style: textStyles.headlineMedium,
                ),
                Column(
                  children:
                      List.generate(petResources.categories.length, (index) {
                    return PetCareCard(
                        category: petResources.categories[index]);
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

class PetCareCard extends StatefulWidget {
  final PetResourcesCategory category;
  const PetCareCard({super.key, required this.category});

  @override
  State<PetCareCard> createState() => _PetCareCardState();
}

class _PetCareCardState extends State<PetCareCard> {
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
      onTap: () {
        _toggleExpansion();
      },
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 90,
                      child: Text(
                        widget.category.category,
                        style: textStyles.bodyLarge,
                      ),
                    ),
                    _isExpanded
                        ? const Icon(Icons.expand_less)
                        : const Icon(Icons.expand_more)
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBoxh10(),
                      Wrap(
                        runSpacing: 10,
                        spacing: 10,
                        children: List.generate(widget.category.items.length,
                            (index) {
                          return InkWell(
                            onTap: () async {
                              final Uri url = Uri.parse(
                                  widget.category.items[index].itemURL);
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
                                //       CircleAvatar(
                                //           radius: 15,
                                //           backgroundColor: Colors.blueGrey,
                                //           child: Text(
                                //             (index + 1).toString(),
                                //             style: textStyles.bodyMedium!
                                //                 .copyWith(color: Colors.white),
                                //           )),
                                const SizedBox(
                                  width: 10,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width - 120,
                                  child: Text(
                                    widget.category.items[index].itemTitle,
                                    style: textStyles.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )
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
      ),
    );
  }
}
