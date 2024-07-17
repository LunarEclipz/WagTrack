import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/services/pet_service.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/themes.dart';

class PetPostsPage extends StatefulWidget {
  final Pet petData;

  const PetPostsPage({super.key, required this.petData});

  @override
  State<PetPostsPage> createState() => _PetPostsPageState();
}

class _PetPostsPageState extends State<PetPostsPage> {
  late String filterSelected = "All";

  @override
  Widget build(BuildContext context) {
    Pet petData = widget.petData;

    final CustomColors customColors = AppTheme.customColors;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textStyles = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(postCategory.length + 1, (index) {
              return index == 0
                  ? InkWell(
                      onTap: () {
                        setState(() {
                          filterSelected = "All";
                        });
                      },
                      child: Text(
                        "All",
                        style: filterSelected == "All"
                            ? textStyles.bodyLarge
                            : textStyles.bodyMedium,
                      ))
                  : InkWell(
                      onTap: () {
                        setState(() {
                          filterSelected = postCategory[index - 1];
                        });
                      },
                      child: Text(
                        postCategory[index - 1],
                        style: filterSelected == postCategory[index - 1]
                            ? textStyles.bodyLarge
                            : textStyles.bodyMedium,
                      ));
            }),
          )
        ],
      ),
    );
  }
}
