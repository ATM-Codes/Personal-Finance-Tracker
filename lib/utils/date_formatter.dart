import 'package:intl/intl.dart';

class DateFormatter {
  static String formatExpenseDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateToCheck).inDays < 7) {
      // Within last week - show day name
      return DateFormat('EEEE').format(date); // Monday, Tuesday, etc.
    } else {
      // Older - show date
      return DateFormat('MMM d').format(date); // Nov 18
    }
  }
}
