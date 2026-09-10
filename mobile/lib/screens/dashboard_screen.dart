import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

String formatRupiah(num amount) {
  final f = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);
  return f.format(amount);
}

String fmtDateShort(String iso) {
  final d = DateTime.parse(iso);
  return DateFormat('MMM d').format(d);
}

class DashboardScreen extends StatelessWidget {
  final AppData data;
  final ValueChanged<int> onGoToTab;
  const DashboardScreen({super.key, required this.data, required this.onGoToTab});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final now = DateTime.now();
    final dow = now.weekday % 7; // Dart: Mon=1..Sun=7 -> convert to Sun=0..Sat=6
    final todayIsoStr = todayIso();
    final todayOfMonth = now.day;

    final todaysClasses = data.classes.where((cl) => (cl.kind) == 'class').where((cl) {
      if (cl.skipDates.contains(todayIsoStr)) return false;
      if (cl.type == 'once') return cl.date == todayIsoStr;
      if (cl.type == 'monthly') return cl.dayOfMonth == todayOfMonth;
      return cl.day == dow;
    }).toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    final pending = data.tasks.where((t) => t.status == 'pending').toList();
    final overdue = pending.where((t) => daysUntil(t.dueDate) < 0).toList();
    final dueSoon = pending.where((t) => daysUntil(t.dueDate) >= 0 && daysUntil(t.dueDate) <= 3).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    final monthKey = todayIsoStr.substring(0, 7);
    final spentThisMonth = data.expenses.where((e) => e.date.startsWith(monthKey)).fold<double>(0, (s, e) => s + e.amount);
    final limit = data.monthlyBudget <= 0 ? 1 : data.monthlyBudget;
    final pct = (spentThisMonth / limit * 100).clamp(0, 100).round();
    final overBudget = spentThisMonth > limit;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, MMMM d, y').format(now), style: bodyFont(size: 13, color: c.inkSoft)),
          const SizedBox(height: 2),
          Text('Hi, ${data.profile.name.split(' ').first}', style: displayFont(size: 28, color: c.ink)),
          const SizedBox(height: 22),

          SectionLabel(text: "Today's classes"),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
            child: todaysClasses.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('No classes today. Enjoy the open schedule.', style: bodyFont(size: 13.5, color: c.inkSoft)),
                  )
                : Column(
                    children: todaysClasses.map((cl) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineSoft))),
                        child: Row(
                          children: [
                            Container(width: 4, height: 36, decoration: BoxDecoration(color: swatchSolid(cl.color), borderRadius: BorderRadius.circular(2))),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(cl.subject, style: bodyFont(size: 14.5, weight: FontWeight.w600, color: c.ink)),
                                  const SizedBox(height: 2),
                                  Row(children: [
                                    Icon(Icons.place_outlined, size: 11, color: c.inkSoft),
                                    const SizedBox(width: 4),
                                    Text(cl.location, style: bodyFont(size: 12.5, color: c.inkSoft)),
                                  ]),
                                ],
                              ),
                            ),
                            Text(_fmtTime(cl.start), style: bodyFont(size: 12.5, color: c.inkSoft)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 22),

          SectionLabel(text: 'Upcoming deadlines', actionLabel: 'View tasks', onAction: () => onGoToTab(2)),
          Container(
            decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
            child: (overdue.isEmpty && dueSoon.isEmpty)
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text('Nothing due in the next few days.', style: bodyFont(size: 13.5, color: c.inkSoft)),
                  )
                : Column(
                    children: [
                      ...overdue.map((t) => _deadlineRow(c, t, isOverdue: true)),
                      ...dueSoon.map((t) => _deadlineRow(c, t, isOverdue: false)),
                    ],
                  ),
          ),
          const SizedBox(height: 22),

          SectionLabel(text: "This month's spending", actionLabel: 'View finance', onAction: () => onGoToTab(3)),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: BoxDecoration(color: c.paperRaised, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.lineSoft)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(formatRupiah(spentThisMonth), style: displayFont(size: 24, color: overBudget ? coral : c.ink)),
                    Text('of ${formatRupiah(limit)} budget', style: bodyFont(size: 12.5, color: c.inkSoft)),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 7,
                    backgroundColor: c.lineSoft,
                    valueColor: AlwaysStoppedAnimation(overBudget ? coral : teal),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  overBudget ? '${formatRupiah(spentThisMonth - limit)} over budget' : '${formatRupiah(limit - spentThisMonth)} remaining',
                  style: bodyFont(size: 12, color: c.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _deadlineRow(AppColors c, TaskItem t, {required bool isOverdue}) {
    final d = daysUntil(t.dueDate);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineSoft))),
      child: Row(
        children: [
          Icon(isOverdue ? Icons.error_outline : Icons.schedule, size: 15, color: isOverdue ? coral : c.inkSoft),
          const SizedBox(width: 10),
          Expanded(child: Text(t.title, style: bodyFont(size: 13.5, color: c.ink))),
          Pill(text: isOverdue ? 'Overdue' : (d == 0 ? 'Today' : fmtDateShort(t.dueDate)), tone: isOverdue ? 'coral' : (d == 0 ? 'amber' : 'teal')),
        ],
      ),
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
}
