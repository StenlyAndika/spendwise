import 'package:flutter/foundation.dart';

import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseProvider extends ChangeNotifier {
  final ExpenseRepository _repository;

  DateTime _visibleMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  DateTime _selectedDay = Expense.dateOnly(DateTime.now());
  List<Expense> _monthExpenses = [];
  Map<String, int> _categoryTotals = {};
  Map<DateTime, int> _dayTotals = {};
  List<String> _categories = [];
  bool _loading = false;

  ExpenseProvider(this._repository) {
    _loadMonth();
  }

  DateTime get visibleMonth => _visibleMonth;
  DateTime get selectedDay => _selectedDay;
  List<Expense> get monthExpenses => _monthExpenses;
  Map<String, int> get categoryTotals => _categoryTotals;
  Map<DateTime, int> get dayTotals => _dayTotals;
  List<String> get categories => _categories;
  bool get loading => _loading;

  int get monthTotal =>
      _monthExpenses.fold(0, (sum, e) => sum + e.amount);

  int get transactionCount => _monthExpenses.length;

  List<Expense> expensesForDay(DateTime day) {
    final list = _monthExpenses
        .where((e) => Expense.sameDay(e.date, day))
        .toList();
    list.sort((a, b) {
      final aId = int.tryParse(a.id) ?? 0;
      final bId = int.tryParse(b.id) ?? 0;
      return bId.compareTo(aId);
    });
    return list;
  }

  int dayTotal(DateTime day) =>
      expensesForDay(day).fold(0, (sum, e) => sum + e.amount);

  void setSelectedDay(DateTime day) {
    _selectedDay = Expense.dateOnly(day);
    notifyListeners();
  }

  Future<void> setVisibleMonth(DateTime month) async {
    _visibleMonth = DateTime(month.year, month.month);
    _syncSelectedDayForMonth();
    await _loadMonth();
  }

  Future<void> prevMonth() async {
    await setVisibleMonth(
      DateTime(_visibleMonth.year, _visibleMonth.month - 1),
    );
  }

  Future<void> nextMonth() async {
    await setVisibleMonth(
      DateTime(_visibleMonth.year, _visibleMonth.month + 1),
    );
  }

  Future<void> refresh() => _loadMonth();

  Future<void> addExpense({
    required DateTime date,
    required String category,
    required String description,
    required int amount,
  }) async {
    final expense = Expense(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: Expense.dateOnly(date),
      category: category.trim(),
      description: description.trim(),
      amount: amount,
    );
    await _repository.addExpense(expense);
    if (!Expense.sameMonth(date, _visibleMonth)) {
      await setVisibleMonth(DateTime(date.year, date.month));
    } else {
      await _loadMonth();
    }
  }

  Future<void> updateExpense({
    required String id,
    required DateTime date,
    required String category,
    required String description,
    required int amount,
  }) async {
    final expense = Expense(
      id: id,
      date: Expense.dateOnly(date),
      category: category.trim(),
      description: description.trim(),
      amount: amount,
    );
    await _repository.updateExpense(expense);

    if (!Expense.sameMonth(date, _visibleMonth)) {
      await setVisibleMonth(DateTime(date.year, date.month));
    } else {
      if (!Expense.sameDay(date, _selectedDay)) {
        setSelectedDay(date);
      }
      await _loadMonth();
    }
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    await _loadMonth();
  }

  Future<String> exportBackup() => _repository.exportBackupJson();

  Future<void> importBackup(String json) async {
    await _repository.importBackupJson(json, replace: true);
    _syncSelectedDayForMonth();
    await refresh();
  }

  void _syncSelectedDayForMonth() {
    if (Expense.sameMonth(_selectedDay, _visibleMonth)) return;
    final today = Expense.dateOnly(DateTime.now());
    _selectedDay = Expense.sameMonth(today, _visibleMonth)
        ? today
        : DateTime(_visibleMonth.year, _visibleMonth.month, 1);
  }

  Future<void> _loadMonth() async {
    _loading = true;
    notifyListeners();

    final results = await Future.wait([
      _repository.getExpensesForMonth(_visibleMonth),
      _repository.getCategoryTotalsForMonth(_visibleMonth),
      _repository.getDayTotalsForMonth(_visibleMonth),
      _repository.getCategories(),
    ]);

    _monthExpenses = results[0] as List<Expense>;
    _categoryTotals = results[1] as Map<String, int>;
    _dayTotals = results[2] as Map<DateTime, int>;
    _categories = results[3] as List<String>;

    _loading = false;
    notifyListeners();
  }
}
