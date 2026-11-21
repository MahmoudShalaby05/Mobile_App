import 'package:flutter/material.dart';

import '../models/food_item.dart';
import '../theme/pantry_theme.dart';

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.description, {super.key});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: editorial.copyWith(fontSize: 38)),
        const SizedBox(height: 6),
        Text(description, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

class PantryTile extends StatelessWidget {
  const PantryTile(this.item, {this.trailing, super.key});

  final FoodItem item;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final days = item.daysRemaining;
    final status = switch (days) {
      < 0 => 'Expired',
      0 => 'Expires today',
      1 => 'Expires tomorrow',
      _ => 'Expires in $days days',
    };
    final (icon, color) = switch (item.category) {
      'Produce' => (Icons.eco_outlined, lime),
      'Dairy' => (Icons.water_drop_outlined, const Color(0xffe5edf8)),
      _ => (Icons.inventory_2_outlined, peach),
    };
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          foregroundColor: pine,
          child: Icon(icon),
        ),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${quantityLabel(item.quantity)} ${item.unit} · ${item.location}\n$status',
        ),
        isThreeLine: true,
        trailing: trailing,
      ),
    );
  }
}
