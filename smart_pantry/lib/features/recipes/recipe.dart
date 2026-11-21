class Ingredient {
  const Ingredient(this.name, this.quantity, this.unit);

  final String name;
  final double quantity;
  final String unit;
}

class Recipe {
  const Recipe(
    this.title,
    this.minutes,
    this.ingredients,
    this.instructions, {
    this.imageAsset,
  });

  final String title;
  final int minutes;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final String? imageAsset;
}
