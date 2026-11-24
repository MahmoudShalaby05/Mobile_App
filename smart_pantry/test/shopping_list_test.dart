import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/app.dart';
import 'package:smart_pantry/models/shopping_item.dart';

Future<void> openShoppingPage(WidgetTester tester) async {
  tester.view.physicalSize = const Size(420, 820);
  tester.view.devicePixelRatio = 1;

  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(const SmartPantryApp());
  await tester.pumpAndSettle();

  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.byIcon(Icons.shopping_basket_outlined),
    ),
  );

  await tester.pumpAndSettle();
}

Finder shoppingRow(String name) {
  return find.widgetWithText(CheckboxListTile, name);
}

Future<void> addItem(
  WidgetTester tester,
  String name,
  String quantity,
  String unit,
) async {
  await tester.tap(find.text('Add Item'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), name);

  await tester.enterText(find.byType(TextFormField).at(1), quantity);

  await tester.tap(find.byType(DropdownButtonFormField<String>));

  await tester.pumpAndSettle();

  await tester.tap(find.text(unit).last);
  await tester.pumpAndSettle();

  await tester.tap(find.widgetWithText(FilledButton, 'Add'));

  await tester.pumpAndSettle();
}

Finder itemCard(String name) {
  return find.ancestor(of: shoppingRow(name), matching: find.byType(Card));
}

void main() {
  test('Shopping unit normalization', () {
    expect(normalizeShoppingUnit('pcs'), 'pieces');
    expect(normalizeShoppingUnit('pieces'), 'pieces');
    expect(normalizeShoppingUnit(' PCS '), 'pieces');
    expect(normalizeShoppingUnit('L'), 'l');
    expect(normalizeShoppingUnit('kg'), isNot('g'));
  });

  testWidgets('User can add a shopping item', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Apple', '3', 'Pieces');

    expect(shoppingRow('Apple'), findsOneWidget);
    expect(find.text('3 pcs'), findsOneWidget);
  });

  testWidgets('User can edit a shopping item', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Apple', '3', 'Pieces');

    await tester.tap(
      find.descendant(
        of: itemCard('Apple'),
        matching: find.byTooltip('Edit Item'),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), '5');

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));

    await tester.pumpAndSettle();

    expect(shoppingRow('Apple'), findsOneWidget);
    expect(find.text('5 pcs'), findsOneWidget);
    expect(find.text('3 pcs'), findsNothing);
  });

  testWidgets('User can delete a shopping item', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Apple', '3', 'Pieces');

    await tester.tap(
      find.descendant(
        of: itemCard('Apple'),
        matching: find.byTooltip('Delete Item'),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Delete'));

    await tester.pumpAndSettle();

    expect(shoppingRow('Apple'), findsNothing);
  });

  testWidgets('Duplicate shopping items are rejected', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Apple', '3', 'Pieces');
    await addItem(tester, 'Apple', '5', 'Pieces');

    expect(
      find.textContaining('already in your shopping list'),
      findsOneWidget,
    );

    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(shoppingRow('Apple'), findsOneWidget);
    expect(find.text('3 pcs'), findsOneWidget);
  });

  testWidgets('Duplicate detection ignores name case and whitespace', (
    tester,
  ) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Apple', '3', 'Pieces');
    await addItem(tester, '  APPLE  ', '5', 'Pieces');

    expect(
      find.textContaining('already in your shopping list'),
      findsOneWidget,
    );
  });

  testWidgets('Duplicate detection recognizes equivalent units', (
    tester,
  ) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Lemon', '5', 'Pieces');

    expect(
      find.textContaining('already in your shopping list'),
      findsOneWidget,
    );

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(shoppingRow('Lemon'), findsOneWidget);
  });

  testWidgets('Items with different units are allowed', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Lemon', '1', 'Kilograms');

    expect(find.byType(AlertDialog), findsNothing);
    expect(shoppingRow('Lemon'), findsNWidgets(2));
  });

  testWidgets('Editing an item cannot create a duplicate', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Apple', '3', 'Pieces');

    await tester.tap(
      find.descendant(
        of: itemCard('Apple'),
        matching: find.byTooltip('Edit Item'),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Lemon');

    await tester.tap(find.widgetWithText(FilledButton, 'Save'));

    await tester.pumpAndSettle();

    expect(
      find.textContaining('already in your shopping list'),
      findsOneWidget,
    );

    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Duplicate warning clears when the name changes', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Lemon', '5', 'Pieces');

    expect(
      find.textContaining('already in your shopping list'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Orange');

    await tester.pumpAndSettle();

    expect(find.textContaining('already in your shopping list'), findsNothing);

    await tester.tap(find.widgetWithText(FilledButton, 'Add'));

    await tester.pumpAndSettle();

    expect(shoppingRow('Orange'), findsOneWidget);
  });

  testWidgets(
    'Purchased items allow new purchases but block conflicting unchecks',
    (tester) async {
      await openShoppingPage(tester);

      await tester.tap(shoppingRow('Lemon'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CheckboxListTile>(shoppingRow('Lemon')).value,
        isTrue,
      );

      await addItem(tester, 'Lemon', '5', 'Pieces');

      expect(shoppingRow('Lemon'), findsNWidgets(2));

      await tester.tap(shoppingRow('Lemon').first);
      await tester.pumpAndSettle();

      expect(find.text('Cannot Uncheck Item'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CheckboxListTile>(shoppingRow('Lemon').first).value,
        isTrue,
      );

      await tester.tap(
        find.descendant(
          of: itemCard('Lemon').last,
          matching: find.byTooltip('Delete Item'),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));

      await tester.pumpAndSettle();

      await tester.tap(shoppingRow('Lemon'));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CheckboxListTile>(shoppingRow('Lemon')).value,
        isFalse,
      );
    },
  );

  testWidgets('Pantry stock matches equivalent shopping units', (tester) async {
    await openShoppingPage(tester);

    await addItem(tester, 'Egg', '3', 'Pieces');

    expect(shoppingRow('Egg'), findsOneWidget);

    expect(find.text('3 pcs · 6 pcs in pantry'), findsOneWidget);
  });
}
