import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:spendwise/core/theme/app_style.dart';
import 'package:spendwise/domain/models/expense.dart';
import 'package:spendwise/presentation/widgets/expense_log_card.dart';

/// Guards the layout of `ExpenseLogCard`, which `widget_test.dart` never
/// renders (it only walks the home page, where the log is usually empty).
///
/// The row is a `Row` with a mix of intrinsic heights: a date column, a
/// category chip, the description and the amount. Any of them can be laid out
/// with the wrong flex, which throws a runtime assert rather than a
/// `flutter analyze` error, so these tests pump the real widget.
void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  Expense expenseAt(DateTime date, {String description = 'Kopi susu'}) =>
      Expense(
        id: '1',
        date: date,
        category: 'Minuman',
        description: description,
        amount: 25000,
      );

  Future<void> pumpCard(
    WidgetTester tester,
    List<Expense> expenses, {
    required bool compact,
    required bool showDate,
    void Function(Expense)? onEdit,
    void Function(Expense)? onDelete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppStyle.lightTheme,
        home: Scaffold(
          body: ExpenseLogCard(
            expenses: expenses,
            compact: compact,
            showDate: showDate,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
        ),
      ),
    );
  }

  testWidgets('compact row with a date lays out without error', (tester) async {
    await pumpCard(
      tester,
      [expenseAt(DateTime(2026, 9, 13))],
      compact: true,
      showDate: true,
    );

    expect(tester.takeException(), isNull);
    expect(find.text('13 Sep'), findsOneWidget);
    expect(find.text('Kopi susu'), findsOneWidget);
  });

  testWidgets('compact row is vertically centered on the date', (tester) async {
    await pumpCard(
      tester,
      [expenseAt(DateTime(2026, 9, 13))],
      compact: true,
      showDate: true,
    );

    // The date, the description and the amount should share a centre line;
    // a `CrossAxisAlignment.start` row leaves the date pinned to the top.
    final dateCenter = tester.getCenter(find.text('13 Sep')).dy;
    final descCenter = tester.getCenter(find.text('Kopi susu')).dy;
    final amountCenter = tester.getCenter(find.text('Rp 25.000')).dy;

    expect(dateCenter, moreOrLessEquals(descCenter, epsilon: 0.5));
    expect(amountCenter, moreOrLessEquals(descCenter, epsilon: 0.5));
  });
  testWidgets('rows keep their intrinsic height, not the parent height', (
    tester,
  ) async {
    // The cards explicitly clip (`Clip.antiAlias`) and the home page clamps the
    // log into a `ConstrainedBox`, so content being cut off is by design. What
    // must never happen is a *row* stretching to fill an unbounded or overly
    // tall parent, which is what the removed `Expanded` did here.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppStyle.lightTheme,
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: ExpenseLogCard(
              expenses: [expenseAt(DateTime(2026, 9, 13))],
              compact: true,
              showDate: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final rowHeight = tester.getSize(
      find.ancestor(
        of: find.text('Kopi susu'),
        matching: find.byType(Row),
      ).first,
    ).height;

    // One line of 13px text plus 10px of vertical padding on each side.
    expect(rowHeight, lessThan(60));
  });

  testWidgets('grouped row with action menu lays out and centers', (
    tester,
  ) async {
    await pumpCard(
      tester,
      [expenseAt(DateTime(2026, 9, 13))],
      compact: false,
      showDate: true,
      onEdit: (_) {},
      onDelete: (_) {},
    );

    expect(tester.takeException(), isNull);

    // The grouped layout also renders a per-day subtotal footer carrying the
    // same text, so scope the lookup to the row itself.
    final row = find.ancestor(
      of: find.text('Kopi susu'),
      matching: find.byType(Row),
    );
    final chipCenter = tester.getCenter(
      find.descendant(of: row.first, matching: find.text('Minuman')),
    ).dy;
    final amountCenter = tester.getCenter(
      find.descendant(of: row.first, matching: find.text('Rp 25.000')),
    ).dy;
    expect(chipCenter, moreOrLessEquals(amountCenter, epsilon: 0.5));
  });

  testWidgets('long description does not overflow the row', (tester) async {
    await pumpCard(
      tester,
      [
        expenseAt(
          DateTime(2026, 9, 13),
          description:
              'Langganan tahunan yang keterangannya sangat panjang sekali '
              'sehingga melebihi lebar baris yang tersedia',
        ),
      ],
      compact: true,
      showDate: true,
    );

    expect(tester.takeException(), isNull);
  });
}
