import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final _dayMonth     = DateFormat('dd MMM');
  static final _dayMonthYear = DateFormat('dd MMM yyyy');
  static final _monthYear    = DateFormat('MMMM yyyy');
  static final _shortMonth   = DateFormat('MMM yyyy');
  static final _time         = DateFormat('hh:mm a');
  static final _full         = DateFormat('EEEE, dd MMMM yyyy');

  static String dayMonth(DateTime d)     => _dayMonth.format(d);
  static String dayMonthYear(DateTime d) => _dayMonthYear.format(d);
  static String monthYear(DateTime d)    => _monthYear.format(d);
  static String shortMonth(DateTime d)   => _shortMonth.format(d);
  static String time(DateTime d)         => _time.format(d);
  static String full(DateTime d)         => _full.format(d);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  static String relative(DateTime d) {
    final now = DateTime.now();
    if (isSameDay(d, now)) return 'Today';
    if (isSameDay(d, now.subtract(const Duration(days: 1)))) return 'Yesterday';
    return dayMonthYear(d);
  }
}