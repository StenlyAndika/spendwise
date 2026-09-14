import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/models/expense.dart';
import '../cubits/expense_cubit.dart';
import '../pages/add_expense_page.dart';

Future<void> editExpense(BuildContext context, Expense expense) async {
  final saved = await AddExpensePage.openEdit(context, expense: expense);
  if (saved == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengeluaran berhasil diperbarui')),
    );
  }
}

Future<void> confirmDeleteExpense(BuildContext context, Expense expense) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Hapus Pengeluaran'),
      content: Text('Hapus "${expense.description}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );

  if (confirmed != true || !context.mounted) return;

  await context.read<ExpenseCubit>().deleteExpense(expense.id);
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pengeluaran dihapus')));
  }
}
