import 'dart:convert';
import 'dart:math';

String genId() {
  final rnd = Random();
  final n = rnd.nextInt(1 << 32);
  final t = DateTime.now().microsecondsSinceEpoch;
  return (t ^ n).toRadixString(36);
}

String _pad2(int n) => n.toString().padLeft(2, '0');

String isoDate(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${_pad2(d.month)}-${_pad2(d.day)}';

String todayIso() => isoDate(DateTime.now());

String shiftDateIso(int days) => isoDate(DateTime.now().add(Duration(days: days)));

/// Days between today and [iso] (positive = future, negative = past).
int daysUntil(String iso) {
  final today = DateTime.parse(todayIso());
  final target = DateTime.parse(iso);
  return target.difference(today).inDays;
}

class Profile {
  String name;
  String university;
  String major;
  String year;

  Profile({
    required this.name,
    required this.university,
    required this.major,
    required this.year,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        name: j['name'] ?? '',
        university: j['university'] ?? '',
        major: j['major'] ?? '',
        year: j['year'] ?? 'Freshman',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'university': university,
        'major': major,
        'year': year,
      };

  Profile copy() => Profile(name: name, university: university, major: major, year: year);
}

/// A scheduled item: either a recurring/one-time class, or a personal activity.
class ClassItem {
  String id;
  String subject;
  String kind; // 'class' | 'activity'
  String type; // 'once' | 'weekly' | 'monthly'
  int day; // 0 (Sun) - 6 (Sat), used when type == 'weekly'
  int dayOfMonth; // 1-31, used when type == 'monthly'
  String? date; // yyyy-MM-dd, used when type == 'once'
  String start; // HH:mm
  String end; // HH:mm
  String location;
  String color; // 'teal' | 'amber' | 'coral' | 'ink'
  List<String> skipDates; // occurrence dates (yyyy-MM-dd) to hide, e.g. holidays

  ClassItem({
    required this.id,
    required this.subject,
    this.kind = 'class',
    this.type = 'weekly',
    this.day = 1,
    this.dayOfMonth = 1,
    this.date,
    required this.start,
    required this.end,
    this.location = '',
    this.color = 'teal',
    List<String>? skipDates,
  }) : skipDates = skipDates ?? [];

  factory ClassItem.fromJson(Map<String, dynamic> j) => ClassItem(
        id: j['id'],
        subject: j['subject'] ?? '',
        kind: j['kind'] ?? 'class',
        type: j['type'] ?? 'weekly',
        day: j['day'] ?? 1,
        dayOfMonth: j['dayOfMonth'] ?? 1,
        date: j['date'],
        start: j['start'] ?? '09:00',
        end: j['end'] ?? '10:00',
        location: j['location'] ?? '',
        color: j['color'] ?? 'teal',
        skipDates: (j['skipDates'] as List?)?.map((e) => e.toString()).toList() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'subject': subject,
        'kind': kind,
        'type': type,
        'day': day,
        'dayOfMonth': dayOfMonth,
        'date': date,
        'start': start,
        'end': end,
        'location': location,
        'color': color,
        'skipDates': skipDates,
      };

  /// Body for POST/PATCH to the API — deliberately excludes id/userId,
  /// which the server assigns.
  Map<String, dynamic> toCreateJson() => {
        'subject': subject,
        'kind': kind,
        'type': type,
        'day': day,
        'dayOfMonth': dayOfMonth,
        'date': date,
        'start': start,
        'end': end,
        'location': location,
        'color': color,
        'skipDates': skipDates,
      };

  ClassItem copyWith({
    String? subject,
    String? kind,
    String? type,
    int? day,
    int? dayOfMonth,
    String? date,
    String? start,
    String? end,
    String? location,
    String? color,
    List<String>? skipDates,
  }) {
    return ClassItem(
      id: id,
      subject: subject ?? this.subject,
      kind: kind ?? this.kind,
      type: type ?? this.type,
      day: day ?? this.day,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      date: date ?? this.date,
      start: start ?? this.start,
      end: end ?? this.end,
      location: location ?? this.location,
      color: color ?? this.color,
      skipDates: skipDates ?? this.skipDates,
    );
  }
}

class TaskItem {
  String id;
  String title;
  String category;
  String priority; // low | medium | high
  String dueDate; // yyyy-MM-dd
  String status; // pending | done

  TaskItem({
    required this.id,
    required this.title,
    this.category = 'Assignment',
    this.priority = 'medium',
    required this.dueDate,
    this.status = 'pending',
  });

  factory TaskItem.fromJson(Map<String, dynamic> j) => TaskItem(
        id: j['id'],
        title: j['title'] ?? '',
        category: j['category'] ?? 'Assignment',
        priority: j['priority'] ?? 'medium',
        dueDate: j['dueDate'] ?? todayIso(),
        status: j['status'] ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'priority': priority,
        'dueDate': dueDate,
        'status': status,
      };

  Map<String, dynamic> toCreateJson() => {
        'title': title,
        'category': category,
        'priority': priority,
        'dueDate': dueDate,
        'status': status,
      };

  TaskItem copyWith({String? title, String? category, String? priority, String? dueDate, String? status}) {
    return TaskItem(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
    );
  }
}

class ExpenseItem {
  String id;
  double amount;
  String category;
  String date; // yyyy-MM-dd
  String note;

  ExpenseItem({
    required this.id,
    required this.amount,
    this.category = 'Food',
    required this.date,
    this.note = '',
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> j) => ExpenseItem(
        id: j['id'],
        amount: (j['amount'] as num).toDouble(),
        category: j['category'] ?? 'Food',
        date: j['date'] ?? todayIso(),
        note: j['note'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category,
        'date': date,
        'note': note,
      };

  Map<String, dynamic> toCreateJson() => {
        'amount': amount,
        'category': category,
        'date': date,
        'note': note,
      };

  ExpenseItem copyWith({double? amount, String? category, String? date, String? note}) {
    return ExpenseItem(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}

class AppData {
  Profile profile;
  List<ClassItem> classes;
  List<TaskItem> tasks;
  List<ExpenseItem> expenses;
  double monthlyBudget;
  String themeMode; // 'light' | 'dark'

  AppData({
    required this.profile,
    required this.classes,
    required this.tasks,
    required this.expenses,
    required this.monthlyBudget,
    this.themeMode = 'light',
  });

  factory AppData.fromJson(Map<String, dynamic> j) => AppData(
        profile: Profile.fromJson(j['profile']),
        classes: (j['classes'] as List).map((e) => ClassItem.fromJson(e)).toList(),
        tasks: (j['tasks'] as List).map((e) => TaskItem.fromJson(e)).toList(),
        expenses: (j['expenses'] as List).map((e) => ExpenseItem.fromJson(e)).toList(),
        monthlyBudget: (j['monthlyBudget'] as num).toDouble(),
        themeMode: j['themeMode'] ?? 'light',
      );

  Map<String, dynamic> toJson() => {
        'profile': profile.toJson(),
        'classes': classes.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'expenses': expenses.map((e) => e.toJson()).toList(),
        'monthlyBudget': monthlyBudget,
        'themeMode': themeMode,
      };

  String encode() => jsonEncode(toJson());

  static AppData decode(String s) => AppData.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
