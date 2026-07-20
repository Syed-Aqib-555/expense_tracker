import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/total_card.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = HiveService.getBox();

    return Scaffold(
      appBar: AppBar(title: const Text("Expense Tracker"), centerTitle: true),

      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
          );
        },
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Expense> box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text(
                "No expenses yet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            );
          }

          final expenses = box.values.toList().reversed.toList();
          double total = 0;

          for (var expense in expenses) {
            total += expense.amount;
          }
          return Column(
            children: [
              TotalCard(total: total),

              Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: ListTile(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditExpenseScreen(
                                expense: expense,
                                index: index,
                              ),
                            ),
                          );
                        },

                        leading: const CircleAvatar(
                          child: Icon(Icons.attach_money),
                        ),

                        title: Text(expense.category),

                        subtitle: Text(expense.note),

                        trailing: Text("Rs ${expense.amount}"),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
