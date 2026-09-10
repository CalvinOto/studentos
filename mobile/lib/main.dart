import 'package:flutter/material.dart';
import 'models/models.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';
import 'screens/auth_flow.dart';
import 'screens/dashboard_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/finance_screen.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const StudentOSApp());
}

class StudentOSApp extends StatefulWidget {
  const StudentOSApp({super.key});

  @override
  State<StudentOSApp> createState() => _StudentOSAppState();
}

class _StudentOSAppState extends State<StudentOSApp> {
  AppData? data;
  bool checkingAuth = true;
  bool loggedIn = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// On launch: if there's no saved token, go straight to login. If there
  /// is one, show cached data immediately (fast paint, works offline), then
  /// try to refresh from the server in the background.
  Future<void> _bootstrap() async {
    final token = await ApiService.getToken();
    if (token == null) {
      setState(() {
        checkingAuth = false;
        loggedIn = false;
      });
      return;
    }

    final cached = await StorageService.load();
    if (cached != null && mounted) {
      setState(() => data = cached);
    }

    await _refreshFromServer();

    if (mounted) {
      setState(() {
        checkingAuth = false;
        loggedIn = data != null;
      });
    }
  }

  /// Pulls profile + classes + tasks + expenses from the API and assembles
  /// them into one AppData, then caches that locally. If the request fails
  /// (no network, server down), it just leaves whatever's already on screen
  /// alone rather than clearing it — except for a 401, which means the
  /// token itself is no longer valid, so that forces a logout.
  Future<void> _refreshFromServer() async {
    try {
      final profileJson = await ApiService.getProfile();
      final classesJson = await ApiService.getClasses();
      final tasksJson = await ApiService.getTasks();
      final expensesJson = await ApiService.getExpenses();

      final next = AppData(
        profile: Profile(
          name: profileJson['name'] ?? '',
          university: profileJson['university'] ?? '',
          major: profileJson['major'] ?? '',
          year: profileJson['year'] ?? 'Freshman',
        ),
        classes: classesJson.map((e) => ClassItem.fromJson(e as Map<String, dynamic>)).toList(),
        tasks: tasksJson.map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList(),
        expenses: expensesJson.map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>)).toList(),
        monthlyBudget: (profileJson['monthlyBudget'] as num?)?.toDouble() ?? 0,
        themeMode: profileJson['themeMode'] ?? 'light',
      );

