class AVSNews {
  DateTime date;
  String url;
  String orgUrl;

  String title;
  String caption;

  AVSNews({
    required this.date,
    required this.url,
    required this.orgUrl,
    required this.title,
    required this.caption,
  });

  static AVSNews fromJson(Map<String, dynamic> json) {
    AVSNews news = AVSNews(
      date: DateTime.fromMillisecondsSinceEpoch(json["date"] as int),
      url: json["url"] as String,
      title: json["title"] as String,
      orgUrl: json["orgUrl"] as String,
      caption: json["caption"] as String,
    );

    return news;
  }
}

class ReportTileObject {
  late int red;  late String symptom;

  late int yellow;
  late int orange;
  late int green;
  ReportTileObject(
      {required this.red,
      required this.yellow,      required this.symptom,

      required this.green,
      required this.orange});
}
