import 'package:flutter/cupertino.dart';
import 'package:wagtrack/models/pet_model.dart';

class PetPostsPage extends StatefulWidget {
  final Pet petData;

  const PetPostsPage({super.key, required this.petData});

  @override
  State<PetPostsPage> createState() => _PetPostsPageState();
}

class _PetPostsPageState extends State<PetPostsPage> {
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        height: 300,
        child: Center(
            child: Text(
          "WIP for Milestone 3",
          style: TextStyle(fontSize: 30),
        )));
  }
}
