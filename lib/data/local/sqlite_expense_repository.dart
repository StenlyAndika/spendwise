import 'package:sqflite/sqflite.dart';

import '../../domain/models/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../backup/backup_codec.dart';

class SqliteExpenseRepository implements ExpenseRepository {
  final Database _db;

  SqliteExpenseRepository(this._db);

  String _monthPrefix(DateTime month) =>
      '${month.year.toString().padLeft(4, '0')}-'
      '${month.month.toString().padLeft(2, '0')}-';

  @override
  Future<List<String>> getCategories() async {
    final rows = await _db.query(
      'categories',
      columns: ['name'],
      orderBy: 'name ASC',
    );
    return rows.map((row) => row['name'] as String).toList();
  }

  @override
  Future<void> addExpense(Expense expense) async {
    await _db.transaction((txn) async {
      await txn.insert(
        'expenses',
        _expenseToRow(expense),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await _upsertCategory(txn, expense.category);
    });
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await _db.transaction((txn) async {
      await txn.update(
        'expenses',
        _expenseToRow(expense),
        where: 'id = ?',
        whereArgs: [expense.id],
      );
      await _upsertCategory(txn, expense.category);
    });
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<Expense>> getExpensesForMonth(DateTime month) async {
    final rows = await _db.query(
      'expenses',
      where: 'date LIKE ?',
      whereArgs: ['${_monthPrefix(month)}%'],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(_expenseFromRow).toList();
  }

  @override
  Future<List<Expense>> getExpensesForDay(DateTime day) async {
    final rows = await _db.query(
      'expenses',
      where: 'date = ?',
      whereArgs: [_formatDate(day)],
      orderBy: 'id DESC',
    );
    return rows.map(_expenseFromRow).toList();
  }

  @override
  Future<Map<String, int>> getCategoryTotalsForMonth(DateTime month) async {
    final rows = await _db.rawQuery(
      '''
      SELECT category, SUM(amount) AS total
      FROM expenses
      WHERE date LIKE ?
      GROUP BY category
      ''',
      ['${_monthPrefix(month)}%'],
    );

    return {
      for (final row in rows)
        row['category'] as String: row['total'] as int,
    };
  }

  @override
  Future<Map<DateTime, int>> getDayTotalsForMonth(DateTime month) async {
    final rows = await _db.rawQuery(
      '''
      SELECT date, SUM(amount) AS total
      FROM expenses
      WHERE date LIKE ?
      GROUP BY date
      ''',
      ['${_monthPrefix(month)}%'],
    );

    final totals = <DateTime, int>{};
    for (final row in rows) {
      final date = DateTime.parse(row['date'] as String);
      totals[Expense.dateOnly(date)] = row['total'] as int;
    }
    return totals;
  }

  @override
  Future<int> getDayTotal(DateTime day) async {
    final rows = await _db.rawQuery(
      'SELECT COALESCE(SUM(amount), 0) AS total FROM expenses WHERE date = ?',
      [_formatDate(day)],
    );
    return rows.first['total'] as int;
  }

  @override
  Future<String> exportBackupJson() async {
    final categories = await getCategories();
    final rows = await _db.query('expenses', orderBy: 'date ASC, id ASC');
    final expenses = rows.map(_expenseFromRow).toList();
    return BackupCodec.encode(categories: categories, expenses: expenses);
  }

  @override
  Future<void> importBackupJson(String json, {required bool replace}) async {
    final backup = BackupCodec.decode(json);
    if (!replace) {
      throw UnsupportedError('Hanya mode replace yang didukung.');
    }

    await _db.transaction((txn) async {
      await txn.delete('expenses');
      await txn.delete('categories');

      final batch = txn.batch();
      for (final category in backup.categories) {
        batch.insert(
          'categories',
          {'name': category},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      for (final expense in backup.expenses) {
        batch.insert(
          'expenses',
          _expenseToRow(expense),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        batch.insert(
          'categories',
          {'name': expense.category.trim()},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> _upsertCategory(DatabaseExecutor txn, String category) async {
    final name = category.trim();
    if (name.isEmpty) return;
    await txn.insert(
      'categories',
      {'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Map<String, Object> _expenseToRow(Expense expense) => {
        'id': expense.id,
        'date': _formatDate(expense.date),
        'category': expense.category,
        'description': expense.description,
        'amount': expense.amount,
      };

  Expense _expenseFromRow(Map<String, Object?> row) {
    final date = DateTime.parse(row['date'] as String);
    return Expense(
      id: row['id'] as String,
      date: Expense.dateOnly(date),
      category: row['category'] as String,
      description: row['description'] as String,
      amount: row['amount'] as int,
    );
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
