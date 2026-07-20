import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/expense.dart';
import '../services/hive_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;
  final int index;

  const EditExpenseScreen({
    super.key,
    required this.expense,
    required this.index,
  });

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController amountController;
  late TextEditingController noteController;

  late String selectedCategory;
  late DateTime selectedDate;

  final List<String> categories = [
    "Food",
    "Transport",
    "Shopping",
    "Bills",
    "Health",
    "Education",
    "Entertainment",
    "Other",
  ];

  @override
  void initState() {
    super.initState();

    amountController = TextEditingController(
      text: widget.expense.amount.toString(),
    );

    noteController = TextEditingController(text: widget.expense.note);

    selectedCategory = widget.expense.category;
    selectedDate = widget.expense.date;
  }

  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter amount";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(labelText: "Category"),
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              ListTile(
                title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: pickDate,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: "Note"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final updatedExpense = Expense(
                      amount: double.parse(amountController.text),
                      category: selectedCategory,
                      date: selectedDate,
                      note: noteController.text,
                    );

                    await HiveService.updateExpense(
                      widget.index,
                      updatedExpense,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("Update Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
