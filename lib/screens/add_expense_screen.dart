import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../services/hive_service.dart';
import '../widgets/expense_form.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add expense')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ExpenseForm(
              submitLabel: 'Save expense',
              onSubmit: (amount, category, date, note) async {
                await HiveService.addExpense(
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
