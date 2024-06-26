import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/authorisation/login_tab.dart';
import 'package:wagtrack/screens/authorisation/register_tab.dart';

class MedicationFrame extends StatefulWidget {
  final Pet petData;

  const MedicationFrame({super.key, required this.petData});

  @override
  State<MedicationFrame> createState() => _MedicationFrameState();
}

class _MedicationFrameState extends State<MedicationFrame>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          unselectedLabelColor: Colors.grey,
          labelColor: colorScheme.tertiary,
          indicatorColor: colorScheme.tertiary,
          tabs: const [
            Tab(
                child: Text(
              'Overview',
              style: TextStyle(fontSize: 20),
            )),
            Tab(
                child: Text(
              'Sessions',
              style: TextStyle(fontSize: 20),
            )),
            Tab(
                child: Text(
              'Routine',
              style: TextStyle(fontSize: 20),
            ))
          ],
        ),
      ],
    );
  }
}
