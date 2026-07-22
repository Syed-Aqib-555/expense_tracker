import 'package:flutter/material.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../services/hive_service.dart';
import '../utils/theme_provider.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/total_card.dart';

import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final box = HiveService.getBox();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff2196F3), Color(0xff1565C0)],
            ),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            Text(
              "Expense Tracker",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (_, theme, __) => IconButton(
              icon: Icon(theme.isDark ? Icons.light_mode : Icons.dark_mode),
              onPressed: theme.toggleTheme,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          elevation: 15,
          backgroundColor: const Color(0xff1565C0),
          foregroundColor: Colors.white,

          icon: const Icon(Icons.add),

          label: const Text(
            "Add Expense",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),

          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
            );
          },
        ),
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<Expense> box, _) {
          if (box.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 25),

                  const Text(
                    "No Expenses Yet",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Tap Add Expense to start tracking.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Spending Card
                  TotalCard(total: total, categoryTotals: categoryTotals),

                  // Analytics Title
                  /*const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
                    child: Text(
                      "Analytics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),*/

                  // Pie Chart
                  // Expense Analytics Card
                  // Expense Analytics Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      /*child: Padding(
                        padding: const EdgeInsets.all(20),
                        /*child: Column(
                          /* children: [
                            /*const Row(
                              /*children: [
                                /* Icon(
                                  Icons.pie_chart,
                                  color: Colors.blue,
                                  size: 28,
                                ),*/
                                //SizedBox(width: 10),
                                /* Text(
                                  "Expense Analytics",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),*/
                              ],*/
                            ),*/

                            // const SizedBox(height: 20),
                            /*SizedBox(
                              height: 250,
                              width: 250,
                              child: ExpensePieChart(
                                categoryTotals: categoryTotals,
                              ),
                            ),*/
                          ],*/
                        ),*/
                      ),*/
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Category Breakdown
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: CategoryBreakdown(categoryTotals: categoryTotals),
                  ),

                  const SizedBox(height: 20),

                  // Recent Transactions
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Transactions",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "See All",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Expense List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];

                      return Dismissible(
                        key: ValueKey(
                          "${expense.category}${expense.date}${expense.amount}",
                        ),
                        direction: DismissDirection.endToStart,

                        background: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 25),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),

                        onDismissed: (_) async {
                          await HiveService.deleteExpense(
                            box.length - 1 - index,
                          );

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Expense Deleted")),
                          );
                        },

                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.08),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),

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
                              radius: 25,
                              backgroundColor: Colors.blue.shade50,
                              child: Icon(
                                _getCategoryIcon(expense.category),
                                color: Colors.blue,
                              ),
                            ),

                            title: Text(
                              expense.category,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                "${expense.note}\n${expense.date.day}/${expense.date.month}/${expense.date.year}",
                              ),
                            ),

                            trailing: Text(
                              "Rs ${expense.amount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case "Food":
        return Icons.restaurant;

      case "Shopping":
        return Icons.shopping_cart;

      case "Bills":
        return Icons.receipt_long;

      case "Transport":
        return Icons.directions_car;

      case "Health":
        return Icons.local_hospital;

      case "Education":
        return Icons.school;

      case "Entertainment":
        return Icons.movie;

      default:
        return Icons.account_balance_wallet;
    }
  }
}
