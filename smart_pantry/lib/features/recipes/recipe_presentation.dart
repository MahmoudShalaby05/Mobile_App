import 'package:flutter/material.dart';

import '../../theme/pantry_theme.dart';
import 'recipe.dart';
import 'recipe_matcher.dart';

class RecipePhoto extends StatelessWidget {
  const RecipePhoto(this.recipe, {super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final asset = recipe.imageAsset;
    return SizedBox.expand(
      child: asset == null
          ? const ColoredBox(
              color: peach,
              child: Center(child: Icon(Icons.restaurant_menu, size: 36)),
            )
          : Image.asset(asset, fit: BoxFit.cover, excludeFromSemantics: true),
    );
  }
}

class RecipeShelf extends StatelessWidget {
  const RecipeShelf({required this.matches, required this.onOpen, super.key});

  final List<RecipeMatch> matches;
  final ValueChanged<RecipeMatch> onOpen;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, match) in matches.indexed) ...[
          if (index > 0) const SizedBox(width: 12),
          SizedBox(
            width: 220,
            child: _RecipeCard(match: match, onTap: () => onOpen(match)),
          ),
        ],
      ],
    ),
  );
}

class RecipeGrid extends StatelessWidget {
  const RecipeGrid({required this.matches, required this.onOpen, super.key});

  final List<RecipeMatch> matches;
  final ValueChanged<RecipeMatch> onOpen;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const gap = 16.0;
      final columns = constraints.maxWidth >= 830
          ? 3
          : constraints.maxWidth >= 490
          ? 2
          : 1;
      final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final match in matches)
            SizedBox(
              width: width,
              child: _RecipeCard(match: match, onTap: () => onOpen(match)),
            ),
        ],
      );
    },
  );
}

class _RecipeCard extends StatelessWidget {
  const _RecipeCard({required this.match, required this.onTap});

  final RecipeMatch match;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ready = match.shortfalls.isEmpty;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(aspectRatio: 1.65, child: RecipePhoto(match.recipe)),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.recipe.minutes} min · ${ready ? 'Ready to cook' : '${match.available}/${match.recipe.ingredients.length} ingredients'}',
                    style: TextStyle(
                      color: ready ? leaf : clay,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    match.recipe.title,
                    style: editorial.copyWith(fontSize: 24),
                  ),
                  if (match.expiringIngredients > 0) ...[
                    const SizedBox(height: 9),
                    Text(
                      'Uses ${match.expiringIngredients} expiring ${match.expiringIngredients == 1 ? 'ingredient' : 'ingredients'}',
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
