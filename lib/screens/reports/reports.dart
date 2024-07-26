import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wagtrack/models/report_model.dart';
import 'package:wagtrack/screens/reports/news_card.dart';
import 'package:wagtrack/screens/reports/report_news.dart';
import 'package:wagtrack/services/news_service.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/sg_geo.dart';
import 'package:wagtrack/shared/themes.dart';
import 'package:wagtrack/shared/utils.dart';

typedef HitValue = ({String title, List<String> symptom, List<Widget> widget});

class Reports extends StatefulWidget {
  const Reports({super.key});

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> {
  late List<AVSNews> allNews;
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllNews();
    setMap();
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
        // const SizedBoxh10(),
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
        final ColorScheme colorScheme = Theme.of(context).colorScheme;

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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Reports in June',
                    ),
                    CircleAvatar(
                      backgroundColor: SeverityColors.red,
                      radius: 5,
                    ),
                    Text("15"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.orange,
                      radius: 5,
                    ),
                    Text("11"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.yellow,
                      radius: 5,
                    ),
                    Text("20"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.green,
                      radius: 5,
                    ),
                    Text("25"),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Column(
                  children:
                      List.generate(tappedLines[0].symptom.length, (index) {
                    return ListTile(
                      leading: const Icon(Icons.sick_rounded),
                      title: Text(tappedLines[0].symptom[index]),
                      subtitle: tappedLines[0].widget[index],
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
    );
  }

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
        Polygon<HitValue> polygon = Polygon(
          points: points,
          color: Colors.blue.withOpacity(0.2),
          borderStrokeWidth: 2,
          borderColor: Colors.black,
          hitValue: (
            title: sgGeo["features"][i]["properties"]["Name"],
            symptom: ["Bad Odour", "Vomitting", "Lethargy"],
            widget: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: SeverityColors.red,
                    radius: 5,
                  ),
                  Text("4"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.orange,
                    radius: 5,
                  ),
                  Text("5"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.yellow,
                    radius: 5,
                  ),
                  Text("7"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.green,
                    radius: 5,
                  ),
                  Text("21"),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: SeverityColors.red,
                    radius: 5,
                  ),
                  Text("9"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.orange,
                    radius: 5,
                  ),
                  Text("1"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.yellow,
                    radius: 5,
                  ),
                  Text("12"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.green,
                    radius: 5,
                  ),
                  Text("1"),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: SeverityColors.red,
                    radius: 5,
                  ),
                  Text("2"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.orange,
                    radius: 5,
                  ),
                  Text("5"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.yellow,
                    radius: 5,
                  ),
                  Text("1"),
                  CircleAvatar(
                    backgroundColor: SeverityColors.green,
                    radius: 5,
                  ),
                  Text("3"),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            ]
          ),
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
          Polygon<HitValue> polygon = Polygon(
            points: points,
            color: Colors.blue.withOpacity(0.2),
            borderStrokeWidth: 2,
            borderColor: Colors.black,
            hitValue: (
              title: sgGeo["features"][i]["properties"]["Name"],
              symptom: ["Bad Odour"],
              widget: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: SeverityColors.red,
                      radius: 5,
                    ),
                    Text("4"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.orange,
                      radius: 5,
                    ),
                    Text("5"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.yellow,
                      radius: 5,
                    ),
                    Text("7"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.green,
                      radius: 5,
                    ),
                    Text("21"),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: SeverityColors.red,
                      radius: 5,
                    ),
                    Text("9"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.orange,
                      radius: 5,
                    ),
                    Text("1"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.yellow,
                      radius: 5,
                    ),
                    Text("12"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.green,
                      radius: 5,
                    ),
                    Text("1"),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      backgroundColor: SeverityColors.red,
                      radius: 5,
                    ),
                    Text("2"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.orange,
                      radius: 5,
                    ),
                    Text("5"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.yellow,
                      radius: 5,
                    ),
                    Text("1"),
                    CircleAvatar(
                      backgroundColor: SeverityColors.green,
                      radius: 5,
                    ),
                    Text("3"),
                    SizedBox(
                      width: 5,
                    ),
                  ],
                ),
              ]
            ),
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
