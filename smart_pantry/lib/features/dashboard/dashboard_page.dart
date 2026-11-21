import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../theme/pantry_theme.dart';
import '../../widgets/pantry_widgets.dart';
import '../recipes/recipe_matcher.dart';
import '../recipes/recipe_presentation.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.pantryCount,
    required this.urgent,
    required this.shoppingCount,
    required this.recommendations,
    required this.openRecipe,
    required this.open,
    super.key,
  });

  final int pantryCount;
  final List<FoodItem> urgent;
  final int shoppingCount;
  final List<RecipeMatch> recommendations;
  final ValueChanged<RecipeMatch> openRecipe;
  final ValueChanged<int> open;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _HomeHero(
        recommendation: recommendations.firstOrNull,
        onBrowse: () => open(4),
      ),
      const SizedBox(height: 14),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ActionChip(
            avatar: const Icon(Icons.kitchen_outlined),
            label: Text('$pantryCount in pantry'),
            onPressed: () => open(1),
          ),
          ActionChip(
            avatar: const Icon(Icons.schedule),
            label: Text('${urgent.length} expiring soon'),
            onPressed: () => open(2),
          ),
          ActionChip(
            avatar: const Icon(Icons.shopping_basket_outlined),
            label: Text('$shoppingCount to buy'),
            onPressed: () => open(3),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Text(
              'Cook from your pantry',
              style: editorial.copyWith(fontSize: 25),
            ),
          ),
          TextButton(
            onPressed: () => open(4),
            child: const Text('See recipes'),
          ),
        ],
      ),
      const SizedBox(height: 8),
      if (recommendations.isEmpty)
        const Text('Recipes will appear here when they’re available.')
      else
        RecipeShelf(matches: recommendations, onOpen: openRecipe),
      const SizedBox(height: 22),
      Row(
        children: [
          Expanded(
            child: Text('Use first', style: editorial.copyWith(fontSize: 25)),
          ),
          TextButton(onPressed: () => open(2), child: const Text('View all')),
        ],
      ),
      if (urgent.isEmpty) const Text('Nothing expires in the next three days.'),
      for (final item in urgent.take(3)) PantryTile(item),
    ],
  );
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.recommendation, required this.onBrowse});

  final RecipeMatch? recommendation;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final featured = recommendation;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          if (featured != null)
            Positioned.fill(child: RecipePhoto(featured.recipe)),
          Container(
            constraints: const BoxConstraints(minHeight: 244),
            alignment: Alignment.bottomLeft,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x34222c22), Color(0xf21d251b)],
                stops: [0.05, 0.88],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cook what you have',
                  style: editorial.copyWith(fontSize: 34, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Find meals for the ingredients in your kitchen.',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 14),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: paper,
                    foregroundColor: pine,
                  ),
                  onPressed: onBrowse,
                  child: const Text('Explore recipes'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
