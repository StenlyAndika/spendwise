import 'package:flutter/material.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/category.dart';

/// Modal picker for narrowing the history list to one or more categories.
///
/// Toggles live in a local draft so dismissing the sheet applies nothing; the
/// chosen selection comes back as the sheet's result and the caller decides
/// what to do with it.
class CategoryFilterSheet extends StatefulWidget {
  final List<String> categories;
  final Map<String, int> totals;
  final List<String> selected;

  const CategoryFilterSheet({
    super.key,
    required this.categories,
    required this.totals,
    required this.selected,
  });

  static Future<void> show(
    BuildContext context, {
    required List<String> categories,
    required Map<String, int> totals,
    required List<String> selected,
    required ValueChanged<List<String>> onApply,
  }) async {
    final result = await showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CategoryFilterSheet(
        categories: categories,
        totals: totals,
        selected: selected,
      ),
    );
    if (result != null) onApply(result);
  }

  @override
  State<CategoryFilterSheet> createState() => _CategoryFilterSheetState();
}

class _CategoryFilterSheetState extends State<CategoryFilterSheet> {
  late final Set<String> _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.selected.toSet();
  }

  void _toggle(String category) {
    setState(() {
      if (!_draft.remove(category)) _draft.add(category);
    });
  }

  void _apply(List<String> categories) => Navigator.of(context).pop(categories);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: AppStyle.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppStyle.radiusLg),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dragHandle(),
            const SizedBox(height: 12),
            _header(),
            const SizedBox(height: 12),
            Flexible(child: _categoryList()),
            const SizedBox(height: 14),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _dragHandle() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppStyle.border,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        const Icon(Icons.filter_list_rounded, size: 18, color: AppStyle.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Filter Kategori',
            style: AppStyle.heading.copyWith(fontSize: 16),
          ),
        ),
        if (_draft.isNotEmpty)
          TextButton(
            onPressed: () => setState(_draft.clear),
            child: const Text('Hapus filter'),
          ),
      ],
    );
  }

  Widget _categoryList() {
    if (widget.categories.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Icon(
              Icons.category_outlined,
              size: 36,
              color: AppStyle.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada kategori di bulan ini',
              style: AppStyle.body.copyWith(color: AppStyle.textSecondary),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 320),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) =>
            _categoryRow(widget.categories[index]),
      ),
    );
  }

  Widget _categoryRow(String category) {
    final color = CategoryColors.forName(category);
    final isSelected = _draft.contains(category);
    final total = widget.totals[category];

    return InkWell(
      // Category names also appear as chips in the list behind the sheet, so
      // rows are addressable by key rather than by label alone.
      key: ValueKey('filter-category-$category'),
      onTap: () => _toggle(category),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                category,
                style: AppStyle.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? AppStyle.textPrimary
                      : AppStyle.textSecondary,
                ),
              ),
            ),
            if (total != null) ...[
              Text(
                CurrencyFormatter.format(total),
                style: AppStyle.caption.copyWith(color: AppStyle.textMuted),
              ),
              const SizedBox(width: 10),
            ],
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.circle_outlined,
              size: 20,
              color: isSelected ? color : AppStyle.border,
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _apply(const []),
            child: const Text('Hapus filter'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton(
            onPressed: () => _apply(_draft.toList()),
            child: const Text('Terapkan'),
          ),
        ),
      ],
    );
  }
}