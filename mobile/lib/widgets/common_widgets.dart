import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

TextStyle displayFont({double size = 20, FontWeight weight = FontWeight.w600, Color? color}) =>
    GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color);

TextStyle bodyFont({double size = 14, FontWeight weight = FontWeight.w400, Color? color}) =>
    GoogleFonts.ibmPlexSans(fontSize: size, fontWeight: weight, color: color);

class Pill extends StatelessWidget {
  final String text;
  final String tone; // teal | amber | coral | ink
  const Pill({super.key, required this.text, this.tone = 'teal'});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: swatchTint(tone), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: bodyFont(size: 11.5, weight: FontWeight.w600, color: swatchDeep(tone))),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const SectionLabel({super.key, required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: bodyFont(size: 13, weight: FontWeight.w600, color: c.ink)),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(actionLabel!, style: bodyFont(size: 12, weight: FontWeight.w600, color: teal)),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const EmptyState({super.key, required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      child: Column(
        children: [
          Icon(icon, size: 30, color: c.inkSoft.withOpacity(0.5)),
          const SizedBox(height: 10),
          Text(title, style: displayFont(size: 17, color: c.ink)),
          const SizedBox(height: 4),
          Text(body, textAlign: TextAlign.center, style: bodyFont(size: 13, color: c.inkSoft)),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String tone;
  const MetricCard({super.key, required this.icon, required this.label, required this.value, this.tone = 'teal'});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: c.paperRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.lineSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(color: swatchTint(tone), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: swatchDeep(tone)),
          ),
          const SizedBox(height: 9),
          Text(value, style: displayFont(size: 19, color: c.ink)),
          const SizedBox(height: 1),
          Text(label, style: bodyFont(size: 11.5, color: c.inkSoft)),
        ],
      ),
    );
  }
}

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  const LabeledTextField({super.key, required this.label, required this.controller, this.hint, this.keyboardType, this.obscureText = false});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyFont(size: 12.5, color: c.inkSoft)),
          const SizedBox(height: 5),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            style: bodyFont(size: 14.5, color: c.ink),
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: c.paperRaised,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c.line)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: teal)),
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledDateField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  const LabeledDateField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyFont(size: 12.5, color: c.inkSoft)),
          const SizedBox(height: 5),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: value,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) onChanged(picked);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: c.paperRaised,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: c.line),
              ),
              child: Text(
                '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}',
                style: bodyFont(size: 14.5, color: c.ink),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LabeledTimeField extends StatelessWidget {
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onChanged;
  const LabeledTimeField({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: bodyFont(size: 12.5, color: c.inkSoft)),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: () async {
            final picked = await showTimePicker(context: context, initialTime: value);
            if (picked != null) onChanged(picked);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: c.paperRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.line),
            ),
            child: Text(value.format(context), style: bodyFont(size: 14.5, color: c.ink)),
          ),
        ),
      ],
    );
  }
}

class LabeledDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> options;
  final String Function(T) labelBuilder;
  final ValueChanged<T> onChanged;
  const LabeledDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: bodyFont(size: 12.5, color: c.inkSoft)),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: c.paperRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: c.line),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                style: bodyFont(size: 14.5, color: c.ink),
                dropdownColor: c.paperRaised,
                items: options
                    .map((o) => DropdownMenuItem<T>(value: o, child: Text(labelBuilder(o), style: bodyFont(size: 14.5, color: c.ink))))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A row of equal-width selectable segments, used for priority/type/recurrence pickers.
class SegmentedPicker extends StatelessWidget {
  final List<String> values;
  final List<String> labels;
  final String selected;
  final ValueChanged<String> onChanged;
  const SegmentedPicker({super.key, required this.values, required this.labels, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Row(
      children: List.generate(values.length, (i) {
        final v = values[i];
        final active = v == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == values.length - 1 ? 0 : 8),
            child: GestureDetector(
              onTap: () => onChanged(v),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? strongInk : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: active ? c.ink : c.line),
                ),
                child: Text(labels[i], style: bodyFont(size: 12.5, weight: FontWeight.w600, color: active ? Colors.white : c.inkSoft)),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const PrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: strongInk,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        child: Text(label, style: bodyFont(size: 14.5, weight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

class DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const DangerButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: coral,
          side: const BorderSide(color: coral),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(label, style: bodyFont(size: 13.5, weight: FontWeight.w600, color: coral)),
      ),
    );
  }
}

/// Shows a modal bottom sheet with a title, scrollable body, and a primary submit button.
Future<void> showFormSheet({
  required BuildContext context,
  required String title,
  required List<Widget> children,
  required String submitLabel,
  required VoidCallback onSubmit,
}) {
  final c = Theme.of(context).extension<AppColors>()!;
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: c.paper,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (ctx) {
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
                  Text(title, style: displayFont(size: 20, color: c.ink)),
                  const SizedBox(height: 14),
                  ...children,
                  const SizedBox(height: 6),
                  PrimaryButton(
                    label: submitLabel,
                    onPressed: () {
                      onSubmit();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
