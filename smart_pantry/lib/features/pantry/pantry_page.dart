import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../widgets/pantry_widgets.dart';

class PantryPage extends StatefulWidget {
  const PantryPage({required this.items, required this.consume, super.key});

  final List<FoodItem> items;
  final ValueChanged<FoodItem> consume;

  @override
  State<PantryPage> createState() => _PantryPageState();
}

class _PantryPageState extends State<PantryPage> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final items = widget.items
        .where(
          (item) => normalizeName(item.name).contains(normalizeName(query)),
        )
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading('My pantry', 'Keep track of what’s in your kitchen.'),
        TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: const InputDecoration(
            labelText: 'Search ingredients',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty) const Text('No ingredients found.'),
        for (final item in items)
          PantryTile(
            item,
            trailing: IconButton(
              tooltip: 'Mark ${item.name} as used',
              icon: const Icon(Icons.check_circle_outline),
              onPressed: () => widget.consume(item),
            ),
          ),
      ],
    );
  }
}
