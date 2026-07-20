import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../widgets/total_card.dart';
import '../models/expense.dart';
import '../services/hive_service.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';
import '../widgets/category_breakdown.dart';

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
Map<String, double> categoryTotals = {};

for (var expense in expenses) {
  total += expense.amount;

  categoryTotals.update(
    expense.category,
    (value) => value + expense.amount,
    ifAbsent: () => expense.amount,
  );
}
          for (var expense in expenses) {
            total += expense.amount;
          }
          return Column(
            children: [

  TotalCard(total: total),

  CategoryBreakdown(
    categoryTotals: categoryTotals,
  ),

  Expanded(
                child: ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];

                    return Dismissible(
  key: Key(index.toString()),

  direction: DismissDirection.endToStart,

  background: Container(
    alignment: Alignment.centerRight,
    padding: const EdgeInsets.only(right: 20),
    color: Colors.red,
    child: const Icon(
      Icons.delete,
      color: Colors.white,
      size: 30,
    ),
  ),

  onDismissed: (direction) async {

    await HiveService.deleteExpense(
      box.length - 1 - index,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Expense Deleted"),
      ),
    );
  },

  child: Card(
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
              index: box.length - 1 - index,
            ),
          ),
        );
      },

      leading: CircleAvatar(
        backgroundColor: Colors.blue.shade100,
        child: const Icon(Icons.account_balance_wallet),
      ),

      title: Text(
        expense.category,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),

      subtitle: Text(
        "${expense.note}\n${expense.date.day}/${expense.date.month}/${expense.date.year}",
      ),

      trailing: Text(
        "Rs ${expense.amount.toStringAsFixed(2)}",
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
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
