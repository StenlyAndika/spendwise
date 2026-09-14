import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';
import '../widgets/expense_actions.dart';
import '../widgets/expense_log_card.dart';
import '../widgets/metric_cards_row.dart';
import '../widgets/month_calendar_card.dart';
import '../widgets/workspace_app_bar.dart';
import 'add_expense_page.dart';
import 'backup_page.dart';
import 'spend_history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showMonthCard = true;

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

  Future<void> _openAddExpense(ExpenseCubit cubit) async {
    final saved = await AddExpensePage.open(
      context,
      initialDate: cubit.state.selectedDay,
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengeluaran berhasil disimpan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final cubit = context.read<ExpenseCubit>();
        final selectedDay = state.selectedDay;
        final dayExpenses = state.expensesForDay(selectedDay);
        final dayTotal = state.dayTotal(selectedDay);

        return Scaffold(
          appBar: WorkspaceAppBar(
            title: 'Spendwise',
            subtitle: 'Catat · Review · Analisa',
            monthLabel: _monthLabel(state.visibleMonth),
            onPrevMonth: cubit.prevMonth,
            onNextMonth: cubit.nextMonth,
            onSettings: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BackupPage()),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ExpenseMetricCardsRow(
                monthTotal: CurrencyFormatter.format(state.monthTotal),
                transactionCount: state.transactionCount,
              ),
              Expanded(
                child: state.loading
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          const minLogHeight = 72.0;
                          final calendarMaxHeight =
                              (constraints.maxHeight - minLogHeight).clamp(
                                180.0,
                                constraints.maxHeight,
                              );

                          return Column(
                            children: [
                              Expanded(
                                child: RefreshIndicator(
                                  onRefresh: cubit.refresh,
                                  child: _dayLogArea(
                                    selectedDay: selectedDay,
                                    expenses: dayExpenses,
                                    dayTotal: dayTotal,
                                  ),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: calendarMaxHeight,
                                ),
                                child: SingleChildScrollView(
                                  child: _calendarPanel(state, cubit),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: const BoxDecoration(
                color: AppStyle.surface,
                border: Border(top: BorderSide(color: AppStyle.borderLight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => SpendHistoryPage.open(context),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: const Text('Riwayat'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: () => _openAddExpense(cubit),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Tambah Pengeluaran'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _dayLogArea({
    required DateTime selectedDay,
    required List<Expense> expenses,
    required int dayTotal,
  }) {
    final dateLabel = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(selectedDay);

    if (expenses.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: _statusView(
                icon: Icons.receipt_long_outlined,
                color: AppStyle.primary,
                title: 'Belum ada pengeluaran',
                subtitle: 'Tidak ada pengeluaran pada $dateLabel.',
              ),
            ),
          );
        },
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateLabel,
                    style: AppStyle.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppStyle.textSecondary,
                    ),
                  ),
                ),
                Text(
                  CurrencyFormatter.format(dayTotal),
                  style: AppStyle.bodySm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppStyle.ready,
                  ),
                ),
              ],
            ),
          ),
          ExpenseLogCard(
            expenses: expenses,
            compact: true,
            showDate: false,
            onEdit: (expense) => editExpense(context, expense),
            onDelete: (expense) => confirmDeleteExpense(context, expense),
          ),
        ],
      ),
    );
  }

  Widget _statusView({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppStyle.heading.copyWith(fontSize: 17)),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppStyle.body.copyWith(
                color: AppStyle.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calendarPanel(ExpenseState state, ExpenseCubit cubit) {
    final statusLabel = state.monthTotal > 0
        ? 'Total ${DateFormat('MMMM yyyy', 'id_ID').format(state.visibleMonth)}: ${CurrencyFormatter.format(state.monthTotal)}'
        : 'Belum ada pengeluaran di bulan ini.';

    return Material(
      color: AppStyle.surface,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppStyle.borderLight)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  size: 17,
                  color: AppStyle.textMuted,
                ),
                const SizedBox(width: 7),
                Text(
                  'KALENDER PENGELUARAN',
                  style: AppStyle.caption.copyWith(
                    color: AppStyle.textMuted,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: _showMonthCard
                      ? 'Sembunyikan kalender'
                      : 'Tampilkan kalender',
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      setState(() => _showMonthCard = !_showMonthCard),
                  icon: AnimatedRotation(
                    turns: _showMonthCard ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: const Icon(Icons.expand_more_rounded, size: 20),
                  ),
                ),
              ],
            ),
            Text(
              statusLabel,
              style: AppStyle.bodySm.copyWith(
                color: AppStyle.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                opacity: _showMonthCard ? 1 : 0,
                child: _showMonthCard
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 10),
                          MonthCalendarCard(
                            visibleMonth: state.visibleMonth,
                            selectedDay: state.selectedDay,
                            dayTotals: state.dayTotals,
                            showMonthNavigation: false,
                            onDayTap: cubit.setSelectedDay,
                          ),
                        ],
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
