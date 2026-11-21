import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../widgets/pantry_widgets.dart';

class UseFirstPage extends StatelessWidget {
  const UseFirstPage({required this.items, super.key});

  final List<FoodItem> items;

  @override
  Widget build(BuildContext context) {
    final attention = items.where((item) => item.daysRemaining <= 3).toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'Use first',
          'See what has expired or expires within three days.',
        ),
        if (attention.isEmpty) const Text('You’re all caught up.'),
        for (final item in attention) PantryTile(item),
      ],
    );
  }
}
