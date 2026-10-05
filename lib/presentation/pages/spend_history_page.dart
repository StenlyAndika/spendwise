import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../widgets/category_chart_card.dart';
import '../widgets/category_filter_sheet.dart';
import '../widgets/expense_actions.dart';
import '../widgets/expense_log_card.dart';
import '../widgets/workspace_app_bar.dart';

class SpendHistoryPage extends StatelessWidget {
  const SpendHistoryPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SpendHistoryPage()));
  }

  String _monthLabel(DateTime month) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }

  String _monthSubtitle(DateTime month) {
    return DateFormat('MMMM yyyy', 'id_ID').format(month);
  }

  /// Categories offered by the filter sheet: everything spent this month, plus
  /// anything already selected, so a selection made in another month stays
  /// visible and deselectable instead of silently vanishing.
  List<String> _filterableCategories(ExpenseState state) =>
      [
        ...{
          ...state.categoryTotals.keys,
          ...state.selectedCategories,
        },
      ]..sort();

  void _openFilter(BuildContext context, ExpenseState state) {
    CategoryFilterSheet.show(
      context,
      categories: _filterableCategories(state),
      totals: state.categoryTotals,
      selected: state.selectedCategories,
      onApply: context.read<ExpenseCubit>().setCategoryFilter,
    );
  }

  Widget _filterSummary(ExpenseState state, List<Expense> filtered) {
    final total = filtered.fold(0, (sum, e) => sum + e.amount);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
      child: Row(
        children: [
          const Icon(
            Icons.filter_alt_outlined,
            size: 14,
            color: AppStyle.primary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${state.selectedCategories.join(', ')} · '
              '${filtered.length} dari ${state.transactionCount} item · '
              '${CurrencyFormatter.format(total)}',
              style: AppStyle.caption.copyWith(
                color: AppStyle.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final cubit = context.read<ExpenseCubit>();
        final month = state.visibleMonth;
        final filtered = state.filteredExpenses;
        final hasFilter = state.hasCategoryFilter;
        final canFilter = hasFilter || state.categoryTotals.isNotEmpty;

        return Scaffold(
          appBar: WorkspaceAppBar(
            title: 'Riwayat Pengeluaran',
            subtitle: _monthSubtitle(month),
            monthLabel: _monthLabel(month),
            onPrevMonth: cubit.prevMonth,
            onNextMonth: cubit.nextMonth,
            filterActive: hasFilter,
            onFilter: canFilter ? () => _openFilter(context, state) : null,
          ),
          body: state.loading
              ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
              : RefreshIndicator(
                  onRefresh: cubit.refresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Column(
                      children: [
                        // Intentionally unfiltered: the chart stays a
                        // full-month context panel while the list narrows.
                        CategoryChartCard(
                          categoryTotals: state.categoryTotals,
                          monthTotal: state.monthTotal,
                        ),
                        if (hasFilter) ...[
                          const SizedBox(height: 10),
                          _filterSummary(state, filtered),
                        ],
                        const SizedBox(height: 10),
                        ExpenseLogCard(
                          expenses: filtered,
                          emptyTitle: hasFilter
                              ? 'Tidak ada pengeluaran di kategori ini'
                              : 'Belum ada pengeluaran',
                          emptyMessage: hasFilter
                              ? 'Coba pilih kategori lain atau hapus filter.'
                              : 'Tambah pengeluaran untuk mulai mencatat.',
                          onEdit: (expense) => editExpense(context, expense),
                          onDelete: (expense) =>
                              confirmDeleteExpense(context, expense),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
