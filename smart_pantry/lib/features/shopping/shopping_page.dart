import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../models/shopping_item.dart';
import '../../widgets/pantry_widgets.dart';
import 'add_shopping_item_dialog.dart';

class ShoppingPage extends StatelessWidget {
  const ShoppingPage({
    required this.items,
    required this.pantry,
    required this.toggle,
    required this.onAddItem,
    required this.onEditItem,
    required this.onDeleteItem,
    super.key,
  });

  final List<ShoppingItem> items;
  final List<FoodItem> pantry;
  final ValueChanged<ShoppingItem> toggle;
  final void Function(String name, double quantity, String unit) onAddItem;
  final void Function(
    ShoppingItem item,
    String name,
    double quantity,
    String unit,
  ) onEditItem;

  final ValueChanged<ShoppingItem> onDeleteItem;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const PageHeading('Shopping list', 'Check off groceries as you shop.'),
      const SizedBox(height: 12),

      // NEW: Add Item button
      FilledButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddShoppingItemDialog(onAdd: onAddItem);
            },
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),

      const SizedBox(height: 12),
      if (items.isEmpty) const Text('Your shopping list is empty.'),
      for (final item in items)
  Card(
    color: Colors.white,
    elevation: 0,
    child: Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            value: item.isPurchased,
            onChanged: (_) => toggle(item),
            title: Text(item.name),
            subtitle: Text(_details(item)),
          ),
        ),

        // Edit button
        IconButton(
          tooltip: 'Edit Item',
          icon: const Icon(Icons.edit_outlined),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AddShoppingItemDialog(
                  existingItem: item,
                  onAdd: (name, quantity, unit) {
                    onEditItem(item, name, quantity, unit);
                  },
                );
              },
            );
          },
        ),

        // Delete button
        IconButton(
          tooltip: 'Delete Item',
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _confirmDelete(context, item);
          },
        ),
      ],
    ),
  ),
    ],
  );
void _confirmDelete(
  BuildContext context,
  ShoppingItem item,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete Shopping Item'),
        content: Text(
          'Are you sure you want to delete ${item.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onDeleteItem(item);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );
}
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
