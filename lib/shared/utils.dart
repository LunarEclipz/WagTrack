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

/// Converts a given `DateTime` into a '___ time ago' string.
String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) {
    return 'Just Now';
  } else if (difference.inMinutes < 60) {
    final mins = difference.inMinutes;
    return '$mins minute${mins > 1 ? 's' : ''} ago';
  } else if (difference.inHours < 24) {
    final hrs = difference.inHours;
    return '$hrs hour${hrs > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 7) {
    if (difference.inDays == 1) {
      return 'Yesterday';
    }

    final days = difference.inDays;
    return '$days day${days > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 30) {
    final weeks = (difference.inDays / 7).floor();
    return '$weeks week${weeks > 1 ? 's' : ''} ago';
  } else if (difference.inDays < 365) {
    final months = (difference.inDays / 30).floor();
    return '$months month${months > 1 ? 's' : ''} ago';
  } else {
    final years = (difference.inDays / 365).floor();
    return '$years year${years > 1 ? 's' : ''} ago';
  }
}
