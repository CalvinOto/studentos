import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  final Profile profile;
  final ValueChanged<Profile> onSave;
  const EditProfileScreen({super.key, required this.profile, required this.onSave});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController nameCtl;
  late TextEditingController universityCtl;
  late TextEditingController majorCtl;
  late String year;

  static const years = ['Freshman', 'Sophomore', 'Junior', 'Senior', 'Graduate'];

  @override
  void initState() {
    super.initState();
    nameCtl = TextEditingController(text: widget.profile.name);
    universityCtl = TextEditingController(text: widget.profile.university);
    majorCtl = TextEditingController(text: widget.profile.major);
    year = widget.profile.year;
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    return Scaffold(
      backgroundColor: c.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 20, 6),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.chevron_left, color: c.ink), onPressed: () => Navigator.of(context).pop()),
                  Text('Edit profile', style: displayFont(size: 22, color: c.ink)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LabeledTextField(label: 'Name', controller: nameCtl),
                    LabeledTextField(label: 'University', controller: universityCtl),
                    LabeledTextField(label: 'Major', controller: majorCtl),
                    LabeledDropdown<String>(
                      label: 'Year',
                      value: year,
                      options: years,
                      labelBuilder: (s) => s,
                      onChanged: (v) => setState(() => year = v),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Save changes',
                      onPressed: () {
                        widget.onSave(Profile(name: nameCtl.text.trim(), university: universityCtl.text.trim(), major: majorCtl.text.trim(), year: year));
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: c.inkSoft,
                          side: BorderSide(color: c.line),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Cancel', style: bodyFont(size: 14, weight: FontWeight.w600, color: c.inkSoft)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
