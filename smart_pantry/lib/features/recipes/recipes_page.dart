import 'package:flutter/material.dart';

import '../../models/food_item.dart';
import '../../theme/pantry_theme.dart';
import '../../widgets/pantry_widgets.dart';
import 'recipe.dart';
import 'recipe_matcher.dart';
import 'recipe_presentation.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({required this.matches, required this.onOpen, super.key});

  final List<RecipeMatch> matches;
  final ValueChanged<RecipeMatch> onOpen;

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  String _query = '';
  bool _readyOnly = false;

  @override
  Widget build(BuildContext context) {
    final matches = widget.matches.where((match) {
      final recipe = match.recipe;
      return (!_readyOnly || match.shortfalls.isEmpty) &&
          (normalizeName(recipe.title).contains(_query) ||
              recipe.ingredients.any(
                (ingredient) => normalizeName(ingredient.name).contains(_query),
              ));
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PageHeading(
          'Explore recipes',
          'Find something to cook with what you have.',
        ),
        TextField(
          onChanged: (query) => setState(() => _query = normalizeName(query)),
          decoration: const InputDecoration(
            labelText: 'Search recipes or ingredients',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: FilterChip(
            label: const Text('Ready to cook'),
            selected: _readyOnly,
            onSelected: (selected) => setState(() => _readyOnly = selected),
          ),
        ),
        const SizedBox(height: 16),
        if (matches.isEmpty)
          const Text('No recipes match your search.')
        else
          RecipeGrid(matches: matches, onOpen: widget.onOpen),
      ],
    );
  }
}

void showRecipe(
  BuildContext context,
  RecipeMatch match,
  ValueChanged<List<Ingredient>> addMissing,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (detailContext) => Scaffold(
        appBar: AppBar(title: const Text('Recipe')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 740),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          height: 235,
                          child: RecipePhoto(match.recipe),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PageHeading(
                        match.recipe.title,
                        '${match.recipe.minutes} min',
                      ),
                      Text(
                        'Ingredients',
                        style: editorial.copyWith(fontSize: 25),
                      ),
                      for (final ingredient in match.recipe.ingredients)
                        _IngredientRow(ingredient),
                      if (match.shortfalls.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Still needed',
                          style: editorial.copyWith(fontSize: 25, color: clay),
                        ),
                        for (final ingredient in match.shortfalls)
                          _IngredientRow(ingredient),
                        FilledButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Add missing to shopping list'),
                          onPressed: () {
                            addMissing(match.shortfalls);
                            Navigator.of(detailContext).pop();
                          },
                        ),
                      ],
                      const SizedBox(height: 24),
                      Text('Method', style: editorial.copyWith(fontSize: 25)),
                      for (final (index, step)
                          in match.recipe.instructions.indexed)
                        ListTile(
                          leading: Text('${index + 1}'),
                          title: Text(step),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow(this.ingredient);

  final Ingredient ingredient;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(ingredient.name),
    trailing: Text('${quantityLabel(ingredient.quantity)} ${ingredient.unit}'),
  );
}
