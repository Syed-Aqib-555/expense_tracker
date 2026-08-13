import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/category_data.dart';

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

    return PieChart(
      PieChartData(
        centerSpaceRadius: 32,
        sectionsSpace: 2,
        borderData: FlBorderData(show: false),
        sections: categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            color: categoryDataFor(entry.key).color,
            value: entry.value,
            title: '',
            radius: 20,
          );
        }).toList(),
      ),
    );
  }
}
