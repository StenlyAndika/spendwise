import '../models/expense.dart';

abstract class ExpenseRepository {
  Future<List<String>> getCategories();
  Future<void> addExpense(Expense expense);
  Future<void> updateExpense(Expense expense);
  Future<void> deleteExpense(String id);
  Future<List<Expense>> getExpensesForMonth(DateTime month);
  Future<List<Expense>> getExpensesForDay(DateTime day);
  Future<Map<String, int>> getCategoryTotalsForMonth(DateTime month);
  Future<Map<DateTime, int>> getDayTotalsForMonth(DateTime month);
  Future<int> getDayTotal(DateTime day);
  Future<String> exportBackupJson();
  Future<void> importBackupJson(String json, {required bool replace});
}
