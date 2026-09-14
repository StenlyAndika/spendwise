import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/data/backup/backup_codec.dart';
import 'package:spendwise/domain/models/expense.dart';

void main() {
  test('BackupCodec round-trip preserves data', () {
    final expenses = [
      Expense(
        id: '1',
        date: DateTime(2026, 9, 13),
        category: 'Langganan',
        description: 'Langganan Cursor',
        amount: 380000,
      ),
    ];
    const categories = ['Langganan', 'Makanan'];

    final json = BackupCodec.encode(categories: categories, expenses: expenses);
    final decoded = BackupCodec.decode(json);

    expect(decoded.version, BackupCodec.currentVersion);
    expect(decoded.categories, categories);
    expect(decoded.expenses.length, 1);
    expect(decoded.expenses.first.description, 'Langganan Cursor');
    expect(decoded.expenses.first.amount, 380000);
  });

  test('BackupCodec rejects unsupported version', () {
    expect(
      () => BackupCodec.decode('{"version":99,"categories":[],"expenses":[]}'),
      throwsFormatException,
    );
  });
}
