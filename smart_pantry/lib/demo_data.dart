import 'models/food_item.dart';
import 'models/shopping_item.dart';

List<FoodItem> demoPantry() {
  final today = DateTime.now();
  return [
    for (final (name, quantity, unit, category, location, days) in [
      ('Tomato', 4.0, 'pieces', 'Produce', 'Fridge', 1),
      ('Milk', 1.0, 'L', 'Dairy', 'Fridge', 2),
      ('Spinach', 100.0, 'g', 'Produce', 'Fridge', 3),
      ('Egg', 6.0, 'pieces', 'Protein', 'Fridge', 8),
      ('Rice', 500.0, 'g', 'Grains', 'Cupboard', 90),
      ('Cheese', 200.0, 'g', 'Dairy', 'Fridge', 7),
    ])
      FoodItem(
        id: name,
        name: name,
        quantity: quantity,
        unit: unit,
        category: category,
        location: location,
        expirationDate: DateTime(today.year, today.month, today.day + days),
      ),
  ];
}

const demoShopping = [
  ShoppingItem('lemon', 'Lemon', 2, 'pieces'),
  ShoppingItem('chickpeas', 'Chickpeas', 200, 'g'),
];
