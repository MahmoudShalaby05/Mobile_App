import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/app.dart';
import 'package:smart_pantry/features/recipes/recipe_presentation.dart';

void main() {
  testWidgets(
    'Phone home shows the recipe shelf and labeled bottom navigation',
    (tester) async {
      tester.view.physicalSize = const Size(360, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const SmartPantryApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(RecipePhoto), findsNWidgets(4));
      expect(find.text('Cook from your pantry'), findsOneWidget);
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.byIcon(Icons.restaurant_menu),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'chickpeas');
      await tester.pumpAndSettle();
      expect(find.text('Spinach & chickpea rice bowl'), findsOneWidget);
      expect(find.text('Tomato & cheese omelette'), findsNothing);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Cook from your pantry'), findsOneWidget);
    },
  );

  testWidgets('Recipes send missing ingredients to the shared shopping list', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SmartPantryApp());

    await tester.tap(find.text('Explore recipes'));
    await tester.pumpAndSettle();
    final bowl = find.text('Spinach & chickpea rice bowl');
    await tester.ensureVisible(bowl);
    await tester.pumpAndSettle();
    await tester.tap(bowl);
    await tester.pumpAndSettle();
    final addMissing = find.text('Add missing to shopping list');
    await tester.ensureVisible(addMissing);
    await tester.pumpAndSettle();
    await tester.tap(addMissing);
    await tester.pumpAndSettle();

    expect(find.text('Shopping list'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Chickpeas'), findsOneWidget);
    expect(find.widgetWithText(CheckboxListTile, 'Lemon'), findsOneWidget);
  });

  testWidgets('Using a pantry item updates recipe availability', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 820);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const SmartPantryApp());
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.kitchen_outlined),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mark Tomato as used'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.byIcon(Icons.restaurant_menu),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('2/3 ingredients'), findsWidgets);

    final omelette = find.text('Tomato & cheese omelette');
    await tester.ensureVisible(omelette);
    await tester.pumpAndSettle();
    await tester.tap(omelette);
    await tester.pumpAndSettle();
    final addMissing = find.text('Add missing to shopping list');
    await tester.ensureVisible(addMissing);
    await tester.pumpAndSettle();
    await tester.tap(addMissing);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxListTile, 'Tomato'), findsOneWidget);
  });
}
