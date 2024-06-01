import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/home/add_pet.dart';
import 'package:wagtrack/screens/settings/app_settings.dart';
import 'package:wagtrack/shared/components/call_to_action.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/themes.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
  });

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? name;

  /// Loads username - MOVE TODO:
  void getName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString('user_name');
  }

  @override
  void initState() {
    super.initState();
    getName();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;

    getName();
    return AppScrollablePage(children: <Widget>[
      Text(
        "Welcome Back ${name ?? ''}",
        style: textStyles.headlineMedium,
      ),
      const SizedBoxh20(),
      CallToActionButton(
        icon: Icons.book_rounded,
        title: "Pet Care Resources",
        text: "Pet Care Resources at Your Fingertips! Click to learn more ...",
        color: AppTheme.customColors.pastelBlue,
        onTap: () {},
      ),
      const SizedBoxh20(),
      Text(
        "My Pets",
        style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(
        "You have not added a personal pet",
        style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      ),
      const SizedBoxh20(),
      Text(
        "Community Pets",
        style: textStyles.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      Text(
        "You have not added a community pet",
        style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      ),
    ]);
  }
}

// Cards to display both Community and Personal pets in home

class PetCard extends StatefulWidget {
  final Pet petData;
  const PetCard({super.key, required this.petData});

  @override
  State<PetCard> createState() => _PetCardState();
}

class _PetCardState extends State<PetCard> {
  @override
  Widget build(BuildContext context) {
    Pet pet = widget.petData;

    return const Card(
      child: Row(
        children: [],
      ),
    );
  }
}
