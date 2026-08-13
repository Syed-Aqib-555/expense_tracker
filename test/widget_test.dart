import 'package:expense_tracker/widgets/expense_form.dart';
import 'package:expense_tracker/widgets/total_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('summary card displays formatted spending and count', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 520,
            child: TotalCard(
              total: 12345.5,
              categoryTotals: {'Food': 2345.5, 'Bills': 10000},
              periodLabel: 'August 2026',
              expenseCount: 2,
            ),
          ),
        ),
      ),
    );

    expect(find.text('Rs 12,345.50'), findsOneWidget);
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('2 expenses'), findsOneWidget);
  });

  testWidgets('expense form validates and submits entered values', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    double? savedAmount;
    String? savedCategory;
    String? savedNote;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpenseForm(
            submitLabel: 'Save expense',
            onSubmit: (amount, category, date, note) async {
              savedAmount = amount;
              savedCategory = category;
              savedNote = note;
            },
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.byKey(const Key('submitExpense')));
    await tester.tap(find.byKey(const Key('submitExpense')));
    await tester.pump();
    expect(find.text('Enter an amount greater than zero'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('amountField')), '825.50');
    await tester.tap(find.byKey(const Key('category-Shopping')));
    await tester.enterText(find.byKey(const Key('noteField')), 'New shoes');
    await tester.ensureVisible(find.byKey(const Key('submitExpense')));
    await tester.tap(find.byKey(const Key('submitExpense')));
    await tester.pump();

    expect(savedAmount, 825.50);
    expect(savedCategory, 'Shopping');
    expect(savedNote, 'New shoes');
  });
}
