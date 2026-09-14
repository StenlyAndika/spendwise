class Expense {
  final String id;
  final DateTime date;
  final String category;
  final String description;
  final int amount;

  const Expense({
    required this.id,
    required this.date,
    required this.category,
    required this.description,
    required this.amount,
  });

  Expense copyWith({
    String? id,
    DateTime? date,
    String? category,
    String? description,
    int? amount,
  }) =>
      Expense(
        id: id ?? this.id,
        date: date ?? this.date,
        category: category ?? this.category,
        description: description ?? this.description,
        amount: amount ?? this.amount,
      );

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool sameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;
}
