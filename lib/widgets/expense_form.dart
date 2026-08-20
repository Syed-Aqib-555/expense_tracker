import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../utils/category_data.dart';

typedef ExpenseFormSubmit =
    Future<void> Function(
      double amount,
      String category,
      DateTime date,
      String note,
    );

class ExpenseForm extends StatefulWidget {
  const ExpenseForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initialExpense,
  });

  final String submitLabel;
  final ExpenseFormSubmit onSubmit;
  final Expense? initialExpense;

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _selectedCategory;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    _amountController = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(2),
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    _selectedCategory = expense?.category ?? expenseCategories.first.name;
    _selectedDate = expense?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1, 12, 31),
    );

    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _isSaving) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSubmit(
        double.parse(_amountController.text.trim()),
        _selectedCategory,
        _selectedDate,
        _noteController.text.trim(),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          Text(
            'How much did you spend?',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Add the details below to keep your spending accurate.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('amountField'),
            controller: _amountController,
            autofocus: widget.initialExpense == null,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            decoration: const InputDecoration(
              labelText: 'Amount',
              hintText: '0.00',
              prefixText: 'Rs  ',
              prefixIcon: Icon(Icons.payments_outlined),
            ),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || !amount.isFinite || amount <= 0) {
                return 'Enter an amount greater than zero';
              }
              return null;
            },
          ),
          const SizedBox(height: 26),
          Text(
            'Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: expenseCategories.map((category) {
              final selected = category.name == _selectedCategory;
              return ChoiceChip(
                key: Key('category-${category.name}'),
                selected: selected,
                label: Text(category.name),
                avatar: Icon(
                  category.icon,
                  size: 18,
                  color: selected ? colors.onPrimaryContainer : category.color,
                ),
                onSelected: (_) {
                  setState(() => _selectedCategory = category.name);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 26),
          Text(
            'Date',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            key: const Key('datePicker'),
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(16),
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                border: Border.all(color: colors.outlineVariant),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, color: colors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, d MMMM yyyy').format(_selectedDate),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextFormField(
            key: const Key('noteField'),
            controller: _noteController,
            minLines: 3,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Note (optional)',
              hintText: 'What was this expense for?',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 54),
                child: Icon(Icons.notes_rounded),
              ),
            ),
          ),
          const SizedBox(height: 30),
          FilledButton.icon(
            key: const Key('submitExpense'),
            onPressed: _isSaving ? null : _submit,
            icon: _isSaving
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_isSaving ? 'Saving…' : widget.submitLabel),
          ),
        ],
      ),
    );
  }
}
