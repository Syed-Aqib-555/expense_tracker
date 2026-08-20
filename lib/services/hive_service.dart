import 'package:hive_flutter/hive_flutter.dart';
import '../models/expense.dart';

class HiveService {
  static const String boxName = 'expenses';

  static Box<Expense> getBox() {
    return Hive.box<Expense>(boxName);
  }

  static Future<void> addExpense(Expense expense) async {
    await getBox().add(expense);
  }

  static List<Expense> getExpenses() {
    return getBox().values.toList();
  }

  static Future<void> deleteExpense(int index) async {
    await getBox().deleteAt(index);
  }

  static Future<void> deleteExpenseByKey(dynamic key) async {
    await getBox().delete(key);
  }

  static Future<void> restoreExpense(dynamic key, Expense expense) async {
    await getBox().put(key, expense);
  }

  static Future<void> updateExpense(int index, Expense expense) async {
    await getBox().putAt(index, expense);
  }

  static Future<void> updateExpenseByKey(dynamic key, Expense expense) async {
    await getBox().put(key, expense);
  }
}
