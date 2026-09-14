import 'dart:convert';

import '../../domain/models/expense.dart';

class BackupData {
  final int version;
  final DateTime exportedAt;
  final List<String> categories;
  final List<Expense> expenses;

  const BackupData({
    required this.version,
    required this.exportedAt,
    required this.categories,
    required this.expenses,
  });
}

class BackupCodec {
  static const currentVersion = 1;

  static String encode({
    required List<String> categories,
    required List<Expense> expenses,
  }) {
    final data = {
      'version': currentVersion,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'categories': categories,
      'expenses': expenses.map(_expenseToJson).toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  static BackupData decode(String json) {
    final raw = jsonDecode(json);
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Backup harus berupa objek JSON.');
    }

    final version = raw['version'];
    if (version is! int || version != currentVersion) {
      throw FormatException('Versi backup tidak didukung: $version');
    }

    final exportedAtRaw = raw['exportedAt'] as String?;
    final exportedAt = exportedAtRaw != null
        ? DateTime.tryParse(exportedAtRaw) ?? DateTime.now().toUtc()
        : DateTime.now().toUtc();

    final categoriesRaw = raw['categories'];
    if (categoriesRaw is! List) {
      throw const FormatException('Field categories tidak valid.');
    }
    final categories = categoriesRaw.map((e) => e.toString()).toList();

    final expensesRaw = raw['expenses'];
    if (expensesRaw is! List) {
      throw const FormatException('Field expenses tidak valid.');
    }

    final expenses = expensesRaw.map(_expenseFromJson).toList();

    return BackupData(
      version: version,
      exportedAt: exportedAt,
      categories: categories,
      expenses: expenses,
    );
  }

  static Map<String, dynamic> _expenseToJson(Expense expense) => {
    'id': expense.id,
    'date': _formatDate(expense.date),
    'category': expense.category,
    'description': expense.description,
    'amount': expense.amount,
  };

  static Expense _expenseFromJson(dynamic raw) {
    if (raw is! Map<String, dynamic>) {
      throw const FormatException('Item expense tidak valid.');
    }

    final id = raw['id']?.toString();
    final dateRaw = raw['date']?.toString();
    final category = raw['category']?.toString();
    final description = raw['description']?.toString();
    final amount = raw['amount'];

    if (id == null ||
        id.isEmpty ||
        dateRaw == null ||
        category == null ||
        category.isEmpty ||
        description == null ||
        description.isEmpty ||
        amount is! int) {
      throw const FormatException('Field expense tidak lengkap.');
    }

    final date = DateTime.tryParse(dateRaw);
    if (date == null) {
      throw FormatException('Tanggal expense tidak valid: $dateRaw');
    }

    return Expense(
      id: id,
      date: Expense.dateOnly(date),
      category: category,
      description: description,
      amount: amount,
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
