import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wagtrack/models/report_model.dart';
import 'package:wagtrack/screens/reports/report_news.dart';
import 'package:wagtrack/services/news_service.dart';
import 'package:wagtrack/shared/components/page_components.dart';
import 'package:wagtrack/shared/components/text_components.dart';
import 'package:wagtrack/shared/sg_geo.dart';
import 'package:wagtrack/shared/utils.dart';

typedef HitValue = ({String title, String subtitle});

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
          height: 200,
          child: Card(
            color: Colors.white,
            child: FlutterMap(
              options: MapOptions(
                  cameraConstraint:
                      CameraConstraint.containCenter(bounds: bounds),
                  backgroundColor: Colors.transparent,
                  initialCenter:
                      const LatLng(1.365759871533472, 103.8133714773305),
                  initialZoom: 10,
                  maxZoom: 12,
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
                const Text(
                  '0 reports this month',
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      final tappedLineData = tappedLines[index];
                      return ListTile(
                        leading: index == 0
                            ? const Icon(Icons.vertical_align_top)
                            : index == tappedLines.length - 1
                                ? const Icon(Icons.vertical_align_bottom)
                                : const SizedBox.shrink(),
                        title: Text(tappedLineData.title),
                        subtitle: Text(tappedLineData.subtitle),
                        dense: true,
                      );
                    },
                    itemCount: tappedLines.length,
                  ),
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
    // LatLngBounds("north": 1.5819304717578229, "south": 1.0520882648978884, "east": , "west": 103.57949874688475);
    List<Polygon<HitValue>> polygonList = [];
    for (int i = 0; i < sgGeo["features"].length; i++) {
      var objectICoords = sgGeo["features"][i]["geometry"]["coordinates"];
      List<LatLng> points = [];
      for (int j = 0; j < objectICoords[0].length; j++) {
        print(objectICoords[0][j][1]);
        LatLng coord = LatLng(objectICoords[0][j][1], objectICoords[0][j][0]);
        points.add(coord);
      }
      Polygon<HitValue> polygon = Polygon(
        pattern: StrokePattern.dashed(segments: const [50, 20]),
        points: points,
        color: Colors.blue.withOpacity(0.2),
        borderStrokeWidth: 2,
        borderColor: Colors.black,
        hitValue: (
          title: sgGeo["features"][i]["properties"]["name"],
          subtitle: 'Nothing really special here...',
        ),
      );

      polygonList.add(polygon);
    }
    setState(() {
      _polygons = polygonList;
    });
  }
}

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
                    'https://www.nparks.gov.sg/-/media/avs/images/homepage/logo.jpg?h=708&w=1261&la=en',
                    height: 50,
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
