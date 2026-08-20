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
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      floatingActionButton: screenWidth < 720
          ? FloatingActionButton.extended(
              key: const Key('addExpenseButton'),
              onPressed: _openAddExpense,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add expense'),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 1000;
            final showHeaderAction = constraints.maxWidth >= 720;
            final horizontalPadding = constraints.maxWidth >= 900 ? 28.0 : 16.0;

            return ValueListenableBuilder<Box<Expense>>(
              valueListenable: box.listenable(),
              builder: (context, expenseBox, _) {
                final entries =
                    expenseBox.keys
                        .map(
                          (key) => MapEntry<dynamic, Expense?>(
                            key,
                            expenseBox.get(key),
                          ),
                        )
                        .where((entry) => entry.value != null)
                        .map(
                          (entry) => MapEntry<dynamic, Expense>(
                            entry.key,
                            entry.value!,
                          ),
                        )
                        .toList()
                      ..sort((a, b) => b.value.date.compareTo(a.value.date));

                final content = entries.isEmpty
                    ? <Widget>[
                        const SizedBox(height: 40),
                        _EmptyState(onAddExpense: _openAddExpense),
                      ]
                    : _buildDashboardContent(entries, isWide);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        112,
                      ),
                      children: [
                        _DashboardHeader(
                          showAddAction: showHeaderAction,
                          onAddExpense: _openAddExpense,
                        ),
                        ...content,
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildDashboardContent(
    List<MapEntry<dynamic, Expense>> entries,
    bool isWide,
  ) {
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

    final overview = TotalCard(
      total: total,
      categoryTotals: categoryTotals,
      periodLabel: _period == ExpensePeriod.thisMonth
          ? DateFormat('MMMM yyyy').format(DateTime.now())
          : 'All time',
      expenseCount: periodEntries.length,
    );
    final insights = _InsightsCard(
      total: total,
      expenseCount: periodEntries.length,
      categoryTotals: categoryTotals,
    );
    final transactions = _TransactionsPanel(
      entries: visibleEntries,
      controller: _searchController,
      searchQuery: _searchQuery,
      isCurrentMonth: _period == ExpensePeriod.thisMonth,
      onSearchChanged: (value) => setState(() => _searchQuery = value),
      onClearSearch: () {
        _searchController.clear();
        setState(() => _searchQuery = '');
      },
      confirmDelete: _confirmDelete,
    );

    return [
      const SizedBox(height: 34),
      _OverviewHeader(
        selected: _period,
        onChanged: (period) => setState(() => _period = period),
      ),
      const SizedBox(height: 18),
      if (isWide)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 7, child: overview),
              const SizedBox(width: 18),
              Expanded(flex: 4, child: insights),
            ],
          ),
        )
      else ...[
        overview,
        const SizedBox(height: 18),
        insights,
      ],
      const SizedBox(height: 24),
      if (isWide)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: CategoryBreakdown(categoryTotals: categoryTotals),
            ),
            const SizedBox(width: 18),
            Expanded(flex: 7, child: transactions),
          ],
        )
      else ...[
        if (categoryTotals.isNotEmpty) ...[
          CategoryBreakdown(categoryTotals: categoryTotals),
          const SizedBox(height: 18),
        ],
        transactions,
      ],
    ];
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.showAddAction,
    required this.onAddExpense,
  });

  final bool showAddAction;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense Tracker',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('EEEE, d MMMM').format(DateTime.now()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (showAddAction) ...[
          FilledButton.icon(
            key: const Key('addExpenseButton'),
            onPressed: onAddExpense,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Add expense'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
          ),
          const SizedBox(width: 10),
        ],
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
      ],
    );
  }
}

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({required this.selected, required this.onChanged});

  final ExpensePeriod selected;
  final ValueChanged<ExpensePeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 580;
        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending overview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'A clear view of where your money is going.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
        final selector = _PeriodSelector(
          selected: selected,
          onChanged: onChanged,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, child: selector),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: title),
            const SizedBox(width: 24),
            SizedBox(width: 330, child: selector),
          ],
        );
      },
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

class _InsightsCard extends StatelessWidget {
  const _InsightsCard({
    required this.total,
    required this.expenseCount,
    required this.categoryTotals,
  });

  final double total;
  final int expenseCount;
  final Map<String, double> categoryTotals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final average = expenseCount == 0 ? 0.0 : total / expenseCount;
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategory = sortedCategories.isEmpty
        ? null
        : categoryDataFor(sortedCategories.first.key);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_graph_rounded,
                    color: colors.onTertiaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'At a glance',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            _InsightRow(
              icon: Icons.calculate_outlined,
              label: 'Average expense',
              value: 'Rs ${NumberFormat('#,##0.00').format(average)}',
            ),
            const SizedBox(height: 14),
            Divider(color: colors.outlineVariant.withValues(alpha: 0.7)),
            const SizedBox(height: 14),
            _InsightRow(
              icon: topCategory?.icon ?? Icons.category_outlined,
              iconColor: topCategory?.color,
              label: 'Top category',
              value: topCategory?.name ?? 'No spending yet',
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TransactionsPanel extends StatelessWidget {
  const _TransactionsPanel({
    required this.entries,
    required this.controller,
    required this.searchQuery,
    required this.isCurrentMonth,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.confirmDelete,
  });

  final List<MapEntry<dynamic, Expense>> entries;
  final TextEditingController controller;
  final String searchQuery;
  final bool isCurrentMonth;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final Future<bool> Function(Expense expense) confirmDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transactions',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Review and manage your recent expenses.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.secondaryContainer,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${entries.length} shown',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              key: const Key('expenseSearch'),
              controller: controller,
              onChanged: onSearchChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search category, note, or amount',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.close_rounded),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              _NoResults(isCurrentMonth: isCurrentMonth)
            else
              ...entries.map(
                (entry) => _ExpenseTile(
                  key: ValueKey(entry.key),
                  expense: entry.value,
                  expenseKey: entry.key,
                  confirmDelete: () => confirmDelete(entry.value),
                ),
              ),
          ],
        ),
      ),
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
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: colors.errorContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(Icons.delete_rounded, color: colors.onErrorContainer),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.48),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.52),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () async {
              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditExpenseScreen(
                    expense: expense,
                    expenseKey: expenseKey,
                  ),
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
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(category.icon, color: category.color, size: 22),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          expense.category,
                          style: const TextStyle(
                            fontSize: 15,
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
                          fontSize: 14,
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.primaryContainer,
                        colors.tertiaryContainer,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 46,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Start tracking your spending',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
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
                const SizedBox(height: 26),
                FilledButton.icon(
                  onPressed: onAddExpense,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add first expense'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                ),
              ],
            ),
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
    final colors = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 38,
            color: colors.onSurfaceVariant,
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
    );
  }
}
