import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/seed_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart' show fmtDateShort;

class ScheduleScreen extends StatefulWidget {
  final AppData data;
  final void Function(ClassItem) onAdd;
  final void Function(String id, ClassItem updated) onUpdate;
  final void Function(String id) onDelete;
  const ScheduleScreen({super.key, required this.data, required this.onAdd, required this.onUpdate, required this.onDelete});

  @override
  State<ScheduleScreen> createState() => ScheduleScreenState();
}

class ScheduleScreenState extends State<ScheduleScreen> {
  int weekOffset = 0;
  late int dayIdx;

  @override
  void initState() {
    super.initState();
    dayIdx = DateTime.now().weekday % 7; // Sun=0..Sat=6
  }

  List<DateTime> get weekDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sunday = today.subtract(Duration(days: today.weekday % 7)).add(Duration(days: weekOffset * 7));
    return List.generate(7, (i) => sunday.add(Duration(days: i)));
  }

  /// Public entry point used by the FAB in RootShell.
  void openAddSheet() => _openSheet(null);

  void _openSheet(ClassItem? existing) {
    final sd = weekDates[dayIdx];
    _showEditor(context, existing: existing, defaultDate: sd);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final dates = weekDates;
    final selectedDate = dates[dayIdx];
    final selectedIso = isoDate(selectedDate);
    final selectedDayOfMonth = selectedDate.day;
    final monthYearLabel = DateFormat('MMMM y').format(dates[3]);
    final todayDow = DateTime.now().weekday % 7;
    final isCurrentWeek = weekOffset == 0;

    final dayClasses = widget.data.classes.where((cl) {
      if (cl.skipDates.contains(selectedIso)) return false;
      if (cl.type == 'once') return cl.date == selectedIso;
      if (cl.type == 'monthly') return cl.dayOfMonth == selectedDayOfMonth;
      return cl.day == dayIdx;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Schedule', style: bodyFont(size: 13, color: c.inkSoft)),
              const SizedBox(height: 2),
              Text(monthYearLabel, style: displayFont(size: 28, color: c.ink)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              IconButton(icon: const Icon(Icons.chevron_left), color: c.inkSoft, onPressed: () => setState(() => weekOffset--)),
              Expanded(
                child: Text(
                  isCurrentWeek ? 'This week' : '${fmtDateShort(isoDate(dates[0]))} – ${fmtDateShort(isoDate(dates[6]))}',
                  textAlign: TextAlign.center,
                  style: bodyFont(size: 12, color: c.inkSoft),
                ),
              ),
              IconButton(icon: const Icon(Icons.chevron_right), color: c.inkSoft, onPressed: () => setState(() => weekOffset++)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: List.generate(7, (i) {
              final active = i == dayIdx;
              final isToday = isCurrentWeek && i == todayDow;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => dayIdx = i),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: active ? strongInk : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(dayNamesShort[i], style: bodyFont(size: 11, weight: FontWeight.w600, color: active ? Colors.white : c.inkSoft)),
                        const SizedBox(height: 2),
                        Text(
                          '${dates[i].day}',
                          style: bodyFont(size: 13, weight: FontWeight.w600, color: active ? Colors.white : (isToday ? teal : c.ink)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              if (dayClasses.isEmpty)
                EmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: 'Nothing scheduled',
                  body: 'Nothing on ${dayNamesFull[dayIdx]}, $monthYearLabel. Tap + to add a class or activity.',
                )
              else
                ...dayClasses.map((cl) => _classCard(context, c, cl)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _classCard(BuildContext context, AppColors c, ClassItem cl) {
    final tint = swatchTint(cl.color);
    final solid = swatchSolid(cl.color);
    final deep = swatchDeep(cl.color);
    final recurrenceLabel = {'once': 'One-time', 'weekly': 'Weekly', 'monthly': 'Monthly'};

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 62,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(_fmtTime(cl.start), textAlign: TextAlign.right, style: bodyFont(size: 11.5, color: c.inkSoft)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Column(
                children: [
                  Container(margin: const EdgeInsets.only(top: 17), width: 9, height: 9, decoration: BoxDecoration(color: solid, shape: BoxShape.circle)),
                  Expanded(child: Container(width: 1, color: c.lineSoft)),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => _openSheet(cl),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(color: tint, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 6,
                              children: [
                                Text(cl.subject, style: bodyFont(size: 14.5, weight: FontWeight.w600, color: deep)),
                                if (cl.kind == 'activity') _miniTag('Activity', deep),
                                if (cl.type != 'weekly') _miniTag(recurrenceLabel[cl.type] ?? '', deep),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(children: [
                              Icon(Icons.access_time, size: 11, color: deep.withOpacity(0.85)),
                              const SizedBox(width: 4),
                              Text('${_fmtTime(cl.start)} – ${_fmtTime(cl.end)}', style: bodyFont(size: 12, color: deep.withOpacity(0.85))),
                            ]),
                            const SizedBox(height: 2),
                            Row(children: [
                              Icon(Icons.place_outlined, size: 11, color: deep.withOpacity(0.85)),
                              const SizedBox(width: 4),
                              Expanded(child: Text(cl.location.isEmpty ? 'No location set' : cl.location, style: bodyFont(size: 12, color: deep.withOpacity(0.85)))),
                            ]),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onDelete(cl.id),
                        child: Icon(Icons.delete_outline, size: 18, color: deep.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.55), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: bodyFont(size: 10, weight: FontWeight.w600, color: color)),
    );
  }

  String _fmtTime(String hhmm) {
    final parts = hhmm.split(':');
    int h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:$m $period';
  }

  void _showEditor(BuildContext context, {ClassItem? existing, required DateTime defaultDate}) {
    final subjectCtl = TextEditingController(text: existing?.subject ?? '');
    final locationCtl = TextEditingController(text: existing?.location ?? '');
    String kind = existing?.kind ?? 'class';
    String type = existing?.type ?? 'weekly';
    int day = existing?.day ?? defaultDate.weekday % 7;
    int dayOfMonth = existing?.dayOfMonth ?? defaultDate.day;
    DateTime onceDate = existing?.date != null ? DateTime.parse(existing!.date!) : defaultDate;
    TimeOfDay start = _parseTime(existing?.start ?? '09:00');
    TimeOfDay end = _parseTime(existing?.end ?? '10:00');
    String color = existing?.color ?? 'teal';
    final occurrenceIso = isoDate(defaultDate);
    List<String> skipDates = List.from(existing?.skipDates ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).extension<AppColors>()!.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final c = Theme.of(ctx).extension<AppColors>()!;
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(color: c.line, borderRadius: BorderRadius.circular(2)),
                          ),
                        ),
                        Text(existing != null ? 'Edit item' : 'Add to schedule', style: displayFont(size: 20, color: c.ink)),
                        const SizedBox(height: 14),
                        LabeledTextField(label: 'Subject', controller: subjectCtl, hint: 'e.g. Organic Chemistry'),

                        Text('Type', style: bodyFont(size: 12.5, color: c.inkSoft)),
                        const SizedBox(height: 6),
                        SegmentedPicker(
                          values: const ['class', 'activity'],
                          labels: const ['Class', 'Activity'],
                          selected: kind,
                          onChanged: (v) => setSheetState(() => kind = v),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 6, bottom: 12),
                          child: Text(
                            kind == 'class'
                                ? 'Counts toward your semester class load in Profile.'
                                : "A personal or daily item — won't be counted as a class.",
                            style: bodyFont(size: 11, color: c.inkSoft),
                          ),
                        ),

                        Text('Repeats', style: bodyFont(size: 12.5, color: c.inkSoft)),
                        const SizedBox(height: 6),
                        SegmentedPicker(
                          values: const ['once', 'weekly', 'monthly'],
                          labels: const ['One-time', 'Weekly', 'Monthly'],
                          selected: type,
                          onChanged: (v) => setSheetState(() => type = v),
                        ),
                        const SizedBox(height: 12),

                        if (type == 'once')
                          LabeledDateField(label: 'Date', value: onceDate, onChanged: (d) => setSheetState(() => onceDate = d)),
                        if (type == 'weekly')
                          LabeledDropdown<int>(
                            label: 'Day',
                            value: day,
                            options: List.generate(7, (i) => i),
                            labelBuilder: (i) => dayNamesFull[i],
                            onChanged: (v) => setSheetState(() => day = v),
                          ),
                        if (type == 'monthly')
                          LabeledDropdown<int>(
                            label: 'Day of month',
                            value: dayOfMonth,
                            options: List.generate(31, (i) => i + 1),
                            labelBuilder: (i) => '$i',
                            onChanged: (v) => setSheetState(() => dayOfMonth = v),
                          ),

                        Row(
                          children: [
                            Expanded(child: LabeledTimeField(label: 'Start', value: start, onChanged: (t) => setSheetState(() => start = t))),
                            const SizedBox(width: 10),
                            Expanded(child: LabeledTimeField(label: 'End', value: end, onChanged: (t) => setSheetState(() => end = t))),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LabeledTextField(label: 'Location', controller: locationCtl, hint: 'e.g. Wilson Hall 204'),

                        Text('Color tag', style: bodyFont(size: 12.5, color: c.inkSoft)),
                        const SizedBox(height: 6),
                        Row(
                          children: classColors.map((cName) {
                            final active = color == cName;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setSheetState(() => color = cName),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: swatchSolid(cName),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: active ? c.ink : Colors.transparent, width: 2),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        if (existing != null && type != 'once') ...[
                          const SizedBox(height: 16),
                          Divider(color: c.lineSoft),
                          const SizedBox(height: 8),
                          Text('Holiday or one-off skip', style: bodyFont(size: 12.5, color: c.inkSoft)),
                          const SizedBox(height: 6),
                          if (skipDates.isNotEmpty)
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: skipDates.map((d) {
                                return Container(
                                  padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
                                  decoration: BoxDecoration(color: coralTint, borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(fmtDateShort(d), style: bodyFont(size: 11.5, weight: FontWeight.w600, color: coralDeep)),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          final updated = skipDates.where((x) => x != d).toList();
                                          setSheetState(() => skipDates = updated);
                                          widget.onUpdate(existing.id, existing.copyWith(skipDates: updated));
                                        },
                                        child: Icon(Icons.close, size: 13, color: coralDeep.withOpacity(0.75)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: skipDates.contains(occurrenceIso)
                                  ? null
                                  : () {
                                      final updated = [...skipDates, occurrenceIso];
                                      widget.onUpdate(existing.id, existing.copyWith(skipDates: updated));
                                      Navigator.of(ctx).pop();
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: c.ink,
                                side: BorderSide(color: c.line),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: Text(
                                skipDates.contains(occurrenceIso) ? 'Already skipped on ${fmtDateShort(occurrenceIso)}' : 'Skip just this occurrence (${fmtDateShort(occurrenceIso)})',
                                style: bodyFont(size: 13, weight: FontWeight.w600, color: c.ink),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: existing != null ? 'Save changes' : 'Add',
                          onPressed: () {
                            if (subjectCtl.text.trim().isEmpty) return;
                            final item = ClassItem(
                              id: existing?.id ?? genId(),
                              subject: subjectCtl.text.trim(),
                              kind: kind,
                              type: type,
                              day: day,
                              dayOfMonth: dayOfMonth,
                              date: isoDate(onceDate),
                              start: _fmtTimeOfDay(start),
                              end: _fmtTimeOfDay(end),
                              location: locationCtl.text.trim(),
                              color: color,
                              skipDates: skipDates,
                            );
                            if (existing != null) {
                              widget.onUpdate(existing.id, item);
                            } else {
                              widget.onAdd(item);
                            }
                            Navigator.of(ctx).pop();
                          },
                        ),
                        if (existing != null) ...[
                          const SizedBox(height: 10),
                          DangerButton(
                            label: 'Delete',
                            onPressed: () {
                              widget.onDelete(existing.id);
                              Navigator.of(ctx).pop();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  String _fmtTimeOfDay(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
