import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'demo_data.dart';
import 'features/authentication/account_page.dart';
import 'features/authentication/auth_actions.dart';
import 'features/authentication/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/expiration/use_first_page.dart';
import 'features/pantry/pantry_page.dart';
import 'features/recipes/recipe.dart';
import 'features/recipes/recipe_catalog.dart';
import 'features/recipes/recipe_matcher.dart';
import 'features/recipes/recipes_page.dart';
import 'features/shopping/shopping_page.dart';
import 'models/food_item.dart';
import 'models/shopping_item.dart';
import 'providers/firebase_providers.dart';
import 'theme/pantry_theme.dart';

class SmartPantryApp extends StatelessWidget {
  const SmartPantryApp({this.authenticationEnabled = false, super.key});

  final bool authenticationEnabled;

  @override
  Widget build(BuildContext context) => authenticationEnabled
      ? const _SessionApp()
      : _pantryApp(const _PantryShell());
}

MaterialApp _pantryApp(Widget home, {Key? key}) => MaterialApp(
  key: key,
  title: 'Smart Pantry',
  debugShowCheckedModeBanner: false,
  theme: pantryTheme(),
  home: home,
);

class _SessionApp extends ConsumerStatefulWidget {
  const _SessionApp();

  @override
  ConsumerState<_SessionApp> createState() => _SessionAppState();
}

class _SessionAppState extends ConsumerState<_SessionApp> {
  bool _registering = false;

  Future<String?> _signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    setState(() => _registering = true);
    try {
      return await register(
        ref.read(firebaseAuthProvider),
        fullName: fullName,
        email: email,
        password: password,
      );
    } finally {
      if (mounted) setState(() => _registering = false);
    }
  }

  @override
  Widget build(BuildContext context) => ref
      .watch(authStateProvider)
      .when(
        loading: () => _pantryApp(
          const Scaffold(body: Center(child: CircularProgressIndicator())),
          key: const ValueKey(('loading', null)),
        ),
        error: (_, _) => _pantryApp(
          Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Could not load your account session.'),
                    TextButton(
                      onPressed: () => ref.invalidate(authStateProvider),
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          key: const ValueKey(('error', null)),
        ),
        data: (user) {
          if (user == null || _registering) {
            return _pantryApp(
              LoginPage(
                onLogin: ({required email, required password}) => signIn(
                  ref.read(firebaseAuthProvider),
                  email: email,
                  password: password,
                ),
                onSignup: _signup,
              ),
              key: const ValueKey(('signed-out', null)),
            );
          }

          // Recreate the navigator and shell on every UID change. No old route or
          // in-memory feature state can survive a sign-out or account switch.
          return _pantryApp(
            _PantryShell(user: user),
            key: ValueKey(('signed-in', user.uid)),
          );
        },
        skipLoadingOnRefresh: false,
        skipLoadingOnReload: false,
      );
}

class _PantryShell extends StatefulWidget {
  const _PantryShell({this.user});

  final User? user;

  @override
  State<_PantryShell> createState() => _PantryShellState();
}

class _PantryShellState extends State<_PantryShell> {
  final _pantry = demoPantry();
  final _shopping = [...demoShopping];
  int _selected = 0;
  int _nextShoppingId = 0;

  void _open(int index) => setState(() => _selected = index);

  void _addMissing(List<Ingredient> missing) {
    setState(() {
      for (final ingredient in missing) {
        final index = _shopping.indexWhere(
          (item) =>
              !item.isPurchased &&
              normalizeName(item.name) == normalizeName(ingredient.name) &&
              item.unit == ingredient.unit,
        );
        if (index == -1) {
          _shopping.add(
            ShoppingItem(
              'recipe-${_nextShoppingId++}',
              ingredient.name,
              ingredient.quantity,
              ingredient.unit,
            ),
          );
        } else if (_shopping[index].quantity < ingredient.quantity) {
          _shopping[index] = ShoppingItem(
            _shopping[index].id,
            ingredient.name,
            ingredient.quantity,
            ingredient.unit,
          );
        }
      }
      _selected = 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final urgent = _pantry.where((item) => item.isExpiringSoon).toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
    final recommendations = matchRecipes(starterRecipes, _pantry);

    void openRecipe(RecipeMatch match) =>
        showRecipe(context, match, _addMissing);

    final page = switch (_selected) {
      0 => DashboardPage(
        pantryCount: _pantry.length,
        urgent: urgent,
        shoppingCount: _shopping.where((item) => !item.isPurchased).length,
        recommendations: recommendations,
        openRecipe: openRecipe,
        open: _open,
      ),
      1 => PantryPage(
        items: _pantry,
        consume: (item) => setState(() => _pantry.remove(item)),
      ),
      2 => UseFirstPage(items: _pantry),
      3 => ShoppingPage(
        items: _shopping,
        pantry: _pantry,
        toggle: (item) =>
            setState(() => _shopping[_shopping.indexOf(item)] = item.toggle()),
      ),
      _ => RecipesPage(matches: recommendations, onOpen: openRecipe),
    };

    return PopScope<Object?>(
      canPop: _selected == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selected != 0) _open(0);
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          title: const Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: pine,
                foregroundColor: lime,
                child: Icon(Icons.restaurant_menu, size: 18),
              ),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Smart Pantry',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: editorial,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Account',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => AccountPage(user: widget.user),
                ),
              ),
              icon: const Icon(Icons.account_circle_outlined),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            key: ValueKey(_selected),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 740),
                child: SizedBox(width: double.infinity, child: page),
              ),
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selected,
          onDestinationSelected: _open,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.kitchen_outlined),
              label: 'Pantry',
            ),
            NavigationDestination(
              icon: Icon(Icons.schedule),
              label: 'Use first',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_basket_outlined),
              label: 'Shopping',
            ),
            NavigationDestination(
              icon: Icon(Icons.restaurant_menu),
              label: 'Recipes',
            ),
          ],
        ),
      ),
    );
  }
}
