import 'package:flutter/material.dart';

class CategoryBreakdown extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const CategoryBreakdown({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Category Breakdown",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...categoryTotals.entries.map(
              (entry) => ListTile(
                leading: const Icon(Icons.category),
                title: Text(entry.key),
                trailing: Text(
                  "Rs ${entry.value.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
