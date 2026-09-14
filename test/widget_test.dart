import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'fakes/fake_expense_repository.dart';
import 'package:spendwise/presentation/cubits/expense_cubit.dart';
import 'package:spendwise/presentation/pages/home_page.dart';

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
}
