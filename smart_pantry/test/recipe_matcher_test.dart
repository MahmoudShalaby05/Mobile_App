import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/features/recipes/recipe.dart';
import 'package:smart_pantry/features/recipes/recipe_matcher.dart';
import 'package:smart_pantry/models/food_item.dart';

void main() {
  const recipe = Recipe('Warm milk', 3, [Ingredient('Milk', 500, 'ml')], []);
  final today = DateTime.now();

  FoodItem stock(String id, double quantity, String unit, int days) => FoodItem(
    id: id,
    name: ' milk ',
    quantity: quantity,
    unit: unit,
    category: 'Dairy',
    location: 'Fridge',
    expirationDate: DateTime(today.year, today.month, today.day + days),
  );

  test('Aggregates compatible stock and excludes expired batches', () {
    final result = matchRecipes(
      [recipe],
      [
        stock('carton', 0.25, 'L', 1),
        stock('glass', 100, 'ml', 7),
        stock('expired', 1, 'L', -1),
      ],
    ).single;

    expect(result.available, 0);
    expect(result.expiringIngredients, 1);
    expect(result.shortfalls.single.quantity, 150);
    expect(result.shortfalls.single.unit, 'ml');
  });

  test('Ranks cookable meals before meals with missing ingredients', () {
    const incomplete = Recipe('Milk and eggs', 5, [
      Ingredient('Milk', 100, 'ml'),
      Ingredient('Egg', 1, 'pieces'),
    ], []);
    final results = matchRecipes(
      [incomplete, recipe],
      [stock('carton', 1, 'L', 1)],
    );

    expect(results.first.recipe, recipe);
    expect(results.first.shortfalls, isEmpty);
  });
}
