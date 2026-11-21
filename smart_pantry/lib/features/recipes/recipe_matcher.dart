import '../../models/food_item.dart';
import 'recipe.dart';

class RecipeMatch {
  const RecipeMatch(this.recipe, this.shortfalls, this.expiringIngredients);

  final Recipe recipe;
  final List<Ingredient> shortfalls;
  final int expiringIngredients;

  int get available => recipe.ingredients.length - shortfalls.length;
}

List<RecipeMatch> matchRecipes(List<Recipe> recipes, List<FoodItem> pantry) {
  final matches = recipes.map((recipe) {
    final shortfalls = <Ingredient>[];
    var expiringIngredients = 0;
    for (final ingredient in recipe.ingredients) {
      var quantity = 0.0;
      var usesExpiring = false;
      for (final item in pantry) {
        if (item.daysRemaining < 0 ||
            item.quantity <= 0 ||
            normalizeName(item.name) != normalizeName(ingredient.name)) {
          continue;
        }
        final factor = _conversion(item.unit, ingredient.unit);
        if (factor == null) continue;
        quantity += item.quantity * factor;
        usesExpiring |= item.isExpiringSoon;
      }
      if (usesExpiring) expiringIngredients++;
      final missing = ingredient.quantity - quantity;
      if (missing > 0.000000001) {
        shortfalls.add(Ingredient(ingredient.name, missing, ingredient.unit));
      }
    }
    return RecipeMatch(recipe, shortfalls, expiringIngredients);
  }).toList();

  return matches..sort((a, b) {
    final complete = (b.shortfalls.isEmpty ? 1 : 0).compareTo(
      a.shortfalls.isEmpty ? 1 : 0,
    );
    if (complete != 0) return complete;
    final urgency = b.expiringIngredients.compareTo(a.expiringIngredients);
    if (urgency != 0) return urgency;
    final coverage = (b.available * a.recipe.ingredients.length).compareTo(
      a.available * b.recipe.ingredients.length,
    );
    if (coverage != 0) return coverage;
    return a.recipe.title.compareTo(b.recipe.title);
  });
}

double? _conversion(String from, String to) => switch ((from, to)) {
  (final a, final b) when a == b => 1,
  ('kg', 'g') || ('L', 'ml') => 1000,
  ('g', 'kg') || ('ml', 'L') => 0.001,
  _ => null,
};
