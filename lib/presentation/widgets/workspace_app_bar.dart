import 'package:flutter/material.dart';

import '../../core/theme/app_style.dart';

class WorkspaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final String? monthLabel;
  final VoidCallback? onPrevMonth;
  final VoidCallback? onNextMonth;
  final VoidCallback? onSettings;

  const WorkspaceAppBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.monthLabel,
    this.onPrevMonth,
    this.onNextMonth,
    this.onSettings,
  });

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Text(
            subtitle,
            style: AppStyle.caption.copyWith(
              color: AppStyle.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      actions: [
        if (monthLabel != null) ...[
          IconButton(
            tooltip: 'Bulan sebelumnya',
            onPressed: onPrevMonth,
            icon: const Icon(Icons.chevron_left_rounded),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Center(
              child: Text(
                monthLabel!,
                style: AppStyle.bodySm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppStyle.textSecondary,
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Bulan berikutnya',
            onPressed: onNextMonth,
            icon: const Icon(Icons.chevron_right_rounded),
          ),
        ],
        if (onSettings != null)
          IconButton(
            tooltip: 'Backup',
            onPressed: onSettings,
            icon: const Icon(Icons.settings_outlined),
          ),
        const SizedBox(width: 4),
      ],
    );
  }
}
