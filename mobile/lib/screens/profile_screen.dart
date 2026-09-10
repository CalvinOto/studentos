import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_colors.dart';
import '../widgets/common_widgets.dart';
import 'dashboard_screen.dart' show formatRupiah;
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final AppData data;
  final ValueChanged<Profile> onUpdateProfile;
  final ValueChanged<String> onUpdateTheme; // 'light' | 'dark'
  final VoidCallback onLogout;
  const ProfileScreen({
    super.key,
    required this.data,
    required this.onUpdateProfile,
    required this.onUpdateTheme,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Map<String, bool> notif = {'classes': true, 'deadlines': true, 'budget': false};

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final data = widget.data;
    final initials = data.profile.name.trim().isEmpty
        ? '?'
        : data.profile.name.trim().split(RegExp(r'\s+')).map((s) => s[0]).take(2).join().toUpperCase();

    final weeklyClassCount = data.classes.where((cl) => cl.kind == 'class' && cl.type == 'weekly').length;
    final tasksDone = data.tasks.where((t) => t.status == 'done').length;
    final tasksPending = data.tasks.where((t) => t.status == 'pending').length;
    final monthKey = todayIso().substring(0, 7);
    final spentThisMonth = data.expenses.where((e) => e.date.startsWith(monthKey)).fold<double>(0, (s, e) => s + e.amount);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 100),
      children: [
        Text('Profile', style: bodyFont(size: 13, color: c.inkSoft)),
        const SizedBox(height: 2),
        Text('You', style: displayFont(size: 28, color: c.ink)),
        const SizedBox(height: 20),

        Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(color: teal, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Text(initials, style: displayFont(size: 20, color: Colors.white)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data.profile.name, style: displayFont(size: 19, color: c.ink)),
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.school_outlined, size: 13, color: c.inkSoft),
                    const SizedBox(width: 5),
                    Expanded(child: Text('${data.profile.year} · ${data.profile.major}', style: bodyFont(size: 12.5, color: c.inkSoft))),
                  ]),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => EditProfileScreen(profile: data.profile, onSave: widget.onUpdateProfile),
                ));
              },
              icon: const Icon(Icons.edit_outlined, size: 12),
              label: Text('Edit', style: bodyFont(size: 12.5, weight: FontWeight.w600, color: c.ink)),
              style: OutlinedButton.styleFrom(
                foregroundColor: c.ink,
                side: BorderSide(color: c.line),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        SectionLabel(text: 'Your semester at a glance'),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
          children: [
            MetricCard(icon: Icons.menu_book_outlined, label: 'Classes / week', value: '$weeklyClassCount', tone: 'teal'),
            MetricCard(icon: Icons.check_box_outlined, label: 'Tasks completed', value: '$tasksDone', tone: 'amber'),
            MetricCard(icon: Icons.schedule, label: 'Tasks open', value: '$tasksPending', tone: 'coral'),
            MetricCard(icon: Icons.account_balance_wallet_outlined, label: 'Spent this month', value: formatRupiah(spentThisMonth), tone: 'ink'),
          ],
        ),
        const SizedBox(height: 22),

        SectionLabel(text: 'Personal information'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: c.paperRaised, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.lineSoft)),
          child: Column(
            children: [
              _infoRow(c, 'University', data.profile.university),
              _infoRow(c, 'Major', data.profile.major),
              _infoRow(c, 'Year', data.profile.year, last: true),
            ],
          ),
        ),
        const SizedBox(height: 22),

        SectionLabel(text: 'Notifications'),
        Container(
          decoration: BoxDecoration(color: c.paperRaised, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.lineSoft)),
          child: Column(
            children: [
              _notifRow(c, 'classes', 'Class reminders', '15 minutes before each class'),
              _notifRow(c, 'deadlines', 'Deadline alerts', 'Tasks due today or overdue'),
              _notifRow(c, 'budget', 'Budget warnings', "When you're close to your limit", last: true),
            ],
          ),
        ),
        const SizedBox(height: 22),

        SectionLabel(text: 'Appearance'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: c.paperRaised, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.lineSoft)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: bodyFont(size: 13.5, weight: FontWeight.w500, color: c.ink)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(
                  child: _themeButton(context, c, 'light', Icons.wb_sunny_outlined, 'Light'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _themeButton(context, c, 'dark', Icons.nightlight_outlined, 'Dark'),
                ),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 22),

        SectionLabel(text: 'About'),
        Container(
          decoration: BoxDecoration(color: c.paperRaised, borderRadius: BorderRadius.circular(14), border: Border.all(color: c.lineSoft)),
          child: Column(
            children: [
              _aboutRow(c, Icons.auto_awesome_outlined, "What's new", 'See the latest StudentOS updates', tag: 'Soon'),
              _aboutRow(c, Icons.trending_up, 'Send feedback', 'Tell us what would make this better', tag: 'Soon'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: c.inkSoft),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('StudentOS', style: bodyFont(size: 13.5, weight: FontWeight.w500, color: c.ink)),
                          Text('Version 1.0.0', style: bodyFont(size: 11.5, color: c.inkSoft)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _confirmLogout(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: coral,
              side: const BorderSide(color: coral),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text('Log out', style: bodyFont(size: 13.5, weight: FontWeight.w600, color: coral)),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to sign in again to see your data."),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.onLogout();
            },
            child: Text('Log out', style: TextStyle(color: coral)),
          ),
        ],
      ),
    );
  }

  Widget _themeButton(BuildContext context, AppColors c, String mode, IconData icon, String label) {
    final active = widget.data.themeMode == mode;
    return GestureDetector(
      onTap: () => widget.onUpdateTheme(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? strongInk : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? c.ink : c.line),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: active ? Colors.white : c.inkSoft),
            const SizedBox(height: 4),
            Text(label, style: bodyFont(size: 12, weight: FontWeight.w600, color: active ? Colors.white : c.inkSoft)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(AppColors c, String label, String value, {bool last = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : BorderSide(color: c.lineSoft))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: bodyFont(size: 12.5, color: c.inkSoft)),
          Text(value, style: bodyFont(size: 13.5, weight: FontWeight.w500, color: c.ink)),
        ],
      ),
    );
  }

  Widget _notifRow(AppColors c, String key, String label, String desc, {bool last = false}) {
    final on = notif[key] ?? false;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : BorderSide(color: c.lineSoft))),
      child: Row(
        children: [
          Icon(Icons.notifications_none, size: 16, color: c.inkSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyFont(size: 13.5, weight: FontWeight.w500, color: c.ink)),
                Text(desc, style: bodyFont(size: 11.5, color: c.inkSoft)),
              ],
            ),
          ),
          Switch(
            value: on,
            activeColor: Colors.white,
            activeTrackColor: teal,
            inactiveTrackColor: c.line,
            onChanged: (v) => setState(() => notif[key] = v),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(AppColors c, IconData icon, String label, String desc, {String? tag}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.lineSoft))),
      child: Row(
        children: [
          Icon(icon, size: 16, color: c.inkSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: bodyFont(size: 13.5, weight: FontWeight.w500, color: c.ink)),
                Text(desc, style: bodyFont(size: 11.5, color: c.inkSoft)),
              ],
            ),
          ),
          if (tag != null) Pill(text: tag, tone: 'amber'),
          const SizedBox(width: 6),
          Icon(Icons.chevron_right, size: 15, color: c.inkSoft.withOpacity(0.5)),
        ],
      ),
    );
  }
}
