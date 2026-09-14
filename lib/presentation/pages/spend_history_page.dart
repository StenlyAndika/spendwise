import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/expense_provider.dart';
import '../widgets/category_chart_card.dart';
import '../widgets/expense_actions.dart';
import '../widgets/expense_log_card.dart';
import '../widgets/workspace_app_bar.dart';

class SpendHistoryPage extends StatelessWidget {
  const SpendHistoryPage({super.key});

  static Future<void> open(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SpendHistoryPage()),
    );
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
    final provider = context.watch<ExpenseProvider>();
    final month = provider.visibleMonth;

    return Scaffold(
      appBar: WorkspaceAppBar(
        title: 'Riwayat Pengeluaran',
        subtitle: _monthSubtitle(month),
        monthLabel: _monthLabel(month),
        onPrevMonth: provider.prevMonth,
        onNextMonth: provider.nextMonth,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2.5))
          : RefreshIndicator(
              onRefresh: provider.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  children: [
                    CategoryChartCard(
                      categoryTotals: provider.categoryTotals,
                      monthTotal: provider.monthTotal,
                    ),
                    const SizedBox(height: 10),
                    ExpenseLogCard(
                      expenses: provider.monthExpenses,
                      onEdit: (expense) => editExpense(context, expense),
                      onDelete: (expense) =>
                          confirmDeleteExpense(context, expense),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