      await StorageService.save(next);
      if (mounted) setState(() => data = next);
    } on ApiUnauthorizedException {
      await ApiService.logout();
      if (mounted) {
        setState(() {
          data = null;
          loggedIn = false;
        });
      }
    } catch (_) {
      // Network hiccup or server down — keep showing whatever's cached.
    }
  }

  Future<void> _handleAuthenticated() async {
    setState(() => checkingAuth = true);
    await _refreshFromServer();
    if (mounted) {
      setState(() {
        checkingAuth = false;
        loggedIn = data != null;
      });
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.logout();
    setState(() {
      data = null;
      loggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = data?.themeMode == 'dark';
    final colors = isDark ? AppColors.dark : AppColors.light;

    Widget body;
    if (checkingAuth) {
      body = Scaffold(backgroundColor: colors.paper, body: const Center(child: CircularProgressIndicator(color: teal)));
    } else if (!loggedIn || data == null) {
      body = AuthFlow(onAuthenticated: _handleAuthenticated);
    } else {
      body = RootShell(
        data: data!,
        onLocalUpdate: (next) => setState(() => data = next),
        onRefresh: _refreshFromServer,
        onLogout: _handleLogout,
      );
    }

    return MaterialApp(
      title: 'StudentOS',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: colors.paper,
        colorScheme: ColorScheme.fromSeed(seedColor: teal, brightness: isDark ? Brightness.dark : Brightness.light),
        extensions: [colors],
      ),
      home: body,
    );
  }
}

class RootShell extends StatefulWidget {
  final AppData data;
  final ValueChanged<AppData> onLocalUpdate;
  final Future<void> Function() onRefresh;
  final VoidCallback onLogout;
  const RootShell({
    super.key,
    required this.data,
    required this.onLocalUpdate,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  late AppData _data = widget.data;
  int tabIndex = 0;

  final scheduleKey = GlobalKey<ScheduleScreenState>();
  final tasksKey = GlobalKey<TasksScreenState>();
  final financeKey = GlobalKey<FinanceScreenState>();

  @override
  void didUpdateWidget(covariant RootShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.data, widget.data)) {
      _data = widget.data;
    }
  }

  void _applyLocal(AppData next) {
    setState(() => _data = next);
    widget.onLocalUpdate(next);
    StorageService.save(next);
  }

  void _showError(Object e) {
    final message = e is ApiException ? e.message : 'Something went wrong. Check your connection.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: coral));
  }

  AppData _cloneWith({
    Profile? profile,
    List<ClassItem>? classes,
    List<TaskItem>? tasks,
    List<ExpenseItem>? expenses,
    double? monthlyBudget,
    String? themeMode,
  }) {
    return AppData(
      profile: profile ?? _data.profile,
      classes: classes ?? _data.classes,
      tasks: tasks ?? _data.tasks,
      expenses: expenses ?? _data.expenses,
      monthlyBudget: monthlyBudget ?? _data.monthlyBudget,
      themeMode: themeMode ?? _data.themeMode,
    );
  }

  // ---- classes ----
  Future<void> _addClass(ClassItem draft) async {
    try {
      final json = await ApiService.createClass(draft.toCreateJson());
      final saved = ClassItem.fromJson(json);
      _applyLocal(_cloneWith(classes: [..._data.classes, saved]));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _updateClass(String id, ClassItem updated) async {
    try {
      final json = await ApiService.updateClass(id, updated.toCreateJson());
      final saved = ClassItem.fromJson(json);
      _applyLocal(_cloneWith(classes: _data.classes.map((c) => c.id == id ? saved : c).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteClass(String id) async {
    try {
      await ApiService.deleteClass(id);
      _applyLocal(_cloneWith(classes: _data.classes.where((c) => c.id != id).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  // ---- tasks ----
  Future<void> _addTask(TaskItem draft) async {
    try {
      final json = await ApiService.createTask(draft.toCreateJson());
      final saved = TaskItem.fromJson(json);
      _applyLocal(_cloneWith(tasks: [..._data.tasks, saved]));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _updateTask(String id, TaskItem updated) async {
    try {
      final json = await ApiService.updateTask(id, updated.toCreateJson());
      final saved = TaskItem.fromJson(json);
      _applyLocal(_cloneWith(tasks: _data.tasks.map((t) => t.id == id ? saved : t).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _toggleTask(String id) async {
    try {
      final json = await ApiService.toggleTask(id);
      final saved = TaskItem.fromJson(json);
      _applyLocal(_cloneWith(tasks: _data.tasks.map((t) => t.id == id ? saved : t).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteTask(String id) async {
    try {
      await ApiService.deleteTask(id);
      _applyLocal(_cloneWith(tasks: _data.tasks.where((t) => t.id != id).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  // ---- expenses ----
  Future<void> _addExpense(ExpenseItem draft) async {
    try {
      final json = await ApiService.createExpense(draft.toCreateJson());
      final saved = ExpenseItem.fromJson(json);
      _applyLocal(_cloneWith(expenses: [..._data.expenses, saved]));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _updateExpense(String id, ExpenseItem updated) async {
    try {
      final json = await ApiService.updateExpense(id, updated.toCreateJson());
      final saved = ExpenseItem.fromJson(json);
      _applyLocal(_cloneWith(expenses: _data.expenses.map((e) => e.id == id ? saved : e).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _deleteExpense(String id) async {
    try {
      await ApiService.deleteExpense(id);
      _applyLocal(_cloneWith(expenses: _data.expenses.where((e) => e.id != id).toList()));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _updateBudget(double v) async {
    try {
      final json = await ApiService.updateProfile({'monthlyBudget': v});
      _applyLocal(_cloneWith(monthlyBudget: (json['monthlyBudget'] as num?)?.toDouble() ?? v));
    } catch (e) {
      _showError(e);
    }
  }

  // ---- profile & theme (both live on /profile server-side) ----
  Future<void> _updateProfile(Profile p) async {
    try {
      final json = await ApiService.updateProfile({
        'name': p.name,
        'university': p.university,
        'major': p.major,
        'year': p.year,
      });
      _applyLocal(_cloneWith(
        profile: Profile(
          name: json['name'] ?? p.name,
          university: json['university'] ?? p.university,
          major: json['major'] ?? p.major,
          year: json['year'] ?? p.year,
        ),
      ));
    } catch (e) {
      _showError(e);
    }
  }

  Future<void> _updateTheme(String mode) async {
    try {
      final json = await ApiService.updateProfile({'themeMode': mode});
      _applyLocal(_cloneWith(themeMode: json['themeMode'] ?? mode));
    } catch (e) {
      _showError(e);
    }
  }

  void _onFabPressed() {
    switch (tabIndex) {
      case 1:
        scheduleKey.currentState?.openAddSheet();
        break;
      case 2:
        tasksKey.currentState?.openAddSheet();
        break;
      case 3:
        financeKey.currentState?.openAddSheet();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>()!;
    final showFab = tabIndex == 1 || tabIndex == 2 || tabIndex == 3;

    final screens = [
      DashboardScreen(data: _data, onGoToTab: (i) => setState(() => tabIndex = i)),
      ScheduleScreen(key: scheduleKey, data: _data, onAdd: _addClass, onUpdate: _updateClass, onDelete: _deleteClass),
      TasksScreen(key: tasksKey, data: _data, onAdd: _addTask, onUpdate: _updateTask, onToggle: _toggleTask, onDelete: _deleteTask),
      FinanceScreen(key: financeKey, data: _data, onAdd: _addExpense, onUpdate: _updateExpense, onDelete: _deleteExpense, onUpdateBudget: _updateBudget),
      ProfileScreen(data: _data, onUpdateProfile: _updateProfile, onUpdateTheme: _updateTheme, onLogout: widget.onLogout),
    ];

    return Scaffold(
      backgroundColor: c.paper,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          color: teal,
          child: IndexedStack(index: tabIndex, children: screens),
        ),
      ),
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              backgroundColor: teal,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (i) => setState(() => tabIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: c.paperRaised,
        selectedItemColor: teal,
        unselectedItemColor: c.inkSoft,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.check_box_outlined), activeIcon: Icon(Icons.check_box), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), activeIcon: Icon(Icons.account_balance_wallet), label: 'Finance'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
