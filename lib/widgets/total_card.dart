import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'expense_pie_chart.dart';

class TotalCard extends StatelessWidget {
  final double total;
  final Map<String, double> categoryTotals;
  final String periodLabel;
  final int expenseCount;

  const TotalCard({
    super.key,
    required this.total,
    required this.categoryTotals,
    required this.periodLabel,
    required this.expenseCount,
  });

  @override
  Widget build(BuildContext context) {
    final amount = NumberFormat('#,##0.00').format(total);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2563EB), Color(0xFF4338CA)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showChart = constraints.maxWidth >= 360;
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total spending',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Rs $amount',
                        key: const Key('totalAmount'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _SummaryPill(
                          icon: Icons.calendar_month_rounded,
                          label: periodLabel,
                        ),
                        _SummaryPill(
                          icon: Icons.receipt_long_rounded,
                          label:
                              '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (showChart) ...[
                const SizedBox(width: 20),
                Container(
                  width: 112,
                  height: 112,
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0x20FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: ExpensePieChart(categoryTotals: categoryTotals),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
