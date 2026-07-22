import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;

  const ExpensePieChart({super.key, required this.categoryTotals});

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return const Center(
        child: Text("No Data", style: TextStyle(fontSize: 16)),
      );
    }

    final colors = [
      const Color(0xFFFF9800), // Orange
      const Color(0xFFE91E63), // Pink
      const Color(0xFF4CAF50), // Green
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF00BCD4), // Cyan
      const Color(0xFFFFC107), // Amber
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];

    int colorIndex = 0;

    return PieChart(
      PieChartData(
        centerSpaceRadius: 35,
        sectionsSpace: 3,
        borderData: FlBorderData(show: false),

        sections: categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            color: colors[colorIndex++ % colors.length],
            value: entry.value,
            title: "",
            radius: 30,
          );
        }).toList(),
      ),
    );
  }
}
