import 'package:intl/intl.dart';

class AppDates {
  AppDates._();

  static final DateFormat _display = DateFormat('dd MMM yyyy');

  static String format(DateTime date) => _display.format(date);

  /// Strips the time so due dates are stored as calendar days.
  static DateTime dayOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime get today => dayOnly(DateTime.now());
}
