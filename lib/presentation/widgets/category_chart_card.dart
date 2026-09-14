import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/category.dart';

class CategoryChartCard extends StatelessWidget {
  final Map<String, int> categoryTotals;
  final int monthTotal;

  const CategoryChartCard({
    super.key,
    required this.categoryTotals,
    required this.monthTotal,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty || monthTotal == 0) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: AppStyle.cardDecoration(),
        child: Column(
          children: [
            Text(
              'Ringkasan Kategori',
              style: AppStyle.heading.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.pie_chart_outline_rounded,
              size: 48,
              color: AppStyle.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada data untuk bulan ini',
              style: AppStyle.body.copyWith(color: AppStyle.textSecondary),
            ),
          ],
        ),
      );
    }

    final sorted = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final sections = sorted.map((entry) {
      final color = CategoryColors.forName(entry.key);
      final pct = entry.value / monthTotal * 100;
      return PieChartSectionData(
        value: entry.value.toDouble(),
        color: color,
        radius: 52,
        title: pct >= 8 ? '${pct.toStringAsFixed(0)}%' : '',
        titleStyle: AppStyle.caption.copyWith(
          fontWeight: FontWeight.w800,
          color: AppStyle.textPrimary,
        ),
      );
    }).toList();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: AppStyle.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Ringkasan Kategori',
            style: AppStyle.heading.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 2,
                    centerSpaceRadius: 48,
                    startDegreeOffset: -90,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total',
                      style: AppStyle.caption.copyWith(
                        color: AppStyle.textMuted,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.compact(monthTotal),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...sorted.map((entry) {
            final color = CategoryColors.forName(entry.key);
            final pct = entry.value / monthTotal * 100;
            final isTop = entry == sorted.first;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.key,
                      style: AppStyle.bodySm.copyWith(
                        fontWeight: isTop ? FontWeight.w800 : FontWeight.w600,
                        color: isTop ? AppStyle.ready : AppStyle.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: AppStyle.caption.copyWith(color: AppStyle.textMuted),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(entry.value),
                    style: AppStyle.bodySm.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
