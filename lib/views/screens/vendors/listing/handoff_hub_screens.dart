import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:jebby/constants/color.dart';
import 'package:jebby/models/handoff_window.dart';
import 'package:jebby/models/listing_draft.dart';
import 'package:jebby/utils/listing_handoff_summary.dart';
import 'package:jebby/utils/show_snackbar.dart';
import 'package:jebby/view_models/listing_form_controller.dart';
import 'package:jebby/views/screens/onboarding/onboarding_form_widgets.dart';
import 'package:jebby/views/screens/onboarding/onboarding_kit.dart';
import 'package:jebby/views/screens/vendors/listing/listing_kit.dart';

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

const _dayFullNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String _compactHandoffWindowRange(HandoffWindow window) {
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

String _handoffDayHoursSummary(List<HandoffWindow> windows) {
  if (windows.isEmpty) return 'No hours set';
  return windows.map(_compactHandoffWindowRange).join(' · ');
}

TimeOfDay _parseHandoffTime(String raw) {
  final parts = raw.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts.first) ?? 0,
    minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
  );
}

String _formatHandoffTime(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m:00';
}

int _handoffTimeMinutes(String raw) {
  final t = _parseHandoffTime(raw);
  return t.hour * 60 + t.minute;
}

TimeOfDay _addHandoffMinutes(TimeOfDay time, int minutes) {
  var total = time.hour * 60 + time.minute + minutes;
  if (total >= 24 * 60) total = 23 * 60 + 59;
  return TimeOfDay(hour: total ~/ 60, minute: total % 60);
}

bool _handoffEndIsAfterStart(String start, String end) {
  return _handoffTimeMinutes(end) > _handoffTimeMinutes(start);
}

List<HandoffWindow> _handoffWindowsForDayEdit(
  HandoffSchedule schedule,
  int dayIndex,
  bool useWeekly,
) {
  if (useWeekly) return List<HandoffWindow>.from(schedule.weeklyWindows);
  return List<HandoffWindow>.from(
    schedule.perDayOverrides[dayIndex] ?? schedule.weeklyWindows,
  );
}

/// Day-times screen edits always become per-day custom hours; weekly slots stay shared.
HandoffSchedule _handoffScheduleAfterDayTimesEdit(
  HandoffSchedule schedule,
  int dayIndex,
  List<HandoffWindow> windows,
) {
  final useWeekly = Map<int, bool>.from(schedule.useWeeklyByDay);
  useWeekly[dayIndex] = false;
  final overrides = Map<int, List<HandoffWindow>>.from(schedule.perDayOverrides);
  overrides[dayIndex] = windows;
  return schedule.copyWith(
    useWeeklyByDay: useWeekly,
    perDayOverrides: overrides,
  );
}

/// Slightly darker than [AppColors.jebbySoftBlue] for blocked calendar days.
const _blockedDayFill = Color(0xFFCAD8FF);

DateTime _availabilityToday() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

bool _isPastAvailabilityDay(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.isBefore(_availabilityToday());
}

class ListingHandoffTimesScreen extends StatefulWidget {
  const ListingHandoffTimesScreen({super.key});

  @override
  State<ListingHandoffTimesScreen> createState() =>
      _ListingHandoffTimesScreenState();
}

class _ListingHandoffTimesScreenState extends State<ListingHandoffTimesScreen> {
  String _daysCaption(Set<int> days) {
    if (days.length == 7) return 'Every day selected';
    if (days.length == 1) return '1 day selected';
    return '${days.length} days selected';
  }

  Future<void> _pickWindowTime(
    ListingFormController c,
    HandoffSchedule schedule,
    int windowIndex, {
    required bool isStart,
  }) async {
    final window = schedule.weeklyWindows[windowIndex];
    final startParsed = _parseHandoffTime(window.startTime);
    final initial = isStart
        ? startParsed
        : _handoffEndIsAfterStart(window.startTime, window.endTime)
            ? _parseHandoffTime(window.endTime)
            : _addHandoffMinutes(startParsed, 60);
    final picked = await showListingTimeWheelSheet(
      context,
      title: isStart ? 'Start time' : 'End time',
      initial: initial,
    );
    if (picked == null || !mounted) return;

    var newStart = window.startTime;
    var newEnd = window.endTime;

    if (isStart) {
      newStart = _formatHandoffTime(picked);
      if (!_handoffEndIsAfterStart(newStart, newEnd)) {
        newEnd = _formatHandoffTime(_addHandoffMinutes(picked, 60));
      }
    } else {
      newEnd = _formatHandoffTime(picked);
      if (!_handoffEndIsAfterStart(newStart, newEnd)) {
        showAppErrorSnackbar('End time must be after start time.');
        return;
      }
    }

    final windows = [...schedule.weeklyWindows];
    windows[windowIndex] = HandoffWindow(
      startTime: newStart,
      endTime: newEnd,
    );
    c.draft.handoffSchedule = schedule.copyWith(weeklyWindows: windows);
    c.markDirty();
    c.update();
  }

  void _addWindow(ListingFormController c, HandoffSchedule schedule) {
    final windows = [
      ...schedule.weeklyWindows,
      HandoffWindow(startTime: '08:00:00', endTime: '09:00:00'),
    ];
    c.draft.handoffSchedule = schedule.copyWith(weeklyWindows: windows);
    c.markDirty();
    c.update();
  }

