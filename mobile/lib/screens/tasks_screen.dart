import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/seed_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart' show fmtDateShort;

class TasksScreen extends StatefulWidget {
  final AppData data;
  final void Function(TaskItem) onAdd;
  final void Function(String id, TaskItem updated) onUpdate;
  final void Function(String id) onToggle;
  final void Function(String id) onDelete;
  const TasksScreen({super.key, required this.data, required this.onAdd, required this.onUpdate, required this.onToggle, required this.onDelete});

  @override
  State<TasksScreen> createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  String filter = 'pending';

  void openAddSheet() => _openSheet(null);

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    const priorityRank = {'high': 0, 'medium': 1, 'low': 2};

    var list = widget.data.tasks.where((t) => filter == 'all' ? true : t.status == filter).toList();
    list.sort((a, b) {
      if (filter == 'done') return b.dueDate.compareTo(a.dueDate);
      final byDate = a.dueDate.compareTo(b.dueDate);
      if (byDate != 0) return byDate;
      return (priorityRank[a.priority] ?? 1).compareTo(priorityRank[b.priority] ?? 1);
    });

    const priorityTone = {'high': 'coral', 'medium': 'amber', 'low': 'teal'};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tasks', style: bodyFont(size: 13, color: c.inkSoft)),
              const SizedBox(height: 2),
              Text('To do', style: displayFont(size: 28, color: c.ink)),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _filterChip(c, 'pending', 'Pending'),
              const SizedBox(width: 6),
              _filterChip(c, 'done', 'Done'),
              const SizedBox(width: 6),
              _filterChip(c, 'all', 'All'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            children: [
              if (list.isEmpty)
                const EmptyState(icon: Icons.check_box_outlined, title: 'All clear', body: 'Nothing here right now. Tap + to add a task.')
              else
                ...list.map((t) {
                  final d = daysUntil(t.dueDate);
                  final overdue = t.status == 'pending' && d < 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineSoft))),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () => widget.onToggle(t.id),
                          child: Container(
                            width: 21,
                            height: 21,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: t.status == 'done' ? teal : Colors.transparent,
                              border: Border.all(color: t.status == 'done' ? teal : c.line, width: 1.5),
                            ),
                            child: t.status == 'done' ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
                          ),
                        ),
                        const SizedBox(width: 11),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openSheet(t),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t.title,
                                  style: bodyFont(
                                    size: 14.5,
                                    weight: FontWeight.w500,
                                    color: t.status == 'done' ? c.inkSoft : c.ink,
                                  ).copyWith(decoration: t.status == 'done' ? TextDecoration.lineThrough : TextDecoration.none),
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Pill(text: t.category, tone: 'ink'),
                                    if (t.status == 'pending') Pill(text: t.priority, tone: priorityTone[t.priority] ?? 'teal'),
                                    Text(
                                      overdue ? 'Overdue · ${fmtDateShort(t.dueDate)}' : fmtDateShort(t.dueDate),
                                      style: bodyFont(size: 11.5, weight: overdue ? FontWeight.w600 : FontWeight.w400, color: overdue ? coral : c.inkSoft),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, size: 18, color: c.inkSoft.withOpacity(0.55)),
                          onPressed: () => widget.onDelete(t.id),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(AppColors c, String key, String label) {
    final active = filter == key;
    return GestureDetector(
      onTap: () => setState(() => filter = key),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
        decoration: BoxDecoration(
          color: active ? strongInk : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? c.ink : c.line),
        ),
        child: Text(label, style: bodyFont(size: 12.5, weight: FontWeight.w600, color: active ? Colors.white : c.inkSoft)),
      ),
    );
  }

  void _openSheet(TaskItem? existing) {
    final titleCtl = TextEditingController(text: existing?.title ?? '');
    String category = existing?.category ?? 'Assignment';
    String priority = existing?.priority ?? 'medium';
    DateTime dueDate = existing != null ? DateTime.parse(existing.dueDate) : DateTime.parse(todayIso());

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
                        Text(existing != null ? 'Edit task' : 'Add task', style: displayFont(size: 20, color: c.ink)),
                        const SizedBox(height: 14),
                        LabeledTextField(label: 'Title', controller: titleCtl, hint: 'e.g. Finish lab report'),
                        LabeledDropdown<String>(
                          label: 'Category',
                          value: category,
                          options: taskCategories,
                          labelBuilder: (s) => s,
                          onChanged: (v) => setSheetState(() => category = v),
                        ),
                        Text('Priority', style: bodyFont(size: 12.5, color: c.inkSoft)),
                        const SizedBox(height: 6),
                        SegmentedPicker(
                          values: const ['low', 'medium', 'high'],
                          labels: const ['Low', 'Medium', 'High'],
                          selected: priority,
                          onChanged: (v) => setSheetState(() => priority = v),
                        ),
                        const SizedBox(height: 12),
                        LabeledDateField(label: 'Due date', value: dueDate, onChanged: (d) => setSheetState(() => dueDate = d)),
                        const SizedBox(height: 6),
                        PrimaryButton(
                          label: existing != null ? 'Save changes' : 'Add task',
                          onPressed: () {
                            if (titleCtl.text.trim().isEmpty) return;
                            if (existing != null) {
                              widget.onUpdate(
                                existing.id,
                                existing.copyWith(title: titleCtl.text.trim(), category: category, priority: priority, dueDate: isoDate(dueDate)),
                              );
                            } else {
                              widget.onAdd(TaskItem(
                                id: genId(),
                                title: titleCtl.text.trim(),
                                category: category,
                                priority: priority,
                                dueDate: isoDate(dueDate),
                                status: 'pending',
                              ));
                            }
                            Navigator.of(ctx).pop();
                          },
                        ),
                        if (existing != null) ...[
                          const SizedBox(height: 10),
                          DangerButton(
                            label: 'Delete task',
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
}
