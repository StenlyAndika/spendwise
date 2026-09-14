import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import 'expense_state.dart';

/// Owns the month/selection state and all expense mutations.
///
/// Behaviour is a 1:1 port of the previous `ExpenseProvider`, expressed as
/// `emit()` transitions instead of `notifyListeners()`:
///
/// * [setSelectedDay] / [setVisibleMonth] change navigation only.
/// * [_loadMonth] fetches the four aggregates in parallel and emits once.
/// * add/update jump to the affected month when it is off-screen.
class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repository;

  ExpenseCubit(this._repository) : super(ExpenseState.initial()) {
    loadMonth();
  }

  Future<void> setSelectedDay(DateTime day) async {
    emit(state.copyWith(selectedDay: Expense.dateOnly(day)));
  }

  Future<void> setVisibleMonth(DateTime month) async {
    emit(
      state.copyWith(
        visibleMonth: DateTime(month.year, month.month),
        selectedDay: _selectedDayForMonth(DateTime(month.year, month.month)),
      ),
    );
    await loadMonth();
  }

  Future<void> prevMonth() => setVisibleMonth(
    DateTime(state.visibleMonth.year, state.visibleMonth.month - 1),
  );

  Future<void> nextMonth() => setVisibleMonth(
    DateTime(state.visibleMonth.year, state.visibleMonth.month + 1),
  );

  Future<void> refresh() => loadMonth();

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

    if (!Expense.sameMonth(date, state.visibleMonth)) {
      await setVisibleMonth(DateTime(date.year, date.month));
    } else {
      await loadMonth();
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

    if (!Expense.sameMonth(date, state.visibleMonth)) {
      await setVisibleMonth(DateTime(date.year, date.month));
    } else {
      if (!Expense.sameDay(date, state.selectedDay)) {
        await setSelectedDay(date);
      }
      await loadMonth();
    }
  }

  Future<void> deleteExpense(String id) async {
    await _repository.deleteExpense(id);
    await loadMonth();
  }

  Future<String> exportBackup() => _repository.exportBackupJson();

  Future<void> importBackup(String json) async {
    await _repository.importBackupJson(json, replace: true);
    await setVisibleMonth(state.visibleMonth);
    await refresh();
  }

  Future<void> loadMonth() async {
    if (isClosed) return;
    emit(state.copyWith(loading: true));

    final results = await Future.wait([
      _repository.getExpensesForMonth(state.visibleMonth),
      _repository.getCategoryTotalsForMonth(state.visibleMonth),
      _repository.getDayTotalsForMonth(state.visibleMonth),
      _repository.getCategories(),
    ]);

    if (isClosed) return;

    emit(
      state.copyWith(
        monthExpenses: results[0] as List<Expense>,
        categoryTotals: results[1] as Map<String, int>,
        dayTotals: results[2] as Map<DateTime, int>,
        categories: results[3] as List<String>,
        loading: false,
      ),
    );
  }

  /// Keeps the selected day inside the visible month: today when the month
  /// is the current one, otherwise the 1st.
  DateTime _selectedDayForMonth(DateTime month) {
    if (Expense.sameMonth(state.selectedDay, month)) return state.selectedDay;
    final today = Expense.dateOnly(DateTime.now());
    return Expense.sameMonth(today, month)
        ? today
        : DateTime(month.year, month.month, 1);
  }
}
