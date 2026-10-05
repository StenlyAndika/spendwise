import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'fakes/fake_expense_repository.dart';
import 'package:spendwise/presentation/cubits/expense_cubit.dart';
import 'package:spendwise/presentation/pages/home_page.dart';
import 'package:spendwise/presentation/pages/spend_history_page.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('Home page shows Spendwise title', (tester) async {
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ExpenseCubit(FakeExpenseRepository()),
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.text('Spendwise'), findsOneWidget);
  });

  testWidgets('Riwayat button opens spend history page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    await tester.pumpWidget(
      BlocProvider(
        create: (_) => ExpenseCubit(FakeExpenseRepository()),
        child: const MaterialApp(home: HomePage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();

    expect(find.text('Riwayat Pengeluaran'), findsOneWidget);
    expect(find.text('Ringkasan Kategori'), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('category filter narrows the history list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    final repository = FakeExpenseRepository();
    final cubit = ExpenseCubit(repository);
    final now = DateTime.now();

    await cubit.addExpense(
      date: now,
      category: 'Makanan',
      description: 'Nasi goreng',
      amount: 25000,
    );
    await cubit.addExpense(
      date: now,
      category: 'Transport',
      description: 'Ojek online',
      amount: 15000,
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: SpendHistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    // Unfiltered: both expenses are listed.
    expect(find.text('Nasi goreng'), findsOneWidget);
    expect(find.text('Ojek online'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.filter_list_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter Kategori'), findsOneWidget);

    // "Makanan" also appears as a chip in the list behind the sheet, so
    // target the sheet row by its key.
    await tester.tap(find.byKey(const ValueKey('filter-category-Makanan')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    expect(find.text('Nasi goreng'), findsOneWidget);
    expect(find.text('Ojek online'), findsNothing);
    expect(find.textContaining('1 dari 2 item'), findsOneWidget);

    await cubit.close();
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('clearing the filter restores the full list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    final repository = FakeExpenseRepository();
    final cubit = ExpenseCubit(repository);
    final now = DateTime.now();

    await cubit.addExpense(
      date: now,
      category: 'Makanan',
      description: 'Nasi goreng',
      amount: 25000,
    );
    await cubit.addExpense(
      date: now,
      category: 'Transport',
      description: 'Ojek online',
      amount: 15000,
    );

    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: const MaterialApp(home: SpendHistoryPage()),
      ),
    );
    await tester.pumpAndSettle();

    cubit.setCategoryFilter(['Makanan']);
    await tester.pumpAndSettle();
    expect(find.text('Ojek online'), findsNothing);

    cubit.clearCategoryFilter();
    await tester.pumpAndSettle();

    expect(find.text('Nasi goreng'), findsOneWidget);
    expect(find.text('Ojek online'), findsOneWidget);

    await cubit.close();
    await tester.binding.setSurfaceSize(null);
  });
}
