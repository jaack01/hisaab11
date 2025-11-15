import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

/// Utility class for date and time operations
class AppDateUtils {
  // Private constructor
  AppDateUtils._();

  /// Get current timestamp in seconds (Unix epoch)
  static int getCurrentTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  /// Get current timestamp in milliseconds
  static int getCurrentTimestampMillis() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  /// Convert DateTime to Unix timestamp (seconds)
  static int dateTimeToTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// Convert Unix timestamp (seconds) to DateTime
  static DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// Format DateTime to default date string
  static String formatDate(DateTime dateTime,
      {String? format}) {
    final dateFormat = DateFormat(format ?? AppConstants.defaultDateFormat);
    return dateFormat.format(dateTime);
  }

  /// Format timestamp to default date string
  static String formatTimestamp(int timestamp, {String? format}) {
    final dateTime = timestampToDateTime(timestamp);
    return formatDate(dateTime, format: format);
  }

  /// Format DateTime to date-time string
  static String formatDateTime(DateTime dateTime) {
    final dateFormat = DateFormat(AppConstants.dateTimeFormat);
    return dateFormat.format(dateTime);
  }

  /// Format DateTime to time string
  static String formatTime(DateTime dateTime) {
    final dateFormat = DateFormat(AppConstants.timeFormat);
    return dateFormat.format(dateTime);
  }

  /// Format DateTime to month-year string
  static String formatMonthYear(DateTime dateTime) {
    final dateFormat = DateFormat(AppConstants.monthYearFormat);
    return dateFormat.format(dateTime);
  }

  /// Parse date string to DateTime
  static DateTime? parseDate(String dateString, {String? format}) {
    try {
      final dateFormat = DateFormat(format ?? AppConstants.defaultDateFormat);
      return dateFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get start of day (00:00:00)
  static DateTime getStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// Get end of day (23:59:59)
  static DateTime getEndOfDay(DateTime dateTime) {
    return DateTime(
      dateTime.year,
      dateTime.month,
      dateTime.day,
      23,
      59,
      59,
      999,
    );
  }

  /// Get start of month
  static DateTime getStartOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// Get end of month
  static DateTime getEndOfMonth(DateTime dateTime) {
    final nextMonth = dateTime.month == 12
        ? DateTime(dateTime.year + 1, 1, 1)
        : DateTime(dateTime.year, dateTime.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1, hours: 0, minutes: 0, seconds: 1));
  }

  /// Get start of year
  static DateTime getStartOfYear(DateTime dateTime) {
    return DateTime(dateTime.year, 1, 1);
  }

  /// Get end of year
  static DateTime getEndOfYear(DateTime dateTime) {
    return DateTime(dateTime.year, 12, 31, 23, 59, 59, 999);
  }

  /// Check if date is today
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Check if date is this month
  static bool isThisMonth(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year && dateTime.month == now.month;
  }

  /// Check if date is this year
  static bool isThisYear(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year;
  }

  /// Get relative date string (Today, Yesterday, or formatted date)
  static String getRelativeDateString(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today';
    } else if (isYesterday(dateTime)) {
      return 'Yesterday';
    } else {
      return formatDate(dateTime);
    }
  }

  /// Get time ago string (5 mins ago, 2 hours ago, etc.)
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'min' : 'mins'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  /// Get number of days between two dates
  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  /// Add days to a date
  static DateTime addDays(DateTime dateTime, int days) {
    return dateTime.add(Duration(days: days));
  }

  /// Add months to a date
  static DateTime addMonths(DateTime dateTime, int months) {
    return DateTime(
      dateTime.year,
      dateTime.month + months,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  /// Add years to a date
  static DateTime addYears(DateTime dateTime, int years) {
    return DateTime(
      dateTime.year + years,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  /// Get financial year (April to March in India)
  static String getFinancialYear(DateTime dateTime) {
    if (dateTime.month >= 4) {
      return '${dateTime.year}-${dateTime.year + 1}';
    } else {
      return '${dateTime.year - 1}-${dateTime.year}';
    }
  }

  /// Get start of financial year
  static DateTime getStartOfFinancialYear(DateTime dateTime) {
    if (dateTime.month >= 4) {
      return DateTime(dateTime.year, 4, 1);
    } else {
      return DateTime(dateTime.year - 1, 4, 1);
    }
  }

  /// Get end of financial year
  static DateTime getEndOfFinancialYear(DateTime dateTime) {
    if (dateTime.month >= 4) {
      return DateTime(dateTime.year + 1, 3, 31, 23, 59, 59, 999);
    } else {
      return DateTime(dateTime.year, 3, 31, 23, 59, 59, 999);
    }
  }
}
