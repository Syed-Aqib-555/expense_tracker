import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  String? selectedCategory = "Food";
  DateTime selectedDate = DateTime.now();

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

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
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
      appBar: AppBar(title: const Text("Add Expense")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter an amount";
                  }

                  final amount = double.tryParse(value);

                  if (amount == null || amount <= 0) {
                    return "Enter a valid amount";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
              ),

              const SizedBox(height: 20),

              ListTile(
                title: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Note",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final expense = Expense(
                      amount: double.parse(amountController.text),
                      category: selectedCategory!,
                      date: selectedDate,
                      note: noteController.text,
                    );

                    await HiveService.addExpense(expense);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Expense Saved Successfully"),
                        ),
                      );

                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text("Save Expense"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
