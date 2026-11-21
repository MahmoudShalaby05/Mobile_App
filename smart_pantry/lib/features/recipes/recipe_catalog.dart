import 'recipe.dart';

const starterRecipes = [
  Recipe(
    'Tomato & cheese omelette',
    15,
    [
      Ingredient('Egg', 2, 'pieces'),
      Ingredient('Tomato', 1, 'pieces'),
      Ingredient('Cheese', 30, 'g'),
    ],
    [
      'Dice the tomato and grate the cheese.',
      'Beat the eggs and pour them into a warm nonstick pan.',
      'When the eggs begin to set, add the tomato and cheese. Fold and cook through.',
    ],
    imageAsset: 'assets/food/omelette.jpg',
  ),
  Recipe(
    'Spinach & chickpea rice bowl',
    25,
    [
      Ingredient('Rice', 150, 'g'),
      Ingredient('Spinach', 80, 'g'),
      Ingredient('Chickpeas', 200, 'g'),
      Ingredient('Lemon', 1, 'pieces'),
    ],
    [
      'Cook the rice according to its package.',
      'Drain the cooked chickpeas and warm them with the spinach.',
      'Serve over the rice and finish with lemon juice.',
    ],
    imageAsset: 'assets/food/rice-bowl.jpg',
  ),
  Recipe(
    'Cheesy spinach scramble',
    12,
    [
      Ingredient('Egg', 3, 'pieces'),
      Ingredient('Spinach', 60, 'g'),
      Ingredient('Cheese', 30, 'g'),
      Ingredient('Milk', 50, 'ml'),
    ],
    [
      'Wilt the spinach in a warm pan.',
      'Beat the eggs with milk and pour them into the pan.',
      'Stir gently until cooked through, then fold in the cheese.',
    ],
    imageAsset: 'assets/food/scramble.jpg',
  ),
];
