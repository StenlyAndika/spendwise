import 'package:spendwise/domain/models/expense.dart';
import 'package:spendwise/domain/repositories/expense_repository.dart';

class FakeExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];
  final List<String> _categories = [];

  @override
  Future<List<String>> getCategories() async => List.from(_categories);

  @override
  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    if (!_categories.contains(expense.category)) {
      _categories.add(expense.category);
      _categories.sort();
    }
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index >= 0) _expenses[index] = expense;
    if (!_categories.contains(expense.category)) {
      _categories.add(expense.category);
      _categories.sort();
    }
  }

  @override
  Future<void> deleteExpense(String id) async {
    _expenses.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<Expense>> getExpensesForMonth(DateTime month) async {
    return _expenses.where((e) => Expense.sameMonth(e.date, month)).toList();
  }

  @override
  Future<Map<String, int>> getCategoryTotalsForMonth(DateTime month) async {
    final totals = <String, int>{};
    for (final e in _expenses) {
      if (!Expense.sameMonth(e.date, month)) continue;
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }
    return totals;
  }

  @override
  Future<Map<DateTime, int>> getDayTotalsForMonth(DateTime month) async {
    final totals = <DateTime, int>{};
    for (final e in _expenses) {
      if (!Expense.sameMonth(e.date, month)) continue;
      final day = Expense.dateOnly(e.date);
      totals[day] = (totals[day] ?? 0) + e.amount;
    }
    return totals;
  }

  @override
  Future<String> exportBackupJson() async =>
      '{"version":1,"exportedAt":"2026-01-01T00:00:00.000Z","categories":[],"expenses":[]}';

  @override
  Future<void> importBackupJson(String json, {required bool replace}) async {}
}
