import 'package:flutter/material.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';

enum SpendDayKind { noSpend, lowSpend, mediumSpend, highSpend }

SpendDayKind spendKindForAmount(int amount) {
  if (amount <= 0) return SpendDayKind.noSpend;
  if (amount < 100000) return SpendDayKind.lowSpend;
  if (amount <= 500000) return SpendDayKind.mediumSpend;
  return SpendDayKind.highSpend;
}

class MonthCalendarCard extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime? selectedDay;
  final Map<DateTime, int> dayTotals;
  final ValueChanged<DateTime>? onDayTap;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final bool showMonthNavigation;

  static const weekdayLabels = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  const MonthCalendarCard({
    super.key,
    required this.visibleMonth,
    required this.dayTotals,
    this.selectedDay,
    this.onDayTap,
    this.onPrevMonth,
    this.onNextMonth,
    this.showMonthNavigation = true,
  });

  String _monthTitle(DateTime month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${names[month.month - 1]} ${month.year}';
  }

  int _totalForDay(DateTime date) {
    final key = Expense.dateOnly(date);
    return dayTotals[key] ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final year = visibleMonth.year;
    final month = visibleMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final leadingBlanks = DateTime(year, month, 1).weekday - 1;
    final rows = ((leadingBlanks + daysInMonth) / 7).ceil();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
      decoration: AppStyle.cardDecoration(color: AppStyle.surfaceLight),
      child: Column(
        children: [
          if (showMonthNavigation)
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onPrevMonth,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    _monthTitle(visibleMonth),
                    textAlign: TextAlign.center,
                    style: AppStyle.heading.copyWith(fontSize: 14),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _monthTitle(visibleMonth),
                textAlign: TextAlign.center,
                style: AppStyle.heading.copyWith(fontSize: 14),
              ),
            ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final label in weekdayLabels)
                Expanded(
                  child: Center(
                    child: Text(
                      label,
                      style: AppStyle.caption.copyWith(
                        color: AppStyle.textMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          for (var row = 0; row < rows; row++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  for (var col = 0; col < 7; col++)
                    Expanded(
                      child: _DayCell(
                        dayNum: row * 7 + col - leadingBlanks + 1,
                        daysInMonth: daysInMonth,
                        year: year,
                        month: month,
                        selectedDay: selectedDay,
                        dayTotal: (day) => _totalForDay(day),
                        onDayTap: onDayTap,
                      ),
                    ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              _LegendDot(
                color: AppStyle.ready.withValues(alpha: 0.35),
                label: '< 100k',
              ),
              _LegendDot(
                color: AppStyle.ready.withValues(alpha: 0.55),
                label: '100k–500k',
              ),
              _LegendDot(
                color: AppStyle.ready.withValues(alpha: 0.85),
                label: '> 500k',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppStyle.caption.copyWith(color: AppStyle.textMuted),
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final int dayNum;
  final int daysInMonth;
  final int year;
  final int month;
  final DateTime? selectedDay;
  final int Function(DateTime date) dayTotal;
  final ValueChanged<DateTime>? onDayTap;

  const _DayCell({
    required this.dayNum,
    required this.daysInMonth,
    required this.year,
    required this.month,
    required this.selectedDay,
    required this.dayTotal,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dayNum < 1 || dayNum > daysInMonth) {
      return const SizedBox(height: 44);
    }

    final date = DateTime(year, month, dayNum);
    final total = dayTotal(date);
    final kind = spendKindForAmount(total);
    final selected = selectedDay != null && Expense.sameDay(date, selectedDay!);
    final weekend =
        date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;

    Color bg = Colors.transparent;
    Color fg = weekend ? AppStyle.textMuted : AppStyle.textPrimary;
    var bold = false;

    switch (kind) {
      case SpendDayKind.lowSpend:
        bg = AppStyle.ready.withValues(alpha: 0.22);
        fg = AppStyle.ready;
        bold = true;
      case SpendDayKind.mediumSpend:
        bg = AppStyle.ready.withValues(alpha: 0.38);
        fg = AppStyle.ready;
        bold = true;
      case SpendDayKind.highSpend:
        bg = AppStyle.ready.withValues(alpha: 0.55);
        fg = AppStyle.ready;
        bold = true;
      case SpendDayKind.noSpend:
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => onDayTap?.call(date),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: selected
                  ? Border.all(color: AppStyle.primary.withValues(alpha: 0.85))
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$dayNum',
                  style: AppStyle.bodySm.copyWith(
                    color: fg,
                    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 11,
                    height: 1.1,
                  ),
                ),
                if (total > 0)
                  Text(
                    CurrencyFormatter.compact(total),
                    style: AppStyle.caption.copyWith(
                      color: fg,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
