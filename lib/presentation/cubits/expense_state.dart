import 'package:equatable/equatable.dart';

import '../../../domain/models/expense.dart';

/// Immutable snapshot of everything the UI renders.
///
/// Replaces the scattered mutable fields of the old `ExpenseProvider`:
/// a single state object per emission means widgets rebuild only on
/// meaningful change (Equatable short-circuits identical snapshots).
class ExpenseState extends Equatable {
  /// Month currently being viewed (normalised to the 1st).
  final DateTime visibleMonth;

  /// Day whose log is shown on the home page.
  final DateTime selectedDay;

  /// All expenses in [visibleMonth], newest first.
  final List<Expense> monthExpenses;

  /// `category -> total` for [visibleMonth].
  final Map<String, int> categoryTotals;

  /// `day -> total` for [visibleMonth].
  final Map<DateTime, int> dayTotals;

  /// Known category names, alphabetical.
  final List<String> categories;

  /// True while the initial month load has not produced data yet.
  final bool loading;

  const ExpenseState({
    required this.visibleMonth,
    required this.selectedDay,
    this.monthExpenses = const [],
    this.categoryTotals = const {},
    this.dayTotals = const {},
    this.categories = const [],
    this.loading = true,
  });

  factory ExpenseState.initial() {
    final now = DateTime.now();
    final today = Expense.dateOnly(now);
    return ExpenseState(
      visibleMonth: DateTime(now.year, now.month),
      selectedDay: today,
    );
  }

  int get monthTotal => monthExpenses.fold(0, (sum, e) => sum + e.amount);

  int get transactionCount => monthExpenses.length;

  List<Expense> expensesForDay(DateTime day) {
    final list =
        monthExpenses.where((e) => Expense.sameDay(e.date, day)).toList()
          ..sort((a, b) {
            final aId = int.tryParse(a.id) ?? 0;
            final bId = int.tryParse(b.id) ?? 0;
            return bId.compareTo(aId);
          });
    return list;
  }

  int dayTotal(DateTime day) =>
      expensesForDay(day).fold(0, (sum, e) => sum + e.amount);

  ExpenseState copyWith({
    DateTime? visibleMonth,
    DateTime? selectedDay,
    List<Expense>? monthExpenses,
    Map<String, int>? categoryTotals,
    Map<DateTime, int>? dayTotals,
    List<String>? categories,
    bool? loading,
  }) => ExpenseState(
    visibleMonth: visibleMonth ?? this.visibleMonth,
    selectedDay: selectedDay ?? this.selectedDay,
    monthExpenses: monthExpenses ?? this.monthExpenses,
    categoryTotals: categoryTotals ?? this.categoryTotals,
    dayTotals: dayTotals ?? this.dayTotals,
    categories: categories ?? this.categories,
    loading: loading ?? this.loading,
  );

  @override
  List<Object?> get props => [
    visibleMonth,
    selectedDay,
    monthExpenses,
    categoryTotals,
    dayTotals,
    categories,
    loading,
  ];
}
