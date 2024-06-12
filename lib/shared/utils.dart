import 'package:intl/intl.dart';

Map<String, String> formatDateTime(DateTime dateTime) {
  // Format the date to "d MMM yyyy"
  String formattedDate = DateFormat('d MMM yyyy').format(dateTime);

  // Format the time to "h.mm a"
  String formattedTime = DateFormat('h.mm a').format(dateTime);

  // Return the formatted date and time in a map
  return {
    'Date': formattedDate,
    'Time': formattedTime,
  };
}
