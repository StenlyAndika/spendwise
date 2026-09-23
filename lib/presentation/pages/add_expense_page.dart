import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_style.dart';
import '../../core/utils/currency_formatter.dart';
import '../../domain/models/expense.dart';
import '../cubits/expense_cubit.dart';
import '../cubits/expense_state.dart';

class AddExpensePage extends StatefulWidget {
  final DateTime? initialDate;
  final Expense? expense;

  const AddExpensePage({super.key, this.initialDate, this.expense});

  bool get isEditing => expense != null;

  static Future<bool?> open(BuildContext context, {DateTime? initialDate}) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddExpensePage(initialDate: initialDate),
      ),
    );
  }

  static Future<bool?> openEdit(
    BuildContext context, {
    required Expense expense,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AddExpensePage(expense: expense)),
    );
  }

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  TextEditingController? _categoryFieldController;

  late DateTime _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final editing = widget.expense;
    _selectedDate = Expense.dateOnly(
      editing?.date ?? widget.initialDate ?? DateTime.now(),
    );
    if (editing != null) {
      _descriptionController.text = editing.description;
      _amountController.text = CurrencyFormatter.format(editing.amount);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = Expense.dateOnly(picked));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parseInput(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Total harus lebih dari 0')));
      return;
    }

    setState(() => _saving = true);

    try {
      final cubit = context.read<ExpenseCubit>();
      final category = (_categoryFieldController?.text ?? '').trim();

      if (widget.isEditing) {
        await cubit.updateExpense(
          id: widget.expense!.id,
          date: _selectedDate,
          category: category,
          description: _descriptionController.text.trim(),
          amount: amount,
        );
      } else {
        await cubit.addExpense(
          date: _selectedDate,
          category: category,
          description: _descriptionController.text.trim(),
          amount: amount,
        );
      }

      if (mounted) Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat(
      'EEEE, d MMMM yyyy',
      'id_ID',
    ).format(_selectedDate);

    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        final categories = state.categories;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditing ? 'Edit Pengeluaran' : 'Tambah Pengeluaran',
            ),
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Autocomplete<String>(
                  initialValue: widget.expense != null
                      ? TextEditingValue(text: widget.expense!.category)
                      : null,
                  optionsBuilder: (textEditingValue) {
                    final q = textEditingValue.text.toLowerCase();
                    if (q.isEmpty) return categories;
                    return categories.where((c) => c.toLowerCase().contains(q));
                  },
                  onSelected: (value) {
                    _categoryFieldController?.text = value;
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                        _categoryFieldController = controller;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: AppStyle.inputDecoration('Kategori'),
                          textCapitalization: TextCapitalization.sentences,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Kategori wajib diisi';
                            }
                            return null;
                          },
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        color: AppStyle.surfaceLight,
                        borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                            maxWidth: 400,
                          ),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(option),
                                onTap: () => onSelected(option),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _descriptionController,
                  decoration: AppStyle.inputDecoration('Keterangan'),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Keterangan wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _amountController,
                  decoration: AppStyle.inputDecoration('Total (IDR)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    final formatted = CurrencyFormatter.formatInput(value);
                    if (formatted != value) {
                      _amountController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                  validator: (v) {
                    final amount = CurrencyFormatter.parseInput(v ?? '');
                    if (amount == null || amount <= 0) {
                      return 'Total harus lebih dari 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(AppStyle.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: AppStyle.cardDecoration(
                      color: AppStyle.surfaceLight,
                      radius: AppStyle.radiusMd,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: AppStyle.textMuted,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal',
                                style: AppStyle.caption.copyWith(
                                  color: AppStyle.textMuted,
                                ),
                              ),
                              Text(
                                dateLabel,
                                style: AppStyle.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppStyle.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppStyle.onPrimary,
                          ),
                        )
                      : Text(
                          widget.isEditing
                              ? 'Simpan Perubahan'
                              : 'Simpan Pengeluaran',
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
