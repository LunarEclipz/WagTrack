import 'package:flutter/material.dart';
import 'package:wagtrack/models/pet_model.dart';
import 'package:wagtrack/screens/medication/meds_overview_page.dart';
import 'package:wagtrack/screens/medication/meds_routine/meds_routine_page.dart';
import 'package:wagtrack/screens/medication/meds_sessions_page.dart';
import 'package:wagtrack/shared/components/text_components.dart';

class MedicationFrame extends StatefulWidget {
  final Pet petData;

  const MedicationFrame({super.key, required this.petData});

  @override
  State<MedicationFrame> createState() => _MedicationFrameState();
}

class _MedicationFrameState extends State<MedicationFrame>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTab = 0;

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
    final screenWidth = MediaQuery.of(context).size.width;
    Pet petData = widget.petData;

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
              'Routine',
              style: TextStyle(fontSize: 20),
            )),
            Tab(
                child: Text(
              'Sessions',
              style: TextStyle(fontSize: 20),
            )),
            Tab(
                child: Text(
              'Records',
              // used to be overview
              style: TextStyle(fontSize: 20),
            ))
          ],
          onTap: (index) {
            setState(() {
              _selectedTab = index;
            });
          },
        ),
        const SizedBoxh10(),
        Container(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (_) {
              switch (_selectedTab) {
                case 0:
                  return MedsRoutinePage(
                    petData: petData,
                  );
                case 1:
                  return MedsSessionsPage(
                    petData: petData,
                  );
                case 2:
                  return MedsOverviewPage(
                    petData: petData,
                  );
                default:
                  return Container();
              }
            },
          ),
        ),
      ],
    );
  }
}

// class _MedicationFrameState extends State<MedicationFrame>
//     with TickerProviderStateMixin {
//   late final TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final TextTheme textStyles = Theme.of(context).textTheme;
//     final ColorScheme colorScheme = Theme.of(context).colorScheme;
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;
//     Pet petData = widget.petData;

//     return Column(
//       children: [
//         TabBar(
//           controller: _tabController,
//           unselectedLabelColor: Colors.grey,
//           labelColor: colorScheme.tertiary,
//           indicatorColor: colorScheme.tertiary,
//           tabs: const [
//             Tab(
//                 child: Text(
//               'Overview',
//               style: TextStyle(fontSize: 20),
//             )),
//             Tab(
//                 child: Text(
//               'Sessions',
//               style: TextStyle(fontSize: 20),
//             )),
//             Tab(
//                 child: Text(
//               'Routine',
//               style: TextStyle(fontSize: 20),
//             ))
//           ],
//         ),
//         const SizedBoxh10(),
//         Container(
//           constraints: BoxConstraints(maxHeight: screenHeight * 20),
//           // height: screenHeight,
//           // width: screenWidth,
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: MedsOverviewPage(
//                   petData: petData,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: MedsSessionsPage(
//                   petData: petData,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: MedsRoutinePage(
//                   petData: petData,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
