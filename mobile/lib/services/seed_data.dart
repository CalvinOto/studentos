import '../models/models.dart';

AppData buildSeedData() {
  return AppData(
    profile: Profile(
      name: 'Alex Rivera',
      university: 'Riverside State University',
      major: 'Computer Science',
      year: 'Sophomore',
    ),
    classes: [
      ClassItem(id: genId(), subject: 'Data Structures', kind: 'class', type: 'weekly', day: 1, start: '09:00', end: '10:15', location: 'Wilson Hall 204', color: 'teal'),
      ClassItem(id: genId(), subject: 'Calculus II', kind: 'class', type: 'weekly', day: 1, start: '11:00', end: '12:15', location: 'Beckman 110', color: 'amber'),
      ClassItem(id: genId(), subject: 'Data Structures', kind: 'class', type: 'weekly', day: 3, start: '09:00', end: '10:15', location: 'Wilson Hall 204', color: 'teal'),
      ClassItem(id: genId(), subject: 'Calculus II', kind: 'class', type: 'weekly', day: 3, start: '11:00', end: '12:15', location: 'Beckman 110', color: 'amber'),
      ClassItem(id: genId(), subject: 'Intro to Economics', kind: 'class', type: 'weekly', day: 2, start: '13:30', end: '14:45', location: 'Harding 301', color: 'coral'),
      ClassItem(id: genId(), subject: 'Studio Art', kind: 'class', type: 'weekly', day: 4, start: '15:00', end: '17:00', location: 'Arts Annex', color: 'ink'),
      ClassItem(id: genId(), subject: 'Academic Advising', kind: 'activity', type: 'once', date: shiftDateIso(2), start: '10:00', end: '10:30', location: 'Advising Center', color: 'coral'),
      ClassItem(id: genId(), subject: 'Gym — Leg Day', kind: 'activity', type: 'weekly', day: 5, start: '17:00', end: '18:00', location: 'Campus Rec Center', color: 'ink'),
    ],
    tasks: [
      TaskItem(id: genId(), title: 'Problem set 4 — recursion', category: 'Assignment', priority: 'high', dueDate: todayIso(), status: 'pending'),
      TaskItem(id: genId(), title: 'Read chapters 5-6', category: 'Reading', priority: 'medium', dueDate: todayIso(), status: 'pending'),
      TaskItem(id: genId(), title: 'Econ midterm', category: 'Exam', priority: 'high', dueDate: shiftDateIso(3), status: 'pending'),
      TaskItem(id: genId(), title: 'Group project outline', category: 'Project', priority: 'medium', dueDate: shiftDateIso(5), status: 'pending'),
      TaskItem(id: genId(), title: 'Renew library card', category: 'Personal', priority: 'low', dueDate: shiftDateIso(-1), status: 'done'),
    ],
    expenses: [
      ExpenseItem(id: genId(), amount: 18000, category: 'Food', date: todayIso(), note: 'Campus cafe'),
      ExpenseItem(id: genId(), amount: 95000, category: 'Books', date: shiftDateIso(-2), note: 'Lab manual'),
      ExpenseItem(id: genId(), amount: 35000, category: 'Transport', date: shiftDateIso(-3), note: 'Bus pass top-up'),
      ExpenseItem(id: genId(), amount: 150000, category: 'Fun', date: shiftDateIso(-5), note: 'Concert ticket'),
    ],
    monthlyBudget: 1500000,
    themeMode: 'light',
  );
}

const List<String> taskCategories = ['Assignment', 'Exam', 'Reading', 'Project', 'Personal'];
const List<String> expenseCategories = ['Food', 'Transport', 'Books', 'Rent', 'Fun', 'Other'];
const List<String> classColors = ['teal', 'amber', 'coral', 'ink'];
const List<String> dayNamesShort = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const List<String> dayNamesFull = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
