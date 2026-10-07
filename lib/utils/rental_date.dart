import 'dart:convert';

import 'package:intl/intl.dart';

import 'api_datetime.dart';

/// Parses API/DB rental date values (`DATE` columns serialize as `yyyy-MM-dd` or ISO).
String? parseRentalDate(dynamic value) {
  if (value == null) return null;
  final raw = value.toString().trim();
  if (raw.isEmpty) return null;
  if (raw.length >= 10 && raw[4] == '-' && raw[7] == '-') {
    return raw.substring(0, 10);
  }
  try {
    return DateFormat('yyyy-MM-dd').format(DateTime.parse(raw));
  } catch (_) {
    return raw;
  }
}

DateTime? rentalDateToDateTime(String? value) {
  final normalized = parseRentalDate(value);
  if (normalized == null) return null;
  return DateTime.parse(normalized);
}

String formatRentalDateForDisplay(String? value, {String pattern = 'd/M/yyyy'}) {
  final dt = rentalDateToDateTime(value);
  if (dt == null) return value?.trim().isNotEmpty == true ? value! : '—';
  return DateFormat(pattern).format(dt);
}

String _clockFromWindowPart(String raw) {
  final timePart = raw.contains(' ') ? raw.split(' ').last : raw;
  final normalized = timePart.split('.').first;
  final parts = normalized.split(':');
  if (parts.length < 2) return normalized;
  final hour = int.tryParse(parts[0]) ?? 0;
  final minute = parts[1];
  final period = hour >= 12 ? 'PM' : 'AM';
  final hour12 = hour % 12 == 0 ? 12 : hour % 12;
  return '$hour12:${minute.padLeft(2, '0')} $period';
}

/// Formats API handoff window values (ISO or `yyyy-MM-dd HH:mm:ss`) for display.
String formatHandoffWindowRange(String? begin, String? end) {
  final beginText = begin?.trim() ?? '';
  final endText = end?.trim() ?? '';
  if (beginText.isEmpty || endText.isEmpty) return '—';

  DateTime? beginDt = parseApiDateTime(beginText);
  DateTime? endDt = parseApiDateTime(endText);

  if (beginDt != null && endDt != null) {
    final date = DateFormat('M/d/yyyy').format(beginDt);
    final start = DateFormat('h:mm a').format(beginDt);
    final finish = DateFormat('h:mm a').format(endDt);
    return '$date · $start – $finish';
  }

  final datePart = beginText.contains(' ') ? beginText.split(' ').first : beginText;
  final date = formatRentalDateForDisplay(datePart, pattern: 'M/d/yyyy');
  return '$date · ${_clockFromWindowPart(beginText)} – ${_clockFromWindowPart(endText)}';
}

class RentalWindow {
  final int orderId;
  final String? productName;
  final String? startDate;
  final String? endDate;

  const RentalWindow({
    required this.orderId,
    this.productName,
    this.startDate,
    this.endDate,
  });
}

bool rentalRangesOverlap(String? startA, String? endA, String? startB, String? endB) {
  final aStart = rentalDateToDateTime(startA);
  final aEnd = rentalDateToDateTime(endA);
  final bStart = rentalDateToDateTime(startB);
  final bEnd = rentalDateToDateTime(endB);
  if (aStart == null || aEnd == null || bStart == null || bEnd == null) {
    return false;
  }
  return !aStart.isAfter(bEnd) && !aEnd.isBefore(bStart);
}

RentalWindow? findOverlappingRentalOrder({
  required String newStart,
  required String newEnd,
  required Iterable<RentalWindow> existingOrders,
}) {
  for (final order in existingOrders) {
    if (rentalRangesOverlap(newStart, newEnd, order.startDate, order.endDate)) {
      return order;
    }
  }
  return null;
}

