import 'package:flutter/material.dart';

class ExpenseCategoryData {
  const ExpenseCategoryData({
    required this.name,
    required this.icon,
    required this.color,
  });

  final String name;
  final IconData icon;
  final Color color;
}

const expenseCategories = <ExpenseCategoryData>[
  ExpenseCategoryData(
    name: 'Food',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFF59E0B),
  ),
  ExpenseCategoryData(
    name: 'Transport',
    icon: Icons.directions_car_rounded,
    color: Color(0xFF3B82F6),
  ),
  ExpenseCategoryData(
    name: 'Shopping',
    icon: Icons.shopping_bag_rounded,
    color: Color(0xFFEC4899),
  ),
  ExpenseCategoryData(
    name: 'Bills',
    icon: Icons.receipt_long_rounded,
    color: Color(0xFF8B5CF6),
  ),
  ExpenseCategoryData(
    name: 'Health',
    icon: Icons.health_and_safety_rounded,
    color: Color(0xFF10B981),
  ),
  ExpenseCategoryData(
    name: 'Education',
    icon: Icons.school_rounded,
    color: Color(0xFF06B6D4),
  ),
  ExpenseCategoryData(
    name: 'Entertainment',
    icon: Icons.movie_rounded,
    color: Color(0xFFEF4444),
  ),
  ExpenseCategoryData(
    name: 'Other',
    icon: Icons.more_horiz_rounded,
    color: Color(0xFF64748B),
  ),
];

ExpenseCategoryData categoryDataFor(String name) {
  return expenseCategories.firstWhere(
    (category) => category.name == name,
    orElse: () => expenseCategories.last,
  );
}