  void _removeWindow(
    ListingFormController c,
    HandoffSchedule schedule,
    int index,
  ) {
    if (schedule.weeklyWindows.length <= 1) return;
    final windows = [...schedule.weeklyWindows]..removeAt(index);
    c.draft.handoffSchedule = schedule.copyWith(weeklyWindows: windows);
    c.markDirty();
    c.update();
  }

  List<String> _summaryLines(HandoffSchedule schedule) {
    final days = schedule.weekdays.toList()..sort();
    return days.map((day) {
      final windows = schedule.windowsForDay(day);
      if (windows.isEmpty) {
        return '${_dayLabels[day]} — No hours set';
      }
      final ranges = windows.map((w) => w.displayRange).join(', ');
      return '${_dayLabels[day]} - $ranges';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final schedule = c.draft.handoffSchedule;
        final summaryLines = _summaryLines(schedule);
        final previewLines = summaryLines.take(2).toList();

        return OnboardingShell(
          title: 'Pickup & return times',
          subtitle: 'Set weekly pickup and return times.',
          headerDivider: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Make time for the handoff.',
                style: onboardingNunito(size: 22, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose days and times for pickup and return.',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              Text('Days', style: onboardingNunito(size: 16, weight: FontWeight.w800)),
              const SizedBox(height: 10),
              Row(
                children: List.generate(7, (i) {
                  final selected = schedule.weekdays.contains(i);
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: i < 6 ? 4 : 0),
                      child: Material(
                        color: selected ? AppColors.jebbyBlue : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          onTap: () {
                            final days = Set<int>.from(schedule.weekdays);
                            if (selected) {
                              days.remove(i);
                            } else {
                              days.add(i);
                            }
                            if (days.isEmpty) return;
                            c.draft.handoffSchedule =
                                schedule.copyWith(weekdays: days);
                            c.markDirty();
                            c.update();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? AppColors.jebbyBlue
                                    : const Color(0xFFE3E6EC),
                              ),
                            ),
                            child: Text(
                              _dayLabels[i],
                              style: onboardingNunito(
                                size: 13,
                                weight: FontWeight.w800,
                                color: selected
                                    ? Colors.white
                                    : AppColors.jebbyTextPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _daysCaption(schedule.weekdays),
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Weekly hours',
                style: onboardingNunito(size: 16, weight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.earnerInfoBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(schedule.weeklyWindows.length, (index) {
                      final window = schedule.weeklyWindows[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index < schedule.weeklyWindows.length - 1 ? 14 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: _HandoffTimePickerField(
                                label: 'Start',
                                value: HandoffWindow.formatClock(window.startTime),
                                onTap: () => _pickWindowTime(
                                  c,
                                  schedule,
                                  index,
                                  isStart: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HandoffTimePickerField(
                                label: 'End',
                                value: HandoffWindow.formatClock(window.endTime),
                                onTap: () => _pickWindowTime(
                                  c,
                                  schedule,
                                  index,
                                  isStart: false,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _HandoffRemoveWindowButton(
                              onPressed: schedule.weeklyWindows.length > 1
                                  ? () => _removeWindow(c, schedule, index)
                                  : null,
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _addWindow(c, schedule),
                        icon: Icon(Icons.add, color: AppColors.jebbyBlue, size: 20),
                        label: Text(
                          'Add time window',
                          style: onboardingNunito(
                            size: 15,
                            weight: FontWeight.w800,
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.to(() => const ListingHandoffHoursByDayScreen()),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE3E6EC)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hours by day',
                                  style: onboardingNunito(
                                    size: 16,
                                    weight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Customize individual days',
                                  style: onboardingNunito(
                                    size: 13,
                                    weight: FontWeight.w600,
                                    color: AppColors.jebbyTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: AppColors.jebbyTextMuted.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Also used for delivery and retrieval.',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'All times are local to your item.',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3E6EC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Weekly hours',
                            style: onboardingNunito(
                              size: 16,
                              weight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${schedule.weekdays.length} days',
                          style: onboardingNunito(
                            size: 14,
                            weight: FontWeight.w800,
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                      ],
                    ),
                    if (previewLines.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ...previewLines.map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text(
                            line,
                            style: onboardingNunito(
                              size: 14,
                              weight: FontWeight.w600,
                              color: AppColors.jebbyTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () =>
                            Get.to(() => const ListingHandoffHoursByDayScreen()),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'View all days ›',
                          style: onboardingNunito(
                            size: 14,
                            weight: FontWeight.w800,
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomBar: OnboardingPrimaryButton(
            label: 'Save times',
            onPressed: () {
              c.persistDraft();
              Get.back();
            },
          ),
        );
      },
    );
  }
}

class _HandoffTimePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _HandoffTimePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: onboardingNunito(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
          ),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: onboardingNunito(
                        size: 14,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.expand_more,
                    size: 20,
                    color: AppColors.jebbyTextMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HandoffRemoveWindowButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _HandoffRemoveWindowButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: onPressed == null
                  ? AppColors.jebbyTextMuted.withValues(alpha: 0.3)
                  : AppColors.jebbyBlue,
              width: 1.5,
            ),
          ),
          child: Icon(
            Icons.remove,
            size: 18,
            color: onPressed == null
                ? AppColors.jebbyTextMuted.withValues(alpha: 0.3)
                : AppColors.jebbyBlue,
          ),
        ),
      ),
    );
  }
}

class ListingHandoffHoursByDayScreen extends StatelessWidget {
  const ListingHandoffHoursByDayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final schedule = c.draft.handoffSchedule;
        return OnboardingShell(
          title: 'Hours by day',
          subtitle: 'Customize availability by day.',
          headerDivider: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Make each day work.',
                style: onboardingNunito(size: 22, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a day to adjust its hours.',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(7, (i) {
                final usesWeekly = schedule.useWeeklyByDay[i] ?? true;
                final windows = schedule.windowsForDay(i);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HandoffDayHoursCard(
                    dayName: _dayFullNames[i],
                    statusLabel:
                        usesWeekly ? 'Weekly hours' : 'Custom hours',
                    hoursSummary: _handoffDayHoursSummary(windows),
                    onTap: () => Get.to(
                      () => ListingHandoffDayTimesScreen(dayIndex: i),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'Each day can use weekly or custom hours.',
                textAlign: TextAlign.center,
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HandoffDayHoursCard extends StatelessWidget {
  final String dayName;
  final String statusLabel;
  final String hoursSummary;
  final VoidCallback onTap;

  const _HandoffDayHoursCard({
    required this.dayName,
    required this.statusLabel,
    required this.hoursSummary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3E6EC)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dayName,
                        style: onboardingNunito(
                          size: 16,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: onboardingNunito(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hoursSummary,
                        style: onboardingNunito(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.jebbyTextMuted.withValues(alpha: 0.65),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ListingHandoffDayTimesScreen extends StatefulWidget {
  final int dayIndex;

  const ListingHandoffDayTimesScreen({super.key, required this.dayIndex});

  @override
  State<ListingHandoffDayTimesScreen> createState() =>
      _ListingHandoffDayTimesScreenState();
}

class _ListingHandoffDayTimesScreenState extends State<ListingHandoffDayTimesScreen> {
  Future<void> _pickDayWindowTime(
    ListingFormController c,
    HandoffSchedule schedule,
    bool useWeekly,
    int windowIndex, {
    required bool isStart,
  }) async {
    final windows = _handoffWindowsForDayEdit(schedule, widget.dayIndex, useWeekly);
    final window = windows[windowIndex];
    final startParsed = _parseHandoffTime(window.startTime);
    final initial = isStart
        ? startParsed
        : _handoffEndIsAfterStart(window.startTime, window.endTime)
            ? _parseHandoffTime(window.endTime)
            : _addHandoffMinutes(startParsed, 60);

    final picked = await showListingTimeWheelSheet(
      context,
      title: isStart ? 'Start time' : 'End time',
      initial: initial,
    );
    if (picked == null || !mounted) return;

    var newStart = window.startTime;
    var newEnd = window.endTime;

    if (isStart) {
      newStart = _formatHandoffTime(picked);
      if (!_handoffEndIsAfterStart(newStart, newEnd)) {
        newEnd = _formatHandoffTime(_addHandoffMinutes(picked, 60));
      }
    } else {
      newEnd = _formatHandoffTime(picked);
      if (!_handoffEndIsAfterStart(newStart, newEnd)) {
        showAppErrorSnackbar('End time must be after start time.');
        return;
      }
    }

    final updated = [...windows];
    updated[windowIndex] = HandoffWindow(startTime: newStart, endTime: newEnd);
    c.draft.handoffSchedule = _handoffScheduleAfterDayTimesEdit(
      schedule,
      widget.dayIndex,
      updated,
    );
    c.markDirty();
    c.update();
  }

  void _addDayWindow(
    ListingFormController c,
    HandoffSchedule schedule,
    bool useWeekly,
  ) {
    final windows = _handoffWindowsForDayEdit(schedule, widget.dayIndex, useWeekly);
    windows.add(HandoffWindow(startTime: '08:00:00', endTime: '09:00:00'));
    c.draft.handoffSchedule = _handoffScheduleAfterDayTimesEdit(
      schedule,
      widget.dayIndex,
      windows,
    );
    c.markDirty();
    c.update();
  }

  void _removeDayWindow(
    ListingFormController c,
    HandoffSchedule schedule,
    bool useWeekly,
    int index,
  ) {
    final windows = _handoffWindowsForDayEdit(schedule, widget.dayIndex, useWeekly);
    if (windows.length <= 1) return;
    windows.removeAt(index);
    c.draft.handoffSchedule = _handoffScheduleAfterDayTimesEdit(
      schedule,
      widget.dayIndex,
      windows,
    );
    c.markDirty();
    c.update();
  }

  void _setUseWeekly(ListingFormController c, HandoffSchedule schedule, bool useWeekly) {
    final map = Map<int, bool>.from(schedule.useWeeklyByDay);
    map[widget.dayIndex] = useWeekly;

    var next = schedule.copyWith(useWeeklyByDay: map);
    if (!useWeekly) {
      final overrides = Map<int, List<HandoffWindow>>.from(schedule.perDayOverrides);
      overrides.putIfAbsent(
        widget.dayIndex,
        () => List<HandoffWindow>.from(schedule.weeklyWindows),
      );
      next = next.copyWith(perDayOverrides: overrides);
    }

    c.draft.handoffSchedule = next;
    c.markDirty();
    c.update();
  }

  @override
  Widget build(BuildContext context) {
    final dayName = _dayFullNames[widget.dayIndex];
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final schedule = c.draft.handoffSchedule;
        final useWeekly = schedule.useWeeklyByDay[widget.dayIndex] ?? true;
        final windows =
            _handoffWindowsForDayEdit(schedule, widget.dayIndex, useWeekly);

        return OnboardingShell(
          title: '$dayName times',
          subtitle: 'Set custom pickup times for $dayName.',
          headerDivider: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Make $dayName work for you.',
                style: onboardingNunito(size: 22, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Set different hours for this day.',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3E6EC)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Use weekly hours',
                            style: onboardingNunito(
                              size: 16,
                              weight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Keep the same hours as other days.',
                            style: onboardingNunito(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppColors.jebbyTextMuted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListingHandoffSwitch(
                      value: useWeekly,
                      onChanged: (v) => _setUseWeekly(c, schedule, v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '$dayName hours',
                style: onboardingNunito(size: 16, weight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.earnerInfoBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...List.generate(windows.length, (index) {
                      final window = windows[index];
                      return Column(
                        children: [
                          if (index > 0) ...[
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFCDDAFE),
                            ),
                            const SizedBox(height: 14),
                          ],
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: _HandoffTimePickerField(
                                  label: 'Start',
                                  value: HandoffWindow.formatClock(
                                    window.startTime,
                                  ),
                                  onTap: () => _pickDayWindowTime(
                                    c,
                                    schedule,
                                    useWeekly,
                                    index,
                                    isStart: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _HandoffTimePickerField(
                                  label: 'End',
                                  value: HandoffWindow.formatClock(
                                    window.endTime,
                                  ),
                                  onTap: () => _pickDayWindowTime(
                                    c,
                                    schedule,
                                    useWeekly,
                                    index,
                                    isStart: false,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _HandoffRemoveWindowButton(
                                onPressed: windows.length > 1
                                    ? () => _removeDayWindow(
                                          c,
                                          schedule,
                                          useWeekly,
                                          index,
                                        )
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _addDayWindow(c, schedule, useWeekly),
                        icon: Icon(
                          Icons.add,
                          color: AppColors.jebbyBlue,
                          size: 20,
                        ),
                        label: Text(
                          'Add time window',
                          style: onboardingNunito(
                            size: 15,
                            weight: FontWeight.w800,
                            color: AppColors.jebbyBlue,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.earnerInfoBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Only $dayName changes',
                      style: onboardingNunito(size: 16, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Other days keep their current hours.',
                      style: onboardingNunito(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'All times are local to your item.',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
            ],
          ),
          bottomBar: OnboardingPrimaryButton(
            label: 'Apply day',
            onPressed: () {
              c.persistDraft();
              Get.back();
            },
          ),
        );
      },
    );
  }
}

LatLng _listingLocationMapTarget(ListingLocation location) {
  final lat = location.latitude;
  final lng = location.longitude;
  if (lat != null && lng != null) {
    return LatLng(lat, lng);
  }
  return const LatLng(27.9506, -82.4572);
}

double _parseDeliveryRadiusMiles(String raw) {
  final v = double.tryParse(raw.trim());
  if (v == null || v <= 0) return 10;
  return v;
}

double _mapZoomForDeliveryRadiusMiles(double miles) {
  if (miles <= 5) return 11;
  if (miles <= 10) return 10;
  if (miles <= 20) return 9;
  if (miles <= 40) return 8;
  return 7;
}

String _formatDeliveryFeeField(String raw) {
  final cleaned = raw.replaceAll(RegExp(r'[^0-9.]'), '');
  final value = double.tryParse(cleaned) ?? 0;
  return value.toStringAsFixed(2);
}

String _deliveryFeeDraftValue(String fieldText) {
  final cleaned = fieldText.replaceAll(RegExp(r'[^0-9.]'), '');
  if (cleaned.isEmpty) return '0';
  final value = double.tryParse(cleaned);
  if (value == null) return '0';
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(2);
}

void _showPickupDeliveryRequiredSnackbar() {
  showAppErrorSnackbar(
    'At least one of Pickup & return or Delivery & retrieval must stay enabled.',
    title: 'Required',
  );
}

class _PickupDeliveryOptionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool showDividerBelow;

  const _PickupDeliveryOptionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.showDividerBelow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.earnerInfoBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.jebbyBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: onboardingNunito(
                        size: 16,
                        weight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: onboardingNunito(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.jebbyTextMuted,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ListingHandoffSwitch(value: value, onChanged: onChanged),
            ],
          ),
        ),
        if (showDividerBelow)
          const Divider(
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
            color: Color(0xFFE3E6EC),
          ),
      ],
    );
  }
}

class _YourHandoffTimesCard extends StatelessWidget {
  final String dayCaption;
  final String hoursSummary;
  final String? detailCaption;
  final VoidCallback onTap;

  const _YourHandoffTimesCard({
    required this.dayCaption,
    required this.hoursSummary,
    this.detailCaption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.earnerInfoBlue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.schedule_outlined,
                    color: AppColors.jebbyBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your handoff times',
                        style: onboardingNunito(
                          size: 16,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dayCaption,
                        style: onboardingNunito(
                          size: 14,
                          weight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hoursSummary,
                        style: onboardingNunito(
                          size: 14,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextPrimary,
                        ),
                      ),
                      if (detailCaption != null &&
                          detailCaption!.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          detailCaption!,
                          style: onboardingNunito(
                            size: 13,
                            weight: FontWeight.w600,
                            color: AppColors.jebbyTextMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Uses your pickup & return times.',
                        style: onboardingNunito(
                          size: 13,
                          weight: FontWeight.w600,
                          color: AppColors.jebbyTextMuted,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryRadiusField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const _DeliveryRadiusField({
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Delivery radius',
            style: onboardingNunito(
              size: 13,
              weight: FontWeight.w600,
              color: AppColors.jebbyTextMuted,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: onChanged,
                  style: onboardingNunito(
                    size: 22,
                    weight: FontWeight.w800,
                    height: 1.1,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                'mi',
                style: onboardingNunito(
                  size: 15,
                  weight: FontWeight.w700,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DeliveryFeeField extends StatelessWidget {
  final TextEditingController controller;

  const _DeliveryFeeField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: onboardingNunito(size: 18, weight: FontWeight.w800),
        decoration: InputDecoration(
          isDense: true,
          prefixText: '\$',
          prefixStyle: onboardingNunito(size: 18, weight: FontWeight.w800),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}

class _DeliveryRadiusMapPreview extends StatelessWidget {
  final LatLng target;
  final double radiusMiles;

  const _DeliveryRadiusMapPreview({
    required this.target,
    required this.radiusMiles,
  });

  @override
  Widget build(BuildContext context) {
    final radiusMeters = radiusMiles * 1609.344;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 168,
        width: double.infinity,
        child: GoogleMap(
          key: ValueKey(
            '${target.latitude.toStringAsFixed(5)}_'
            '${target.longitude.toStringAsFixed(5)}_'
            '${radiusMiles.toStringAsFixed(1)}',
          ),
          initialCameraPosition: CameraPosition(
            target: target,
            zoom: _mapZoomForDeliveryRadiusMiles(radiusMiles),
          ),
          circles: {
            Circle(
              circleId: const CircleId('delivery_radius'),
              center: target,
              radius: radiusMeters,
              fillColor: AppColors.jebbyBlue.withValues(alpha: 0.18),
              strokeColor: AppColors.jebbyBlue.withValues(alpha: 0.35),
              strokeWidth: 1,
            ),
          },
          markers: {
            Marker(
              markerId: const MarkerId('item_location'),
              position: target,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
            ),
          },
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          liteModeEnabled: true,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          zoomGesturesEnabled: false,
        ),
      ),
    );
  }
}

class ListingPickupDeliveryScreen extends StatefulWidget {
  const ListingPickupDeliveryScreen({super.key});

  @override
  State<ListingPickupDeliveryScreen> createState() =>
      _ListingPickupDeliveryScreenState();
}

class _ListingPickupDeliveryScreenState extends State<ListingPickupDeliveryScreen> {
  late TextEditingController _fee;
  late TextEditingController _radius;

  @override
  void initState() {
    super.initState();
    final d = Get.find<ListingFormController>().draft.delivery;
    _fee = TextEditingController(text: _formatDeliveryFeeField(d.deliveryFee));
    _radius = TextEditingController(
      text: d.deliveryRadiusMiles.trim().isEmpty ? '10' : d.deliveryRadiusMiles,
    );
  }

  @override
  void dispose() {
    _fee.dispose();
    _radius.dispose();
    super.dispose();
  }

  void _setPickup(ListingFormController c, DeliveryOptions d, bool value) {
    if (!value && !d.offersDelivery) {
      _showPickupDeliveryRequiredSnackbar();
      return;
    }
    c.draft.delivery = d.copyWith(offersPickup: value);
    c.markDirty();
    c.update();
  }

  void _setDelivery(ListingFormController c, DeliveryOptions d, bool value) {
    if (!value && !d.offersPickup) {
      _showPickupDeliveryRequiredSnackbar();
      return;
    }
    c.draft.delivery = d.copyWith(offersDelivery: value);
    c.markDirty();
    c.update();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final d = c.draft.delivery;
        final schedule = c.draft.handoffSchedule;
        final location = c.draft.location;
        final offersDelivery = d.offersDelivery;
        final mapTarget = _listingLocationMapTarget(location);
        final radiusMiles = _parseDeliveryRadiusMiles(_radius.text);
        final locationLabel = location.publicCityState.trim().isEmpty
            ? 'your saved address'
            : location.publicCityState.trim();
        final handoffSummary = summarizeHandoffSchedule(schedule);

        return OnboardingShell(
          title: 'Pickup & delivery',
          subtitle: offersDelivery
              ? 'Set the delivery area and fee.'
              : 'Choose pickup or delivery options.',
          headerDivider: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              if (offersDelivery) ...[
                Text(
                  'How will renters get your item',
                  style: onboardingNunito(size: 22, weight: FontWeight.w800),
                ),
              ] else ...[
                Text(
                  'Make the handoff work.',
                  style: onboardingNunito(size: 22, weight: FontWeight.w800),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Choose one or both options.',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE3E6EC)),
                ),
                child: Column(
                  children: [
                    _PickupDeliveryOptionRow(
                      icon: Icons.inventory_2_outlined,
                      title: 'Pickup & return',
                      subtitle: 'Renters collect and return your item.',
                      value: d.offersPickup,
                      onChanged: (v) => _setPickup(c, d, v),
                      showDividerBelow: true,
                    ),
                    _PickupDeliveryOptionRow(
                      icon: Icons.local_shipping_outlined,
                      title: 'Delivery & retrieval',
                      subtitle: 'You deliver and collect your item.',
                      value: d.offersDelivery,
                      onChanged: (v) => _setDelivery(c, d, v),
                    ),
                  ],
                ),
              ),
              if (offersDelivery) ...[
                const SizedBox(height: 24),
                Text(
                  'Delivery area',
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _DeliveryRadiusField(
                  controller: _radius,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                _DeliveryRadiusMapPreview(
                  target: mapTarget,
                  radiusMiles: radiusMiles,
                ),
                const SizedBox(height: 8),
                Text(
                  'From your item location in $locationLabel.',
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Delivery & retrieval fee',
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                _DeliveryFeeField(controller: _fee),
                const SizedBox(height: 10),
                Text(
                  'One total fee for both trips.',
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Set to \$0 for free delivery and retrieval.',
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Uses your handoff times.',
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                    height: 1.35,
                  ),
                ),
              ] else if (d.offersPickup) ...[
                const SizedBox(height: 16),
                _YourHandoffTimesCard(
                  dayCaption: handoffSummary.headline,
                  hoursSummary: handoffSummary.hours,
                  detailCaption: handoffSummary.detail,
                  onTap: () => Get.to(() => const ListingHandoffTimesScreen()),
                ),
              ],
            ],
          ),
          bottomBar: OnboardingPrimaryButton(
            label: 'Save handoff options',
            onPressed: () {
              c.draft.delivery = d.copyWith(
                deliveryFee: _deliveryFeeDraftValue(_fee.text),
                deliveryRadiusMiles: _radius.text.trim().isEmpty
                    ? '10'
                    : _radius.text.trim(),
              );
              c.markDirty();
              c.persistDraft();
              Get.back();
            },
          ),
        );
      },
    );
  }
}

class ListingItemAvailabilityScreen extends StatefulWidget {
  const ListingItemAvailabilityScreen({super.key});

  @override
  State<ListingItemAvailabilityScreen> createState() =>
      _ListingItemAvailabilityScreenState();
}

class _ListingItemAvailabilityScreenState extends State<ListingItemAvailabilityScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  List<String>? _undoStack;
  int? _savedBannerDays;

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Set<String> get _pendingDates {
    if (_rangeStart == null) return {};
    final a = DateTime(_rangeStart!.year, _rangeStart!.month, _rangeStart!.day);
    final b = _rangeEnd != null
        ? DateTime(_rangeEnd!.year, _rangeEnd!.month, _rangeEnd!.day)
        : a;
    final start = a.isBefore(b) ? a : b;
    final end = a.isBefore(b) ? b : a;
    final out = <String>{};
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      if (!_isPastAvailabilityDay(d)) {
        out.add(_fmt(d));
      }
    }
    return out;
  }

  void _onDayTap(DateTime date) {
    final tapped = DateTime(date.year, date.month, date.day);
    if (_isPastAvailabilityDay(tapped)) return;

    setState(() {
      _savedBannerDays = null;

      if (_rangeStart == null || _rangeEnd != null) {
        _rangeStart = tapped;
        _rangeEnd = null;
        return;
      }

      if (tapped.isBefore(_rangeStart!)) {
        _rangeEnd = _rangeStart;
        _rangeStart = tapped;
      } else {
        _rangeEnd = tapped;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _rangeStart = null;
      _rangeEnd = null;
    });
  }

  String? _rangeLabel(Set<String> keys) {
    if (keys.isEmpty) return null;
    final dates = keys.map(DateTime.parse).toList()..sort();
    final count = dates.length;
    final start = dates.first;
    final end = dates.last;
    final month = DateFormat('MMM').format(start);
    if (count == 1) {
      return '$month ${start.day} • 1 day';
    }
    if (start.month == end.month) {
      return '$month ${start.day} - ${end.day} • $count days';
    }
    final endMonth = DateFormat('MMM').format(end);
    return '$month ${start.day} - $endMonth ${end.day} • $count days';
  }

  void _blockPending(ListingFormController c, Set<String> blocked) {
    final pending = _pendingDates.where((key) {
      return !_isPastAvailabilityDay(DateTime.parse(key));
    }).toSet();
    if (pending.isEmpty) return;
    _undoStack = blocked.toList();
    blocked.addAll(pending);
    c.draft.availability = c.draft.availability.copyWith(
      blockedDates: blocked.toList()..sort(),
    );
    setState(() {
      _savedBannerDays = pending.length;
      _rangeStart = null;
      _rangeEnd = null;
    });
    c.markDirty();
    c.update();
  }

  void _undoBlock(ListingFormController c) {
    if (_undoStack == null) return;
    c.draft.availability = c.draft.availability.copyWith(
      blockedDates: _undoStack!,
    );
    setState(() => _savedBannerDays = null);
    c.markDirty();
    c.update();
  }

  void _unblockAll(ListingFormController c) {
    c.draft.availability =
        c.draft.availability.copyWith(blockedDates: []);
    setState(() {
      _savedBannerDays = null;
      _undoStack = null;
    });
    c.markDirty();
    c.update();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        final blocked = Set<String>.from(c.draft.availability.blockedDates);
        final pending = _pendingDates;
        final hasPending = pending.isNotEmpty;
        final hasBlocked = blocked.isNotEmpty;
        final pendingLabel = _rangeLabel(pending);
        final blockedLabel = _rangeLabel(blocked);

        final shellSubtitle = hasBlocked && !hasPending
            ? 'Review and manage blocked dates.'
            : 'Select a date range to block.';

        return OnboardingShell(
          title: 'Item availability',
          subtitle: shellSubtitle,
          headerDivider: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Your item, your schedule.',
                style: onboardingNunito(size: 22, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Your item is available unless you block dates.',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              _AvailabilityCalendarCard(
                month: _month,
                blocked: blocked,
                pending: pending,
                onPrevMonth: () => setState(() {
                  _month = DateTime(_month.year, _month.month - 1);
                }),
                onNextMonth: () => setState(() {
                  _month = DateTime(_month.year, _month.month + 1);
                }),
                onDayTap: _onDayTap,
              ),
              if (hasPending && pendingLabel != null) ...[
                const SizedBox(height: 12),
                _AvailabilitySummaryCard(
                  label: 'Selected dates',
                  summary: pendingLabel,
                  actionLabel: 'Clear selection',
                  onAction: _clearSelection,
                ),
              ],
              if (hasBlocked && blockedLabel != null && !hasPending) ...[
                const SizedBox(height: 12),
                _AvailabilitySummaryCard(
                  label: 'Blocked dates',
                  summary: blockedLabel,
                  actionLabel: 'Unblock dates',
                  onAction: () => _unblockAll(c),
                ),
              ],
              const SizedBox(height: 12),
              ListingHubRow(
                icon: Icons.event_note_outlined,
                title: 'Rental rules',
                value: 'Optional',
                onTap: () => Get.to(() => const ListingRentalRulesScreen()),
              ),
            ],
          ),
          bottomBar: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_savedBannerDays != null) ...[
                _AvailabilitySavedBanner(
                  days: _savedBannerDays!,
                  onUndo: () => _undoBlock(c),
                ),
                const SizedBox(height: 12),
              ],
              if (hasPending) ...[
                const SizedBox(height: 8),
                Text(
                  'Block these dates to save your changes.',
                  textAlign: TextAlign.center,
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                  ),
                ),
                const SizedBox(height: 12),
                OnboardingPrimaryButton(
                  label: 'Block ${pending.length} dates',
                  onPressed: () => _blockPending(c, blocked),
                ),
              ] else
                OnboardingPrimaryButton(
                  label: 'Done',
                  onPressed: () {
                    c.persistDraft();
                    Get.back();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _AvailabilityCalendarCard extends StatelessWidget {
  final DateTime month;
  final Set<String> blocked;
  final Set<String> pending;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<DateTime> onDayTap;

  const _AvailabilityCalendarCard({
    required this.month,
    required this.blocked,
    required this.pending,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onDayTap,
  });

  String _fmt(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final monthTitle = DateFormat('MMMM yyyy').format(month);
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPrevMonth,
                icon: Icon(Icons.chevron_left, color: AppColors.jebbyBlue),
              ),
              Expanded(
                child: Text(
                  monthTitle,
                  textAlign: TextAlign.center,
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: Icon(Icons.chevron_right, color: AppColors.jebbyBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: _dayLabels
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: onboardingNunito(
                        size: 12,
                        weight: FontWeight.w700,
                        color: AppColors.jebbyTextMuted,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: startWeekday - 1 + daysInMonth,
            itemBuilder: (_, i) {
              if (i < startWeekday - 1) return const SizedBox.shrink();
              final day = i - (startWeekday - 1) + 1;
              final date = DateTime(month.year, month.month, day);
              final key = _fmt(date);
              final isPast = _isPastAvailabilityDay(date);
              final isBlocked = blocked.contains(key);
              final isSelected = pending.contains(key);
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: isPast ? null : () => onDayTap(date),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isBlocked && !isPast ? _blockedDayFill : null,
                        border: isSelected
                            ? Border.all(color: AppColors.jebbyBlue, width: 2)
                            : null,
                      ),
                      child: Text(
                        '$day',
                        style: onboardingNunito(
                          size: 14,
                          weight: FontWeight.w700,
                          color: isPast
                              ? AppColors.jebbyTextMuted.withValues(alpha: 0.45)
                              : isBlocked
                                  ? AppColors.jebbyBlue
                                  : isSelected
                                      ? AppColors.jebbyBlue
                                      : AppColors.jebbyTextPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE3E6EC)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _AvailabilityLegendItem(
                label: 'Available',
                child: _LegendAvailableDot(),
              ),
              _AvailabilityLegendItem(
                label: 'Selected',
                child: _LegendSelectedDot(),
              ),
              _AvailabilityLegendItem(
                label: 'Blocked',
                child: _LegendBlockedDot(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailabilityLegendItem extends StatelessWidget {
  final String label;
  final Widget child;

  const _AvailabilityLegendItem({
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        child,
        const SizedBox(width: 6),
        Text(
          label,
          style: onboardingNunito(
            size: 12,
            weight: FontWeight.w600,
            color: AppColors.jebbyTextMuted,
          ),
        ),
      ],
    );
  }
}

class _LegendAvailableDot extends StatelessWidget {
  const _LegendAvailableDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFD8DCE6)),
      ),
    );
  }
}

class _LegendSelectedDot extends StatelessWidget {
  const _LegendSelectedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.jebbyBlue, width: 2),
      ),
    );
  }
}

class _LegendBlockedDot extends StatelessWidget {
  const _LegendBlockedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _blockedDayFill,
      ),
      child: Icon(Icons.remove, size: 12, color: AppColors.jebbyBlue),
    );
  }
}

class _AvailabilitySummaryCard extends StatelessWidget {
  final String label;
  final String summary;
  final String actionLabel;
  final VoidCallback onAction;

  const _AvailabilitySummaryCard({
    required this.label,
    required this.summary,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3E6EC)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: onboardingNunito(
                    size: 13,
                    weight: FontWeight.w600,
                    color: AppColors.jebbyTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary,
                  style: onboardingNunito(size: 16, weight: FontWeight.w800),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w800,
                color: AppColors.jebbyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilitySavedBanner extends StatelessWidget {
  final int days;
  final VoidCallback onUndo;

  const _AvailabilitySavedBanner({
    required this.days,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.earnerInfoBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.jebbySoftBlue),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: AppColors.jebbyBlue),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$days days blocked. Changes saved.',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w700,
                color: AppColors.jebbyTextPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: onUndo,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Undo',
              style: onboardingNunito(
                size: 14,
                weight: FontWeight.w800,
                color: AppColors.jebbyBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListingRentalRulesScreen extends StatefulWidget {
  const ListingRentalRulesScreen({super.key});

  @override
  State<ListingRentalRulesScreen> createState() => _ListingRentalRulesScreenState();
}

class _ListingRentalRulesScreenState extends State<ListingRentalRulesScreen> {
  late TextEditingController _notice;
  late TextEditingController _turnaround;
  late TextEditingController _minDays;
  late TextEditingController _maxDays;

  @override
  void initState() {
    super.initState();
    final r = Get.find<ListingFormController>().draft.rentalRules;
    _notice = TextEditingController(text: '${r.advanceNoticeHours}');
    _turnaround = TextEditingController(text: '${r.turnaroundHours}');
    _minDays = TextEditingController(text: r.minRentalDays?.toString() ?? '');
    _maxDays = TextEditingController(text: r.maxRentalDays?.toString() ?? '');
  }

  @override
  void dispose() {
    _notice.dispose();
    _turnaround.dispose();
    _minDays.dispose();
    _maxDays.dispose();
    super.dispose();
  }

  int? _optionalDays(TextEditingController controller) {
    final raw = controller.text.trim();
    if (raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ListingFormController>(
      builder: (c) {
        return OnboardingShell(
          title: 'Rental rules',
          subtitle: 'Set notice and rental-length rules.',
          headerDivider: true,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Set the timing.',
                style: onboardingNunito(size: 22, weight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Optional limits for future bookings.',
                style: onboardingNunito(
                  size: 14,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 20),
              const OnboardingFieldLabel('Advance notice (hours)', muted: true),
              OnboardingTextField(
                controller: _notice,
                hint: '24',
                fillColor: Colors.white,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const OnboardingFieldLabel(
                'Time after each return (hours)',
                muted: true,
              ),
              OnboardingTextField(
                controller: _turnaround,
                hint: '0',
                fillColor: Colors.white,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const OnboardingFieldLabel(
                'Minimum rental length (days)',
                muted: true,
              ),
              OnboardingTextField(
                controller: _minDays,
                hint: 'No custom minimum',
                fillColor: Colors.white,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              const OnboardingFieldLabel(
                'Maximum rental length (days)',
                muted: true,
              ),
              OnboardingTextField(
                controller: _maxDays,
                hint: 'No custom maximum',
                fillColor: Colors.white,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Text(
                'Length limits apply to future bookings. Leave length limits blank for no custom limit.',
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                  height: 1.35,
                ),
              ),
            ],
          ),
          bottomBar: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Existing bookings keep their agreed terms.',
                textAlign: TextAlign.center,
                style: onboardingNunito(
                  size: 13,
                  weight: FontWeight.w600,
                  color: AppColors.jebbyTextMuted,
                ),
              ),
              const SizedBox(height: 12),
              OnboardingPrimaryButton(
                label: 'Apply rules',
                onPressed: () {
                  c.draft.rentalRules = RentalRules(
                    advanceNoticeHours: int.tryParse(_notice.text.trim()) ?? 24,
                    turnaroundHours: int.tryParse(_turnaround.text.trim()) ?? 0,
                    minRentalDays: _optionalDays(_minDays),
                    maxRentalDays: _optionalDays(_maxDays),
                  );
                  c.markDirty();
                  c.persistDraft();
                  Get.back();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
