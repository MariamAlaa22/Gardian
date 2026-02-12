import 'package:intl/intl.dart';
import 'constants.dart';

class DateUtilsCustom {
  static const String formatPattern = "yyyy/MM/dd hh:mm:ss a";

  
  static DateTime? stringToDate(String stringDate, String pattern) {
    try {
      return DateFormat(pattern, 'en_US').parse(stringDate);
    } catch (e) {
      print("Error parsing date: $e");
      return null;
    }
  }

  
  static String dateToString(DateTime date, String pattern) {
    return DateFormat(pattern, 'en_US').format(date);
  }

  
  static String getCurrentDateString() {
    return dateToString(DateTime.now(), formatPattern);
  }

  
  static String getFormattedDate(String receivedTime) {
    DateTime? date = stringToDate(receivedTime, formatPattern);
    if (date == null) return receivedTime;

    DateTime now = DateTime.now();
    Duration difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return "A moment ago"; 
    } else if (difference.inMinutes < 60 && now.day == date.day) {
      return "${difference.inMinutes} minutes ago";
    } else if (now.day == date.day) {
      return DateFormat('hh:mm a').format(date);
    } else if (now.subtract(const Duration(days: 1)).day == date.day) {
      return "Yesterday"; 
    } else {
      return DateFormat('MM/dd/yy').format(date);
    }
  }
}