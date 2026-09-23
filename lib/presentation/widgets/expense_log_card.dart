import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/category.dart';
import '../../domain/models/expense.dart';

class ExpenseLogCard extends StatelessWidget {
  final List<Expense> expenses;
  final bool compact;
  final bool showDate;
  final void Function(Expense expense)? onEdit;
  final void Function(Expense expense)? onDelete;

  const ExpenseLogCard({
    super.key,
    required this.expenses,
    this.compact = false,
    this.showDate = true,
    this.onEdit,
    this.onDelete,
  });

  bool get _hasActions => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: AppStyle.cardDecoration(),
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 40, color: AppStyle.textMuted.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text('Belum ada pengeluaran', style: AppStyle.heading.copyWith(fontSize: 14)),
            const SizedBox(height: 4),
            Text(
              'Tambah pengeluaran untuk mulai mencatat.',
              textAlign: TextAlign.center,
              style: AppStyle.body.copyWith(color: AppStyle.textSecondary),
            ),
          ],
        ),
      );
    }

    if (compact) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: AppStyle.cardDecoration(),
        child: Column(children: [for (final expense in expenses) _compactRow(expense)]),
      );
    }

    final groups = <DateTime, List<Expense>>{};
    final order = <DateTime>[];

    for (final expense in expenses) {
      final day = Expense.dateOnly(expense.date);
      if (!groups.containsKey(day)) {
        groups[day] = [];
        order.add(day);
      }
      groups[day]!.add(expense);
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: AppStyle.cardDecoration(),
      child: Column(children: [for (final day in order) ..._buildDayGroup(day, groups[day]!)]),
    );
  }

  List<Widget> _buildDayGroup(DateTime day, List<Expense> items) {
    final dayTotal = items.fold(0, (sum, e) => sum + e.amount);
    final dateLabel = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(day);

    return [
      _dateHeader(dateLabel, items.length),
      for (final expense in items) _expenseRow(expense),
      _dateFooter(dayTotal),
    ];
  }

  Widget _dateHeader(String date, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.paddingLg, vertical: 8),
      decoration: const BoxDecoration(
        color: AppStyle.surfaceLight,
        border: Border(bottom: BorderSide(color: AppStyle.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              date,
              style: AppStyle.bodySm.copyWith(fontWeight: FontWeight.w700, color: AppStyle.textSecondary),
            ),
          ),
          Text('$count item', style: AppStyle.caption.copyWith(color: AppStyle.textMuted)),
        ],
      ),
    );
  }

  Widget _compactRow(Expense expense) {
    final color = CategoryColors.forName(expense.category);
    final dateLabel = DateFormat('d MMM', 'id_ID').format(expense.date);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.paddingLg, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppStyle.borderLight)),
      ),
      child: Row(
        // Center rather than `start`: the chip, the amount and the overflow
        // menu all have different intrinsic heights, so starting them all at
        // the top makes the one-line text look misaligned.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showDate) ...[
            SizedBox(
              width: 42,
              child: Text(
                dateLabel,
                style: AppStyle.caption.copyWith(color: AppStyle.textMuted, fontWeight: FontWeight.w700),
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              expense.category,
              style: AppStyle.caption.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(expense.description, style: AppStyle.body.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: AppStyle.bodySm.copyWith(fontWeight: FontWeight.w800, color: AppStyle.ready),
          ),
          if (_hasActions) _actionMenu(expense),
        ],
      ),
    );
  }

  Widget _expenseRow(Expense expense) {
    final color = CategoryColors.forName(expense.category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.paddingLg, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppStyle.borderLight)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              expense.category,
              style: AppStyle.caption.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(expense.description, style: AppStyle.body.copyWith(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Text(
            CurrencyFormatter.format(expense.amount),
            style: AppStyle.bodySm.copyWith(fontWeight: FontWeight.w800, color: AppStyle.ready),
          ),
          if (_hasActions) _actionMenu(expense),
        ],
      ),
    );
  }

  Widget _actionMenu(Expense expense) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit?.call(expense);
        } else if (value == 'delete') {
          onDelete?.call(expense);
        }
      },
      itemBuilder: (context) => [
        if (onEdit != null) const PopupMenuItem(value: 'edit', child: Text('Edit')),
        if (onDelete != null) const PopupMenuItem(value: 'delete', child: Text('Hapus')),
      ],
    );
  }

  Widget _dateFooter(int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppStyle.paddingLg, vertical: 7),
      decoration: BoxDecoration(
        color: AppStyle.surfaceRaised.withValues(alpha: 0.4),
        border: const Border(bottom: BorderSide(color: AppStyle.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Subtotal: ', style: AppStyle.caption.copyWith(color: AppStyle.textMuted)),
          Text(CurrencyFormatter.format(total), style: AppStyle.bodySm.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
