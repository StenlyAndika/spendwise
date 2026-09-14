import 'package:flutter/material.dart';

import '../../core/theme/app_style.dart';

class MetricCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const MetricCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: AppStyle.cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyle.caption.copyWith(color: AppStyle.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseMetricCardsRow extends StatelessWidget {
  final String monthTotal;
  final int transactionCount;

  const ExpenseMetricCardsRow({
    super.key,
    required this.monthTotal,
    required this.transactionCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: MetricCard(
              icon: Icons.account_balance_wallet_outlined,
              value: monthTotal,
              label: 'Total bulan ini',
              color: AppStyle.ready,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: MetricCard(
              icon: Icons.receipt_long_outlined,
              value: '$transactionCount',
              label: 'Transaksi',
              color: AppStyle.primary,
            ),
          ),
        ],
      ),
    );
  }
}
