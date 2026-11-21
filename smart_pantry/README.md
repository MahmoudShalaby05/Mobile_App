# Smart Pantry

A Flutter starter for the CSC422 Food Waste Reduction & Smart Pantry project. Open the app in guest mode with sample pantry and shopping data. The demo shares state across tabs for the current session and resets on restart.

## Run on the Android emulator

1. In Android Studio, open **Tools → Device Manager** and start your Android virtual device. If the list is empty, create a Pixel virtual device and download a system image through Device Manager.
2. Wait for the Android home screen. Open PowerShell in the Smart Pantry folder and run:

```powershell
flutter pub get
flutter devices
flutter run -d emulator-5554
```

Use the Android emulator ID shown by `flutter devices` if it differs from `emulator-5554`. You can also list installed virtual devices with `flutter emulators` and start one with `flutter emulators --launch Pixel_7` if it uses that name. Press `r` for hot reload or `q` to stop the app.

If the emulator is listed as **offline**, use **Device Manager → Pixel device menu → Cold Boot Now**, then wait for the Android home screen and run `flutter devices` again.

If Gradle reports a missing Android platform, install the requested API under **SDK Manager → SDK Platforms**. The current Flutter setup uses **Android API 36** to build, even if the emulator runs a different Android version.

If Gradle reports a missing NDK, open **Android Studio → Tools → SDK Manager → SDK Tools**, enable **Show Package Details**, and install the requested version under **NDK (Side by side)**. Use `flutter doctor -v` for other Android toolchain issues.

## Team ownership

| Member | Starter files | Next implementation |
| --- | --- | --- |
| 1 | `lib/app.dart`, `lib/theme/`, `lib/features/dashboard/`, `lib/features/authentication/` | Login, signup, session handling, dashboard integration |
| 2 | `lib/features/pantry/`, `lib/models/food_item.dart` | Add/edit/delete forms, filters and Firestore CRUD |
| 3 | `lib/features/expiration/` | Expiration rules, configurable reminders and Android notifications |
| 4 | `lib/features/shopping/`, `lib/models/shopping_item.dart` | Shopping CRUD, duplicate checks and Firestore persistence |
| 5 | `lib/features/recipes/` | Recipe catalog, matching, shopping handoff and meal planning |

The shell owns the in-memory lists. When integrating Firebase and Riverpod, have feature screens read the same pantry and shopping providers. Agree on canonical ingredient names, supported units and expiration rules before wiring the providers.

## Member 5 — Recipes and meal planning

Try **Home → Explore recipes → Spinach & chickpea rice bowl**. The detail screen shows the quantities still needed. **Add missing to shopping list** opens Shopping and reuses existing unchecked entries with the same name and unit. Mark Tomato as used in Pantry to see the omelette fall from ready to cook to two of three ingredients available.

1. Give each recipe a stable ID and expand the three Dart samples into a curated catalog of 20–30 recipes in a local JSON asset. Include serving size, prep time, quantities, units and instructions.
2. Extend `recipe_matcher.dart` with the shared ingredient names and expiry policy. It already aggregates matching non-expired stock, converts kg/g and L/ml, ranks cookable recipes first, then favors expiring ingredients. Test partial stock, mixed units, and expired entries.
3. Wire `addMissing` to Member 4’s shopping provider. Agree on merging repeated additions and pending quantities. The demo keeps the larger pending amount when an exact name and unit match already exists.
4. Add a weekly planner with seven date slots and a recipe picker. Store the date and recipe ID for each planned meal, allow replacing or clearing a slot, and agree on per-user persistence with Member 1.
5. Demo the full flow by changing pantry stock, opening a recommendation, adding ingredient shortfalls to Shopping, and assigning the recipe to a day.

```powershell
flutter analyze
flutter test
```

