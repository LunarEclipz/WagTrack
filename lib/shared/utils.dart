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

/// Converts a given `Duration` into a string of the form
/// _ day(s) _ hour(s) _ minute(s) _ second(s)
///
/// 0 counts are not included.
String formatDuration(Duration duration) {
  int days = duration.inDays;
  int hours = duration.inHours.remainder(24);
  int minutes = duration.inMinutes.remainder(60);
  int seconds = duration.inSeconds.remainder(60);

  String durationString = '';

  if (days > 0) {
    durationString = '$durationString$days day' '${days > 1 ? 's ' : ' '}';
  }
  if (hours > 0) {
    durationString = '$durationString$hours hour' '${hours > 1 ? 's ' : ' '}';
  }
  if (minutes > 0) {
    durationString =
        '$durationString$minutes minute' '${minutes > 1 ? 's ' : ' '}';
  }
  if (seconds > 0) {
    durationString =
        '$durationString$seconds second' '${seconds > 1 ? 's ' : ' '}';
  }

  return durationString;
}

int getDaysInMonth({required int year, required int month}) {
  // Handle February for leap years
  if (month == 2) {
    return isLeapYear(year) ? 29 : 28;
  } else if (month == 4 || month == 6 || month == 9 || month == 11) {
    return 30;
  } else {
    return 31;
  }
}

bool isLeapYear(int year) {
  return (year % 4 == 0) && (year % 100 != 0 || year % 400 == 0);
}
