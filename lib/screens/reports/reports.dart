import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:wagtrack/models/report_model.dart';
import 'package:wagtrack/models/symptom_enums.dart';
import 'package:wagtrack/models/symptom_model.dart';
import 'package:wagtrack/screens/reports/news_card.dart';
import 'package:wagtrack/screens/reports/report_news.dart';
import 'package:wagtrack/screens/reports/report_tile.dart';
import 'package:wagtrack/services/news_service.dart';
import 'package:wagtrack/services/symptom_service.dart';
import 'package:wagtrack/shared/components/input_components.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/dropdown_options.dart';
import 'package:wagtrack/shared/sg_geo.dart';
import 'package:wagtrack/shared/utils.dart';

typedef HitValue = ({
  String title,
  // List<String> symptom,
  // List<Widget> widget,
});

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  List<Symptom> symptomsInMonth = [];
  bool loaded = false;

  late List<AVSNews> allNews;
  late String selectedMonth = (monthsList[DateTime.now().month - 1]);

  late String displayTitle = "";
  late String displayCaption = "";
  late String displayDate = "";
  late String displayURL = "";
  late String displayOrgURL = "";

  final LayerHitNotifier<HitValue> _hitNotifier = ValueNotifier(null);
  late PolygonLayer sgLayers;
  LatLngBounds bounds = LatLngBounds(
      const LatLng(1.4571497742692037, 103.63295554087519),
      const LatLng(1.262197454651967, 104.01267050889712));
  List<Polygon<HitValue>>? _polygons;

  /// which polygon has been pressed
  Polygon<HitValue>? _pressedPolygon;

  // set colors
  final Color borderColor = Colors.white;
  final Color regionColor = const Color.fromARGB(255, 206, 210, 214);
  final Color regionTappedColor = const Color.fromARGB(255, 164, 177, 185);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllNews();
    setMap();
  }

  getSymptomsByMonth() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchAndSetSymptoms();
    });
  }

  Future<void> _fetchAndSetSymptoms() async {
    final SymptomService symptomService =
        Provider.of<SymptomService>(context, listen: false);

    List<Symptom> symptoms = await symptomService.getSymptomsByMonth(
      month: monthsList.indexOf(selectedMonth) + 1,
      year: 2024,
    );

    if (mounted) {
      // mounted: whether this state object is in a tree.
      setState(() {
        symptomsInMonth = symptoms;
      });
    }
  }

  void getAllNews() async {
    List<AVSNews> news = await NewsService().getAllNews();
    setState(() {
      allNews = news;
      displayCaption = news.first.caption;
      displayTitle = news.first.title;
      displayDate = formatDateTime(news.first.date).date;
      displayURL = news.first.url;
      displayOrgURL = news.first.orgUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textStyles = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (!loaded) {
      getSymptomsByMonth();
      setState(() {
        loaded = true;
      });
    }
    return
        // const MapControllerPage();
        AppScrollablePage(
      children: [
        Text(
          "Reports",
          style: textStyles.headlineMedium,
        ),
        const SizedBoxh10(),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 300,
          child: Card(
            color: Colors.white,
            child: FlutterMap(
              options: MapOptions(
                  cameraConstraint:
                      CameraConstraint.containCenter(bounds: bounds),
                  backgroundColor: Colors.transparent,
                  initialCenter:
                      const LatLng(1.3669343734539168, 103.83339687268919),
                  initialZoom: 10,
                  maxZoom: 14,
                  minZoom: 10),
              children: [
                TapRegion(
                  behavior: HitTestBehavior.deferToChild,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        // for setting hit animation

                        // set which polygon has been pressed
                        final hitVal = _hitNotifier.value!.hitValues.first;

                        final hitPolygons = _polygons!.where((polygon) =>
                            polygon.hitValue!.title == hitVal.title);
                        if (hitPolygons.isNotEmpty) {
                          _pressedPolygon = hitPolygons.first;
                        }

                        setMap();
                      });

                      _openTouchedGonsModal(
                        'Tapped',
                        _hitNotifier.value!.hitValues,
                        _hitNotifier.value!.coordinate,
                      );
                    },
                    child: PolygonLayer(
                      hitNotifier: _hitNotifier,
                      simplificationTolerance: 0,
                      polygons: _polygons!,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        AppDropdown(
          onChanged: (String? value) {
            setState(() {
              selectedMonth = value!;
            });
            getSymptomsByMonth();
          },
          optionsList: monthsList,
          selectedText: selectedMonth,
          enabled: true,
        ),
        const SizedBoxh10(),
        NewsCard(
            displayOrgURL: displayOrgURL,
            displayTitle: displayTitle,
            displayCaption: displayCaption,
            displayDate: displayDate,
            displayURL: displayURL),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
                transitionDuration: const Duration(
                    milliseconds: 300), // Adjust the duration here
                pageBuilder: (context, a, b) => ReportNews(
                  allNews: allNews,
                ),
              ),
            );
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text("see all news & events ...",
                  style: textStyles.bodySmall!
                      .copyWith(color: colorScheme.primary)),
            ),
          ),
        ),
      ],
    );
  }

  void _openTouchedGonsModal(
    String eventType,
    List<HitValue> tappedLines,
    LatLng coords,
  ) {
    showModalBottomSheet<void>(
      elevation: 20,
      isScrollControlled: true,
      showDragHandle: true,
      enableDrag: true,
      backgroundColor: Colors.white,
      barrierColor: Colors.black.withOpacity(0.1),
      context: context,
      builder: (context) {
        List<ReportTileObject> symptomReports = [];

        List<Symptom> symptomsInLocation = symptomsInMonth
            .where((obj) =>
                obj.location.toLowerCase() ==
                tappedLines[0].title.toLowerCase())
            .toList();
        Set<String> uniqueSymptomCategories =
            symptomsInLocation.map((symptom) => symptom.symptom).toSet();
        for (int i = 0; i < uniqueSymptomCategories.length; i++) {
          List<Symptom> symptomsMatch = symptomsInLocation
              .where(
                  (obj) => obj.symptom == uniqueSymptomCategories.toList()[i])
              .toList();
          ReportTileObject tileObject = ReportTileObject(
              green: 0,
              red: 0,
              orange: 0,
              yellow: 0,
              symptom: symptomsMatch[0].symptom);

          for (int j = 0; j < symptomsMatch.length; j++) {
            switch (symptomsMatch[j].level) {
              case SymptomLevel.red:
                tileObject.red += 1;
              case SymptomLevel.orange:
                tileObject.orange += 1;
              case SymptomLevel.yellow:
                tileObject.yellow += 1;
              case SymptomLevel.green:
                tileObject.green += 1;
              default:
            }
          }
          symptomReports.add(tileObject);
        }

        return FractionallySizedBox(
          heightFactor: 0.5,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tappedLines[0].title,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                ReportTile(
                    month: selectedMonth,
                    red: symptomsInLocation
                        .where((obj) => obj.level == SymptomLevel.red)
                        .length
                        .toString(),
                    orange: symptomsInLocation
                        .where((obj) => obj.level == SymptomLevel.orange)
                        .length
                        .toString(),
                    yellow: symptomsInLocation
                        .where((obj) => obj.level == SymptomLevel.yellow)
                        .length
                        .toString(),
                    green: symptomsInLocation
                        .where((obj) => obj.level == SymptomLevel.green)
                        .length
                        .toString()),
                const SizedBox(height: 8),
                Column(
                  children: List.generate(symptomReports.length, (index) {
                    return ListTile(
                      leading: const Icon(Icons.sick_rounded),
                      title: Text(symptomReports[index].symptom),
                      subtitle: ReportTile(
                        month: '',
                        red: symptomReports[index].red.toString(),
                        orange: symptomReports[index].orange.toString(),
                        yellow: symptomReports[index].yellow.toString(),
                        green: symptomReports[index].green.toString(),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                // Align(
                //   alignment: Alignment.bottomCenter,
                //   child: SizedBox(
                //     width: double.infinity,
                //     child: OutlinedButton(
                //       onPressed: () => Navigator.pop(context),
                //       child: const Text('Close'),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    ).then((_) {
      /// reset the pressed region
      _pressedPolygon = null;
      setMap();
    });
  }

  /// Sets the map
  setMap() {
    // Set Map
    List<Polygon<HitValue>> polygonList = [];
    for (int i = 0; i < sgGeo["features"].length; i++) {
      var objectIType = sgGeo["features"][i]["geometry"]["type"];
      // If type is polygon
      if (objectIType == "Polygon") {
        var objectICoords = sgGeo["features"][i]["geometry"]["coordinates"];
        List<LatLng> points = [];
        for (int j = 0; j < objectICoords[0].length; j++) {
          LatLng coord = LatLng(objectICoords[0][j][1], objectICoords[0][j][0]);
          points.add(coord);
        }
        final ({String title}) hitValue =
            (title: sgGeo["features"][i]["properties"]["Name"],);
        Color fillColor = regionColor;

        // check if it's pressed:
        if (_pressedPolygon != null && hitValue == _pressedPolygon!.hitValue) {
          fillColor = regionTappedColor;
        }

        Polygon<HitValue> polygon = Polygon(
          points: points,
          color: fillColor,
          borderStrokeWidth: 1,
          borderColor: borderColor,
          hitValue: hitValue,
        );

        polygonList.add(polygon);
      }

      // If type is MultiPolygon
      if (objectIType == "MultiPolygon") {
        var objectICoords = sgGeo["features"][i]["geometry"]["coordinates"];
        List<LatLng> points = [];
        for (int z = 0; z < objectICoords[0].length; z++) {
          for (int j = 0; j < objectICoords[0][z].length; j++) {
            LatLng coord =
                LatLng(objectICoords[0][z][j][1], objectICoords[0][z][j][0]);
            points.add(coord);
          }
          final ({String title}) hitValue =
              (title: sgGeo["features"][i]["properties"]["Name"],);
          Color fillColor = regionColor;

          // check if it's pressed:
          if (_pressedPolygon != null &&
              hitValue == _pressedPolygon!.hitValue) {
            fillColor = regionTappedColor;
          }

          Polygon<HitValue> polygon = Polygon(
            points: points,
            color: fillColor,
            borderStrokeWidth: 1,
            borderColor: borderColor,
            hitValue: hitValue,
          );

          polygonList.add(polygon);
        }
      }
    }
    setState(() {
      _polygons = polygonList;
    });
  }
}
