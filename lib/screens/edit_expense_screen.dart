import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/hive_service.dart';
import '../widgets/expense_form.dart';

class EditExpenseScreen extends StatelessWidget {
  final Expense expense;
  final dynamic expenseKey;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.expenseKey,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit expense')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ExpenseForm(
              initialExpense: expense,
              submitLabel: 'Update expense',
              onSubmit: (amount, category, date, note) async {
                await HiveService.updateExpenseByKey(
                  expenseKey,
                  Expense(
                    amount: amount,
                    category: category,
                    date: date,
                    note: note,
                  ),
                );

                if (context.mounted) Navigator.pop(context, true);
              },
            ),
          ),
        ),
      ),
    );
  }
}