/// ISO date keys (`yyyy-MM-dd`) from listing [blocked_dates].
Set<String> parseBlockedDateKeys(dynamic raw) {
  Iterable<dynamic> items = const [];
  if (raw is String && raw.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) items = decoded;
    } catch (_) {
      return {};
    }
  } else if (raw is List) {
    items = raw;
  } else {
    return {};
  }
  final out = <String>{};
  for (final item in items) {
    final key = parseRentalDate(item);
    if (key != null && key.isNotEmpty) out.add(key);
  }
  return out;
}

bool isDayBlocked(DateTime day, Set<String> blockedIsoDates) {
  if (blockedIsoDates.isEmpty) return false;
  final key = DateFormat('yyyy-MM-dd').format(
    DateTime(day.year, day.month, day.day),
  );
  return blockedIsoDates.contains(key);
}

bool isDayInBookedRange(DateTime day, Iterable<RentalWindow> booked) {
  return isDayInBookedRangeWithTurnaround(day, booked, turnaroundHours: 0);
}

/// Includes [turnaroundHours] after each rental end (day-granular calendar).
bool isDayInBookedRangeWithTurnaround(
  DateTime day,
  Iterable<RentalWindow> booked, {
  int turnaroundHours = 0,
}) {
  final normalized = DateTime(day.year, day.month, day.day);
  for (final window in booked) {
    final start = rentalDateToDateTime(window.startDate);
    final end = rentalDateToDateTime(window.endDate);
    if (start == null || end == null) continue;
    var blockedThrough = end;
    if (turnaroundHours > 0) {
      final withBuffer = end.add(Duration(hours: turnaroundHours));
      blockedThrough = DateTime(
        withBuffer.year,
        withBuffer.month,
        withBuffer.day,
      );
    }
    if (!normalized.isBefore(start) && !normalized.isAfter(blockedThrough)) {
      return true;
    }
  }
  return false;
}

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// First calendar day allowed as rental start given advance notice.
DateTime earliestRentalStartDay(int advanceNoticeHours) {
  final afterNotice = DateTime.now().add(Duration(hours: advanceNoticeHours));
  return dateOnly(afterNotice);
}

int rentalDayCountForDates(DateTime start, DateTime end) {
  final a = dateOnly(start);
  final b = dateOnly(end);
  return b.difference(a).inDays + 1;
}

String? validateRentalLengthDays({
  required int dayCount,
  int? minRentalDays,
  int? maxRentalDays,
}) {
  if (minRentalDays != null && dayCount < minRentalDays) {
    return 'Minimum rental length is $minRentalDays day(s).';
  }
  if (maxRentalDays != null && dayCount > maxRentalDays) {
    return 'Maximum rental length is $maxRentalDays day(s).';
  }
  return null;
}

bool rentalRangeIncludesBlockedDay(
  DateTime start,
  DateTime end,
  Set<String> blockedIsoDates,
) {
  if (blockedIsoDates.isEmpty) return false;
  var cursor = dateOnly(start);
  final last = dateOnly(end);
  while (!cursor.isAfter(last)) {
    if (isDayBlocked(cursor, blockedIsoDates)) return true;
    cursor = cursor.add(const Duration(days: 1));
  }
  return false;
}

String? validateRentalStartAdvanceNotice({
  required DateTime start,
  required int advanceNoticeHours,
}) {
  final earliest = earliestRentalStartDay(advanceNoticeHours);
  if (dateOnly(start).isBefore(earliest)) {
    if (advanceNoticeHours <= 24) {
      return 'This listing requires at least $advanceNoticeHours hours advance notice before the rental start.';
    }
    final days = (advanceNoticeHours / 24).ceil();
    return 'This listing requires about $days day(s) advance notice before the rental start.';
  }
  return null;
}

bool isDayUnavailableForRental(
  DateTime day, {
  required Iterable<RentalWindow> booked,
  required Set<String> blockedIsoDates,
  int turnaroundHours = 0,
}) {
  if (isDayBlocked(day, blockedIsoDates)) return true;
  return isDayInBookedRangeWithTurnaround(
    day,
    booked,
    turnaroundHours: turnaroundHours,
  );
}

