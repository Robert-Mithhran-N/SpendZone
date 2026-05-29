import 'package:intl/intl.dart';

/// Date helper utilities.
class DateHelpers {
  DateHelpers._();

  static final _dayFormat = DateFormat('dd MMM');
  static final _fullFormat = DateFormat('dd MMM yyyy');
  static final _timeFormat = DateFormat('hh:mm a');
  static final _monthYear = DateFormat('MMM yyyy');
  static final _dayMonth = DateFormat('dd MMM');
  static final _weekday = DateFormat('EEEE');

  static String formatDay(DateTime date) => _dayFormat.format(date);
  static String formatFull(DateTime date) => _fullFormat.format(date);
  static String formatTime(DateTime date) => _timeFormat.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);
  static String formatDayMonth(DateTime date) => _dayMonth.format(date);
  static String formatWeekday(DateTime date) => _weekday.format(date);

  /// Returns "Today", "Yesterday", or formatted date
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return formatWeekday(date);
    return formatFull(date);
  }

  /// Group key for date-grouped lists (e.g., "Today", "Yesterday", "25 May 2026")
  static String groupKey(DateTime date) => relativeDate(date);

  /// Start of day
  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// End of day
  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

  /// Start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return startOfDay(date.subtract(Duration(days: weekday - 1)));
  }

  /// Start of month
  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  /// End of month
  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59, 999);

  /// Start of year
  static DateTime startOfYear(DateTime date) => DateTime(date.year, 1, 1);

  /// End of year
  static DateTime endOfYear(DateTime date) =>
      DateTime(date.year, 12, 31, 23, 59, 59, 999);

  /// Get list of months between two dates
  static List<DateTime> monthsBetween(DateTime start, DateTime end) {
    final months = <DateTime>[];
    var current = DateTime(start.year, start.month);
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      months.add(current);
      current = DateTime(current.year, current.month + 1);
    }
    return months;
  }

  /// Get the last N months from today
  static List<DateTime> lastNMonths(int n) {
    final now = DateTime.now();
    return List.generate(n, (i) {
      return DateTime(now.year, now.month - i);
    }).reversed.toList();
  }
}
