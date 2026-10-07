import 'package:jebby/models/handoff_window.dart';
import 'package:jebby/models/listing_draft.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String compactHandoffWindowRange(HandoffWindow window) {
  final start = HandoffWindow.formatClock(window.startTime);
  final end = HandoffWindow.formatClock(window.endTime);
  final startParts = start.split(' ');
  final endParts = end.split(' ');
  if (startParts.length >= 2 &&
      endParts.length >= 2 &&
      startParts[1] == endParts[1]) {
    final startHour = startParts[0].replaceAll(':00', '');
    final endHour = endParts[0].replaceAll(':00', '');
    return '$startHour-$endHour ${startParts[1]}';
  }
  return window.displayRange;
}

String formatHandoffDayIndices(List<int> days) {
  if (days.isEmpty) return '';
  final sorted = [...days]..sort();
  final runs = <List<int>>[];
  var run = [sorted.first];
  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == run.last + 1) {
      run.add(sorted[i]);
    } else {
      runs.add(run);
      run = [sorted[i]];
    }
  }
  runs.add(run);

  String runLabel(List<int> chunk) {
    if (chunk.length == 1) return _dayLabels[chunk.first];
    if (chunk.length == 2) {
      return '${_dayLabels[chunk.first]} & ${_dayLabels[chunk.last]}';
    }
    return '${_dayLabels[chunk.first]}-${_dayLabels[chunk.last]}';
  }

  return runs.map(runLabel).join(' & ');
}

/// Headline (days), hours, and optional footnote for mixed custom schedules.
class HandoffTimesSummary {
  const HandoffTimesSummary({
    required this.headline,
    required this.hours,
    this.detail,
  });

  final String headline;
  final String hours;
  final String? detail;

  ({String value, String? subtitle}) get hubLabels {
    if (headline == 'Not set') {
      return (value: headline, subtitle: hours);
    }
    if (headline == 'Every day') {
      if (detail != null) {
        return (value: headline, subtitle: '$hours · $detail');
      }
      return (value: headline, subtitle: hours);
    }
    if (detail != null) {
      return (value: '$headline $hours', subtitle: detail);
    }
    return (value: '$headline $hours', subtitle: null);
  }
}

String _handoffWindowSignature(List<HandoffWindow> windows) => windows
    .map((w) => '${w.startTime}_${w.endTime}')
    .join(';');

String? _otherCustomHoursDetail(
  HandoffSchedule schedule,
  List<int> activeDays,
  int timeGroupCount,
) {
  if (timeGroupCount > 1) return 'and other custom hours';

  final weeklySignature =
      _handoffWindowSignature(schedule.weeklyWindows);
  for (final entry in schedule.perDayOverrides.entries) {
    if (entry.value.isEmpty) continue;
    if (_handoffWindowSignature(entry.value) != weeklySignature) {
      return 'and other custom hours';
    }
  }

  var activeUsesWeekly = false;
  var activeUsesCustom = false;
  var inactiveCustomDay = false;

  for (final day in activeDays) {
    if (schedule.useWeeklyByDay[day] == false) {
      activeUsesCustom = true;
    } else {
      activeUsesWeekly = true;
    }
  }
  for (var day = 0; day < 7; day++) {
    if (!activeDays.contains(day) && schedule.useWeeklyByDay[day] == false) {
      inactiveCustomDay = true;
      break;
    }
  }

  if (inactiveCustomDay) return 'and other custom hours';
  if (activeUsesWeekly && activeUsesCustom) return 'and other custom hours';
  return null;
}

HandoffTimesSummary summarizeHandoffSchedule(HandoffSchedule schedule) {
  final activeDays = schedule.weekdays.toList()..sort();
  if (activeDays.isEmpty) {
    return const HandoffTimesSummary(
      headline: 'Not set',
      hours: 'Add pickup & return times',
    );
  }

  final groups = <String, List<int>>{};
  for (final day in activeDays) {
    final windows = schedule.windowsForDay(day);
    final signature = windows
        .map((w) => '${w.startTime}_${w.endTime}')
        .join(';');
    groups.putIfAbsent(signature, () => []).add(day);
  }

  final entries = groups.entries.toList()
    ..sort((a, b) {
      final len = b.value.length.compareTo(a.value.length);
      if (len != 0) return len;
      return a.value.first.compareTo(b.value.first);
    });

  String hoursForDays(List<int> days) {
    final windows = schedule.windowsForDay(days.first);
    return windows.map(compactHandoffWindowRange).join(' · ');
  }

  final detail =
      _otherCustomHoursDetail(schedule, activeDays, entries.length);

  if (entries.length == 1) {
    final days = entries.first.value..sort();
    final hours = hoursForDays(days);
    final headline =
        days.length >= 7 ? 'Every day' : formatHandoffDayIndices(days);
    return HandoffTimesSummary(
      headline: headline,
      hours: hours,
      detail: detail,
    );
  }

  final primary = entries.first.value..sort();
  return HandoffTimesSummary(
    headline: formatHandoffDayIndices(primary),
    hours: hoursForDays(primary),
    detail: detail,
  );
}

({String value, String? subtitle}) handoffTimesHubLabels(HandoffSchedule schedule) {
  return summarizeHandoffSchedule(schedule).hubLabels;
}
