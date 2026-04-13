import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';

class AppState extends ChangeNotifier {
  final _uuid = const Uuid();
  bool _isDarkMode = false;
  bool _isLoggedIn = false;
  AppUser? _currentUser;
  final List<AppUser> _users = [];
  final List<Crop> _crops = [];
  final List<Activity> _activities = [];
  final List<Expense> _expenses = [];
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  AppUser? get currentUser => _currentUser;

  // Active crops only
  List<Crop> get crops => List.unmodifiable(_crops.where((c) => !c.isArchived));
  // Archived/harvested crops
  List<Crop> get archivedCrops => List.unmodifiable(_crops.where((c) => c.isArchived));

  List<Activity> get activities => List.unmodifiable(_activities);
  List<Expense> get expenses => List.unmodifiable(_expenses);
  bool get isLoading => _isLoading;

  double get totalInvested {
    return _activities.fold(0.0, (sum, a) => sum + a.cost) +
        _expenses.fold(0.0, (sum, e) => sum + e.amount);
  }

  double get totalActivitiesCost =>
      _activities.fold(0.0, (sum, a) => sum + a.cost);

  double get totalExpensesCost =>
      _expenses.fold(0.0, (sum, e) => sum + e.amount);

  List<Activity> activitiesForCrop(String cropId) =>
      _activities.where((a) => a.cropId == cropId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  List<Expense> expensesForCrop(String cropId) =>
      _expenses.where((e) => e.cropId == cropId).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  double totalCostForCrop(String cropId) {
    final actCost = _activities
        .where((a) => a.cropId == cropId)
        .fold(0.0, (sum, a) => sum + a.cost);
    final expCost = _expenses
        .where((e) => e.cropId == cropId)
        .fold(0.0, (sum, e) => sum + e.amount);
    return actCost + expCost;
  }

  Activity? lastActivityForCrop(String cropId) {
    final list = activitiesForCrop(cropId);
    return list.isNotEmpty ? list.first : null;
  }

  List<Activity> get recentActivities {
    final sorted = List<Activity>.from(_activities)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(5).toList();
  }

  List<Activity> get allActivitiesSorted {
    return List<Activity>.from(_activities)
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Crop by id (including archived)
  Crop? cropById(String id) => _crops.where((c) => c.id == id).firstOrNull;

  AppState() {
    _registerDemoUser();
    _loadPrefs();
  }

  void _registerDemoUser() {
    _users.add(AppUser(
      id: _uuid.v4(),
      fullName: 'Carlos Rodríguez',
      contact: 'demo@cultivapp.co',
      password: 'Demo1234',
    ));
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    final loggedContact = prefs.getString('loggedContact');
    if (loggedContact != null) {
      final user =
          _users.where((u) => u.contact == loggedContact).firstOrNull;
      if (user != null) {
        _currentUser = user;
        _isLoggedIn = true;
      }
    }
    notifyListeners();
  }

  // ── Demo templates ──────────────────────────────────────────────────────────

  void loadDemoTemplate(String templateId) {
    _crops.removeWhere((c) => true);
    _activities.clear();
    _expenses.clear();

    switch (templateId) {
      case 'few':
        _loadFewCrops();
        break;
      case 'medium':
        _loadMediumCrops();
        break;
      case 'many':
        _loadManyCrops();
        break;
    }
    notifyListeners();
  }

  void clearAllData() {
    _crops.clear();
    _activities.clear();
    _expenses.clear();
    notifyListeners();
  }

  void _loadFewCrops() {
    final c1 = Crop(
      id: _uuid.v4(),
      name: 'Maíz Parcela Norte',
      type: 'Maíz',
      location: 'Parcela Norte',
      sowingDate: DateTime.now().subtract(const Duration(days: 30)),
      status: CropStatus.growing,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    _crops.add(c1);
    _activities.add(Activity(
      id: _uuid.v4(),
      cropId: c1.id,
      type: ActivityType.irrigation,
      date: DateTime.now().subtract(const Duration(days: 3)),
      description: 'Riego por goteo',
      cost: 15000,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ));
    _expenses.add(Expense(
      id: _uuid.v4(),
      cropId: c1.id,
      description: 'Semillas de maíz',
      amount: 80000,
      category: 'Semillas',
      date: DateTime.now().subtract(const Duration(days: 30)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ));
  }

  void _loadMediumCrops() {
    final types = ['Maíz', 'Tomate', 'Papa', 'Frijol'];
    final locations = ['Parcela Norte', 'Invernadero', 'Lote Sur', 'Terraza'];
    final statuses = [
      CropStatus.active,
      CropStatus.growing,
      CropStatus.growing,
      CropStatus.active
    ];

    for (int i = 0; i < 4; i++) {
      final c = Crop(
        id: _uuid.v4(),
        name: '${types[i]} ${locations[i]}',
        type: types[i],
        location: locations[i],
        sowingDate: DateTime.now().subtract(Duration(days: 20 + i * 10)),
        status: statuses[i],
        createdAt: DateTime.now().subtract(Duration(days: 20 + i * 10)),
      );
      _crops.add(c);
      _activities.add(Activity(
        id: _uuid.v4(),
        cropId: c.id,
        type: ActivityType.values[i % 3],
        date: DateTime.now().subtract(Duration(days: i + 1)),
        description: 'Actividad de mantenimiento',
        cost: 20000.0 + i * 10000,
        createdAt: DateTime.now().subtract(Duration(days: i + 1)),
      ));
      _expenses.add(Expense(
        id: _uuid.v4(),
        cropId: c.id,
        description: 'Insumos iniciales',
        amount: 50000.0 + i * 15000,
        category: 'Semillas',
        date: DateTime.now().subtract(Duration(days: 20 + i * 10)),
        createdAt: DateTime.now().subtract(Duration(days: 20 + i * 10)),
      ));
    }
  }

  void _loadManyCrops() {
    final data = [
      {'name': 'Maíz Parcela A', 'type': 'Maíz', 'loc': 'Parcela A', 'days': 60},
      {'name': 'Tomate Invernadero 1', 'type': 'Tomate', 'loc': 'Invernadero 1', 'days': 45},
      {'name': 'Papa Lote Sur', 'type': 'Papa', 'loc': 'Lote Sur', 'days': 30},
      {'name': 'Frijol Vereda Alta', 'type': 'Frijol', 'loc': 'Vereda Alta', 'days': 25},
      {'name': 'Café Parcela B', 'type': 'Café', 'loc': 'Parcela B', 'days': 90},
      {'name': 'Plátano Ribera', 'type': 'Plátano', 'loc': 'Ribera del Río', 'days': 120},
      {'name': 'Cebolla Lote Norte', 'type': 'Cebolla', 'loc': 'Lote Norte', 'days': 20},
      {'name': 'Yuca Parcela C', 'type': 'Yuca', 'loc': 'Parcela C', 'days': 50},
    ];
    final statuses = [
      CropStatus.growing, CropStatus.active, CropStatus.growing, CropStatus.active,
      CropStatus.growing, CropStatus.active, CropStatus.active, CropStatus.growing,
    ];
    for (int i = 0; i < data.length; i++) {
      final d = data[i];
      final c = Crop(
        id: _uuid.v4(),
        name: d['name'] as String,
        type: d['type'] as String,
        location: d['loc'] as String,
        sowingDate: DateTime.now().subtract(Duration(days: d['days'] as int)),
        status: statuses[i],
        createdAt: DateTime.now().subtract(Duration(days: d['days'] as int)),
      );
      _crops.add(c);
      for (int j = 0; j < 2; j++) {
        _activities.add(Activity(
          id: _uuid.v4(),
          cropId: c.id,
          type: ActivityType.values[j % ActivityType.values.length],
          date: DateTime.now().subtract(Duration(days: j + 1)),
          description: 'Mantenimiento programado',
          cost: 15000.0 + j * 8000,
          createdAt: DateTime.now().subtract(Duration(days: j + 1)),
        ));
      }
      _expenses.add(Expense(
        id: _uuid.v4(),
        cropId: c.id,
        description: 'Insumos de siembra',
        amount: 45000.0 + i * 12000,
        category: 'Semillas',
        date: DateTime.now().subtract(Duration(days: d['days'] as int)),
        createdAt: DateTime.now().subtract(Duration(days: d['days'] as int)),
      ));
    }
  }

  // ── Auth ────────────────────────────────────────────────────────────────────

  void toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  bool register(String fullName, String contact, String password) {
    if (_users.any((u) => u.contact == contact)) return false;
    _users.add(AppUser(
        id: _uuid.v4(), fullName: fullName, contact: contact, password: password));
    return true;
  }

  Future<bool> login(String contact, String password) async {
    setLoading(true);
    await Future.delayed(const Duration(milliseconds: 800));
    final user = _users
        .where((u) => u.contact == contact && u.password == password)
        .firstOrNull;
    if (user != null) {
      _currentUser = user;
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loggedContact', contact);
      setLoading(false);
      notifyListeners();
      return true;
    }
    setLoading(false);
    return false;
  }

  Future<void> loginAsDemo() async {
    setLoading(true);
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = _users.first;
    _isLoggedIn = true;
    _loadMediumCrops();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('loggedContact', _users.first.contact);
    setLoading(false);
    notifyListeners();
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedContact');
    notifyListeners();
  }

  // ── Crops ───────────────────────────────────────────────────────────────────

  void addCrop(Crop crop) {
    _crops.add(crop);
    notifyListeners();
  }

  void updateCrop(Crop updated) {
    final index = _crops.indexWhere((c) => c.id == updated.id);
    if (index != -1) {
      _crops[index] = updated;
      notifyListeners();
    }
  }

  /// Archive a crop (harvest or cancel) – keeps data
  void archiveCrop(String id, CropStatus finalStatus, String reason) {
    final index = _crops.indexWhere((c) => c.id == id);
    if (index != -1) {
      _crops[index] = _crops[index].copyWith(
        isArchived: true,
        status: finalStatus,
        archiveReason: reason,
        archivedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Permanently delete a crop and all its data
  void deleteCrop(String id) {
    _crops.removeWhere((c) => c.id == id);
    _activities.removeWhere((a) => a.cropId == id);
    _expenses.removeWhere((e) => e.cropId == id);
    notifyListeners();
  }

  void addActivity(Activity activity) {
    _activities.add(activity);
    notifyListeners();
  }

  void deleteActivity(String id) {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  String newId() => _uuid.v4();
}
