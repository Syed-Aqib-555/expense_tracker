import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpensePieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const SizedBox();
    }

    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.pink,
    ];

    int colorIndex = 0;

    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Expense Chart",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: categoryTotals.entries.map((entry) {
                    final section = PieChartSectionData(
                      color: colors[colorIndex++ % colors.length],
                      value: entry.value,
                      title: entry.key,
                      radius: 70,
                      titleStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );

                    return section;
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
