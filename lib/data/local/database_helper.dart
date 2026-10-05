import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../domain/models/category.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'spendwise.db';
  static const _dbVersion = 4;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _open();
    return _database!;
  }

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        name TEXT PRIMARY KEY
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        amount INTEGER NOT NULL
      )
    ''');
    await _createIndexes(db);

    final batch = db.batch();
    for (final name in CategoryColors.palette.keys) {
      batch.insert('categories', {'name': name});
    }
    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createIndexes(db);
    }
    if (oldVersion < 3) {
      await _renameCategory(db, 'Nyawer', 'Minuman');
    }
    if (oldVersion < 4) {
      await _renameCategory(db, 'Hiburan', 'Jajan');
      await _renameCategory(db, 'Kesehatan', 'Topup');
    }
  }

  /// Moves [from] to [to] across `expenses` and `categories` so historical
  /// spending keeps its category instead of being orphaned.
  Future<void> _renameCategory(
    DatabaseExecutor db,
    String from,
    String to,
  ) async {
    await db.update(
      'expenses',
      {'category': to},
      where: 'category = ?',
      whereArgs: [from],
    );
    await db.delete('categories', where: 'name = ?', whereArgs: [from]);
    await db.insert(
      'categories',
      {'name': to},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_expenses_date ON expenses(date)',
    );
  }
}
