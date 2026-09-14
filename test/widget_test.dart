import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'fakes/fake_expense_repository.dart';
import 'package:spendwise/presentation/pages/home_page.dart';
import 'package:spendwise/presentation/providers/expense_provider.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });
  testWidgets('Home page shows Spendwise title', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ExpenseProvider(FakeExpenseRepository()),
        child: const MaterialApp(home: HomePage()),
      ),
    );

    expect(find.text('Spendwise'), findsOneWidget);
  });

  testWidgets('Riwayat button opens spend history page', (tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 900));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ExpenseProvider(FakeExpenseRepository()),
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
