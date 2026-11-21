import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../models/shopping_item.dart';
import '../../widgets/pantry_widgets.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({
    required this.items,
    required this.pantry,
    required this.toggle,
    super.key,
  });

  final List<ShoppingItem> items;
  final List<FoodItem> pantry;
  final ValueChanged<ShoppingItem> toggle;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PageHeading('Shopping list', 'Check off groceries as you shop.'),
      if (items.isEmpty) const Text('Your shopping list is empty.'),
      for (final item in items)
        Card(
          color: Colors.white,
          elevation: 0,
          child: CheckboxListTile(
            value: item.isPurchased,
            onChanged: (_) => toggle(item),
            title: Text(item.name),
            subtitle: Text(_details(item)),
          ),
        ),
    ],
  );

  String _details(ShoppingItem item) {
    final stock = pantry
        .where(
          (food) =>
              food.daysRemaining >= 0 &&
              normalizeName(food.name) == normalizeName(item.name) &&
              food.unit == item.unit,
        )
        .fold(0.0, (total, food) => total + food.quantity);
    final requested = '${quantityLabel(item.quantity)} ${item.unit}';
    return stock > 0
        ? '$requested · ${quantityLabel(stock)} ${item.unit} in pantry'
        : requested;
  }
}
