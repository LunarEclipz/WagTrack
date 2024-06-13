import 'package:intl/intl.dart';

class DateTimeObj {
  late final DateTime dateTime;
  late final String date;
  late final String time;

  DateTimeObj({required this.dateTime, required this.date, required this.time});
}

DateTimeObj formatDateTime(DateTime dateTime) {
  // Format the date to "d MMM yyyy"
  String formattedDate = DateFormat('d MMM yyyy').format(dateTime);

  // Format the time to "h.mm a"
  String formattedTime = DateFormat('h.mm a').format(dateTime);

  // Return the formatted date and time in a map
  return DateTimeObj(
      date: formattedDate, dateTime: dateTime, time: formattedTime);
}
