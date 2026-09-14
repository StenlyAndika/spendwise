import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../widgets/category_chart_card.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final cubit = context.read<ExpenseCubit>();
        final month = state.visibleMonth;

        return Scaffold(
          appBar: WorkspaceAppBar(
            title: 'Riwayat Pengeluaran',
            subtitle: _monthSubtitle(month),
            monthLabel: _monthLabel(month),
            onPrevMonth: cubit.prevMonth,
            onNextMonth: cubit.nextMonth,
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
                        CategoryChartCard(
                          categoryTotals: state.categoryTotals,
                          monthTotal: state.monthTotal,
                        ),
                        const SizedBox(height: 10),
                        ExpenseLogCard(
                          expenses: state.monthExpenses,
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
