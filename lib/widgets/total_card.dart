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
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF312E81)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -54,
            top: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: const BoxDecoration(
                color: Color(0x0FFFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 72,
            bottom: -82,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: Color(0x08FFFFFF),
                shape: BoxShape.circle,
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final showChart = constraints.maxWidth >= 360;
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
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
                                      ?.copyWith(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
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
                                  fontSize: 36,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),
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
                      width: 118,
                      height: 118,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ExpensePieChart(categoryTotals: categoryTotals),
                          const Icon(
                            Icons.insights_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
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
