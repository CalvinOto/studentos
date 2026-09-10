import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/seed_data.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart' show fmtDateShort, formatRupiah;

class FinanceScreen extends StatefulWidget {
  final AppData data;
  final void Function(ExpenseItem) onAdd;
  final void Function(String id, ExpenseItem updated) onUpdate;
  final void Function(String id) onDelete;
  final void Function(double) onUpdateBudget;
  const FinanceScreen({
    super.key,
    required this.data,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
    required this.onUpdateBudget,
  });

  @override
  State<FinanceScreen> createState() => FinanceScreenState();
}

class FinanceScreenState extends State<FinanceScreen> {
  void openAddSheet() => _openExpenseSheet(null);

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final monthKey = todayIso().substring(0, 7);
    final monthExpenses = widget.data.expenses.where((e) => e.date.startsWith(monthKey)).toList()..sort((a, b) => b.date.compareTo(a.date));
    final spent = monthExpenses.fold<double>(0, (s, e) => s + e.amount);
    final limit = widget.data.monthlyBudget <= 0 ? 1 : widget.data.monthlyBudget;
    final remaining = limit - spent;
    final pct = (spent / limit * 100).clamp(0, 100).round();

    final byCategory = expenseCategories
        .map((cat) => MapEntry(cat, monthExpenses.where((e) => e.category == cat).fold<double>(0, (s, e) => s + e.amount)))
        .where((e) => e.value > 0)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCat = byCategory.isEmpty ? 1.0 : byCategory.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      children: [
        Text('Finance', style: bodyFont(size: 13, color: c.inkSoft)),
        const SizedBox(height: 2),
        Text('Budget', style: displayFont(size: 28, color: c.ink)),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(color: strongInk, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spent this month', style: bodyFont(size: 12, color: const Color(0xFFB9C2CA))),
                      const SizedBox(height: 2),
                      Text(formatRupiah(spent), style: displayFont(size: 30, color: Colors.white)),
                    ],
                  ),
                  OutlinedButton(
                    onPressed: () => _openBudgetSheet(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF47555F)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    ),
                    child: Text('Edit budget', style: bodyFont(size: 11.5, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 7,
                  backgroundColor: const Color(0xFF3A4753),
                  valueColor: AlwaysStoppedAnimation(remaining < 0 ? coral : teal),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                remaining < 0 ? '${formatRupiah(-remaining)} over your ${formatRupiah(limit)} budget' : '${formatRupiah(remaining)} left of ${formatRupiah(limit)}',
                style: bodyFont(size: 12, color: const Color(0xFFB9C2CA)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (byCategory.isNotEmpty) ...[
          SectionLabel(text: 'By category'),
          ...byCategory.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key, style: bodyFont(size: 12.5, weight: FontWeight.w500, color: c.ink)),
                      Text(formatRupiah(entry.value), style: bodyFont(size: 12.5, color: c.inkSoft)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(value: entry.value / maxCat, minHeight: 5, backgroundColor: c.lineSoft, valueColor: const AlwaysStoppedAnimation(teal)),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
        ],

        SectionLabel(text: 'Transactions'),
        Container(
          decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
          child: monthExpenses.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text('No expenses logged yet this month.', style: bodyFont(size: 13.5, color: c.inkSoft)),
                )
              : Column(
                  children: monthExpenses.map((e) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineSoft))),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openExpenseSheet(e),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(e.note.isEmpty ? e.category : e.note, style: bodyFont(size: 14, weight: FontWeight.w500, color: c.ink)),
                                  const SizedBox(height: 2),
                                  Text('${e.category} · ${fmtDateShort(e.date)}', style: bodyFont(size: 11.5, color: c.inkSoft)),
                                ],
                              ),
                            ),
                          ),
                          Text(formatRupiah(e.amount), style: bodyFont(size: 14, weight: FontWeight.w600, color: c.ink)),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 16, color: c.inkSoft.withOpacity(0.55)),
                            onPressed: () => widget.onDelete(e.id),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  void _openBudgetSheet(BuildContext context) {
    final ctl = TextEditingController(text: widget.data.monthlyBudget.toStringAsFixed(0));
    showFormSheet(
      context: context,
      title: 'Monthly budget',
      submitLabel: 'Save budget',
      children: [LabeledTextField(label: 'Monthly limit (Rp)', controller: ctl, keyboardType: TextInputType.number)],
      onSubmit: () {
        final v = double.tryParse(ctl.text);
        if (v == null || v <= 0) return;
        widget.onUpdateBudget(v);
        Navigator.of(context).pop();
      },
    );
  }

  void _openExpenseSheet(ExpenseItem? existing) {
    final amountCtl = TextEditingController(text: existing != null ? existing.amount.toStringAsFixed(0) : '');
    final noteCtl = TextEditingController(text: existing?.note ?? '');
    String category = existing?.category ?? 'Food';
    DateTime date = existing != null ? DateTime.parse(existing.date) : DateTime.parse(todayIso());

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
                        Text(existing != null ? 'Edit expense' : 'Add expense', style: displayFont(size: 20, color: c.ink)),
                        const SizedBox(height: 14),
                        LabeledTextField(label: 'Amount (Rp)', controller: amountCtl, hint: 'e.g. 25000', keyboardType: TextInputType.number),
                        LabeledDropdown<String>(
                          label: 'Category',
                          value: category,
                          options: expenseCategories,
                          labelBuilder: (s) => s,
                          onChanged: (v) => setSheetState(() => category = v),
                        ),
                        LabeledDateField(label: 'Date', value: date, onChanged: (d) => setSheetState(() => date = d)),
                        LabeledTextField(label: 'Note (optional)', controller: noteCtl, hint: 'e.g. Coffee with study group'),
                        const SizedBox(height: 6),
                        PrimaryButton(
                          label: existing != null ? 'Save changes' : 'Add expense',
                          onPressed: () {
                            final amt = double.tryParse(amountCtl.text);
                            if (amt == null || amt <= 0) return;
                            if (existing != null) {
                              widget.onUpdate(existing.id, existing.copyWith(amount: amt, category: category, date: isoDate(date), note: noteCtl.text.trim()));
                            } else {
                              widget.onAdd(ExpenseItem(id: genId(), amount: amt, category: category, date: isoDate(date), note: noteCtl.text.trim()));
                            }
                            Navigator.of(ctx).pop();
                          },
                        ),
                        if (existing != null) ...[
                          const SizedBox(height: 10),
                          DangerButton(
                            label: 'Delete expense',
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
