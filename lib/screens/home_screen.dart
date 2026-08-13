import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../services/hive_service.dart';
import '../utils/category_data.dart';
import '../utils/theme_provider.dart';
import '../widgets/category_breakdown.dart';
import '../widgets/total_card.dart';
import 'add_expense_screen.dart';
import 'edit_expense_screen.dart';

enum ExpensePeriod { thisMonth, allTime }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  ExpensePeriod _period = ExpensePeriod.thisMonth;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _isInSelectedPeriod(Expense expense) {
    if (_period == ExpensePeriod.allTime) return true;
    final now = DateTime.now();
    return expense.date.year == now.year && expense.date.month == now.month;
  }

  Future<void> _openAddExpense() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense saved successfully')),
      );
    }
  }

  Future<bool> _confirmDelete(Expense expense) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.delete_outline_rounded),
            title: const Text('Delete this expense?'),
            content: Text(
              'The ${expense.category.toLowerCase()} expense of '
              'Rs ${expense.amount.toStringAsFixed(2)} will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final box = HiveService.getBox();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expense Tracker'),
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (_, provider, _) => IconButton.filledTonal(
              tooltip: provider.isDark ? 'Use light theme' : 'Use dark theme',
              onPressed: provider.toggleTheme,
              icon: Icon(
                provider.isDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('addExpenseButton'),
        onPressed: _openAddExpense,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add expense'),
      ),
      body: ValueListenableBuilder<Box<Expense>>(
        valueListenable: box.listenable(),
        builder: (context, expenseBox, _) {
          final entries =
              expenseBox.keys
                  .map(
                    (key) =>
                        MapEntry<dynamic, Expense?>(key, expenseBox.get(key)),
                  )
                  .where((entry) => entry.value != null)
                  .map(
                    (entry) =>
                        MapEntry<dynamic, Expense>(entry.key, entry.value!),
                  )
                  .toList()
                ..sort((a, b) => b.value.date.compareTo(a.value.date));

          if (entries.isEmpty) {
            return _EmptyState(onAddExpense: _openAddExpense);
          }

          final periodEntries = entries
              .where((entry) => _isInSelectedPeriod(entry.value))
              .toList();
          final categoryTotals = <String, double>{};
          var total = 0.0;
          for (final entry in periodEntries) {
            total += entry.value.amount;
            categoryTotals.update(
              entry.value.category,
              (value) => value + entry.value.amount,
              ifAbsent: () => entry.value.amount,
            );
          }

          final query = _searchQuery.trim().toLowerCase();
          final visibleEntries = periodEntries.where((entry) {
            if (query.isEmpty) return true;
            final expense = entry.value;
            return expense.category.toLowerCase().contains(query) ||
                expense.note.toLowerCase().contains(query) ||
                expense.amount.toStringAsFixed(2).contains(query);
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 112),
                children: [
                  _PeriodSelector(
                    selected: _period,
                    onChanged: (period) => setState(() => _period = period),
                  ),
                  const SizedBox(height: 18),
                  TotalCard(
                    total: total,
                    categoryTotals: categoryTotals,
                    periodLabel: _period == ExpensePeriod.thisMonth
                        ? DateFormat('MMMM yyyy').format(DateTime.now())
                        : 'All time',
                    expenseCount: periodEntries.length,
                  ),
                  if (categoryTotals.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    CategoryBreakdown(categoryTotals: categoryTotals),
                  ],
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Transactions',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        '${visibleEntries.length} shown',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('expenseSearch'),
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search category, note, or amount',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Clear search',
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (visibleEntries.isEmpty)
                    _NoResults(
                      isCurrentMonth: _period == ExpensePeriod.thisMonth,
                    )
                  else
                    ...visibleEntries.map(
                      (entry) => _ExpenseTile(
                        key: ValueKey(entry.key),
                        expense: entry.value,
                        expenseKey: entry.key,
                        confirmDelete: () => _confirmDelete(entry.value),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final ExpensePeriod selected;
  final ValueChanged<ExpensePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ExpensePeriod>(
      segments: const [
        ButtonSegment(
          value: ExpensePeriod.thisMonth,
          icon: Icon(Icons.calendar_view_month_rounded),
          label: Text('This month'),
        ),
        ButtonSegment(
          value: ExpensePeriod.allTime,
          icon: Icon(Icons.all_inclusive_rounded),
          label: Text('All time'),
        ),
      ],
      selected: {selected},
      showSelectedIcon: false,
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({
    super.key,
    required this.expense,
    required this.expenseKey,
    required this.confirmDelete,
  });

  final Expense expense;
  final dynamic expenseKey;
  final Future<bool> Function() confirmDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final category = categoryDataFor(expense.category);

    return Dismissible(
      key: ValueKey('dismiss-$expenseKey'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(),
      onDismissed: (_) async {
        await HiveService.deleteExpenseByKey(expenseKey);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Expense deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () =>
                    HiveService.restoreExpense(expenseKey, expense),
              ),
            ),
          );
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(Icons.delete_rounded, color: colors.onErrorContainer),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditExpenseScreen(expense: expense, expenseKey: expenseKey),
              ),
            );
            if (updated == true && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Expense updated successfully')),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expense.category,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expense.note.isEmpty
                            ? DateFormat('d MMM yyyy').format(expense.date)
                            : '${expense.note} • ${DateFormat('d MMM yyyy').format(expense.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rs ${NumberFormat('#,##0.00').format(expense.amount)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAddExpense});

  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Start tracking your spending',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Add your first expense and this dashboard will turn it into useful insights.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAddExpense,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add first expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({required this.isCurrentMonth});

  final bool isCurrentMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              isCurrentMonth
                  ? 'No matching expenses this month'
                  : 'No matching expenses',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
