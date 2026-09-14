import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/domain/models/expense.dart';
import 'package:spendwise/presentation/cubits/expense_cubit.dart';

import 'fakes/fake_expense_repository.dart';

void main() {
  late FakeExpenseRepository repository;
  late ExpenseCubit cubit;

  setUp(() {
    repository = FakeExpenseRepository();
    cubit = ExpenseCubit(repository);
  });

  tearDown(() => cubit.close());

  test(
    'initial state loads the current month and starts not loading',
    () async {
      await cubit.loadMonth();

      final now = DateTime.now();
      expect(cubit.state.visibleMonth, DateTime(now.year, now.month));
      expect(cubit.state.loading, isFalse);
      expect(cubit.state.monthExpenses, isEmpty);
    },
  );

  test(
    'addExpense inserts and refreshes aggregates for the visible month',
    () async {
      final today = Expense.dateOnly(DateTime.now());

      await cubit.addExpense(
        date: today,
        category: 'Makanan',
        description: 'Nasi goreng',
        amount: 25000,
      );

      expect(cubit.state.monthExpenses, hasLength(1));
      expect(cubit.state.monthTotal, 25000);
      expect(cubit.state.transactionCount, 1);
      expect(cubit.state.categoryTotals, {'Makanan': 25000});
      expect(cubit.state.categories, contains('Makanan'));
      expect(cubit.state.dayTotal(today), 25000);
    },
  );

  test('addExpense trims category and description', () async {
    await cubit.addExpense(
      date: DateTime.now(),
      category: '  Transport  ',
      description: '  Ojek  ',
      amount: 15000,
    );

    final expense = cubit.state.monthExpenses.single;
    expect(expense.category, 'Transport');
    expect(expense.description, 'Ojek');
  });

  test('addExpense for another month navigates to that month', () async {
    final target = DateTime(DateTime.now().year, DateTime.now().month - 2, 5);

    await cubit.addExpense(
      date: target,
      category: 'Belanja',
      description: 'Sepatu',
      amount: 500000,
    );

    expect(cubit.state.visibleMonth, DateTime(target.year, target.month));
    expect(cubit.state.monthExpenses, hasLength(1));
    expect(cubit.state.monthTotal, 500000);
  });

  test('updateExpense reflects new amount', () async {
    await cubit.addExpense(
      date: DateTime.now(),
      category: 'Makanan',
      description: 'Kopi',
      amount: 20000,
    );
    final id = cubit.state.monthExpenses.single.id;

    await cubit.updateExpense(
      id: id,
      date: cubit.state.monthExpenses.single.date,
      category: 'Minuman',
      description: 'Kopi susu',
      amount: 30000,
    );

    final expense = cubit.state.monthExpenses.single;
    expect(expense.amount, 30000);
    expect(expense.category, 'Minuman');
    expect(expense.description, 'Kopi susu');
    expect(cubit.state.monthTotal, 30000);
  });

  test('deleteExpense removes the expense and drops totals', () async {
    await cubit.addExpense(
      date: DateTime.now(),
      category: 'Hiburan',
      description: 'Bioskop',
      amount: 60000,
    );
    expect(cubit.state.monthTotal, 60000);

    await cubit.deleteExpense(cubit.state.monthExpenses.single.id);

    expect(cubit.state.monthExpenses, isEmpty);
    expect(cubit.state.monthTotal, 0);
  });

  test('prevMonth and nextMonth move the visible month', () async {
    final start = cubit.state.visibleMonth;

    await cubit.nextMonth();
    expect(cubit.state.visibleMonth, DateTime(start.year, start.month + 1));

    await cubit.prevMonth();
    await cubit.prevMonth();
    expect(cubit.state.visibleMonth, DateTime(start.year, start.month - 1));
  });

  test('changing month resets a selected day that falls outside it', () async {
    await cubit.prevMonth();

    expect(
      Expense.sameMonth(cubit.state.selectedDay, cubit.state.visibleMonth),
      isTrue,
    );
    expect(cubit.state.selectedDay.day, 1);
  });

  test('setSelectedDay ignores the time component', () async {
    final day = DateTime(2026, 3, 14, 21, 45);

    await cubit.setSelectedDay(day);

    expect(cubit.state.selectedDay, DateTime(2026, 3, 14));
  });
}
