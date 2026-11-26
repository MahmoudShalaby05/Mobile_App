# Shared Firebase and Riverpod foundation

The Firebase CLI verified project `smart-pantry-10613` and its default Firestore database. The Android application ID is `com.example.smart_pantry`. FlutterFire reused the Android registration `1:311411859125:android:425fe8ccfbd87dc97be8fc` to generate `lib/firebase_options.dart`, `android/app/google-services.json`, and the Flutter settings in `firebase.json`. Android is the configured Firebase target. Web, iOS, macOS, Windows, and Linux start in guest mode without Firebase.

## Dependencies

| Package | Declared | Resolved |
| --- | --- | --- |
| `firebase_core` | `^5.2.0` | `5.2.0` |
| `firebase_auth` | `^7.1.0` | `7.1.0` |
| `cloud_firestore` | `^7.2.0` | `7.2.0` |
| `flutter_riverpod` | `^3.5.0` | `3.5.0` |

## Startup and authentication state

`lib/main.dart` waits for Firebase initialization on Android using the generated options, then wraps the existing `SmartPantryApp` in `ProviderScope`. If Android initialization fails, startup displays an error. The guest app uses its in-memory demo state, and the login and signup screens retain their existing submission interfaces for a later phase.

`lib/providers/firebase_providers.dart` exposes three providers:

- `firebaseAuthProvider` and `firestoreProvider` lazily resolve the default Firebase instances when read. Use them on a configured platform after initialization succeeds.
- `authStateProvider` wraps Firebase Auth's `authStateChanges()` in a `StreamProvider<User?>`. In a consumer or provider, use `ref.watch(authStateProvider)`. Handle loading and error states explicitly. The data value is null for a signed-out user and `user.uid` identifies a signed-in user's data.

For isolated tests, override `firebaseAuthProvider` or `firestoreProvider` in a provider container or scope. The original widget tests can continue to pump `SmartPantryApp` directly.

## Firestore paths and ownership

| Path | Owner | Provider contract |
| --- | --- | --- |
| `users/{uid}` | Member 1 | User profile document scoped to the signed-in UID |
| `users/{uid}/pantryItems/{itemId}` | Member 2 | `pantryProvider` exposes the active user's pantry items as `FoodItem` records |
| `users/{uid}/settings/notifications` | Member 3 | `expirationProvider` derives Use First and expiration information from active-user pantry data. Notification preferences use the fixed document path. |
| `users/{uid}/shoppingItems/{itemId}` | Member 4 | `shoppingProvider` exposes the active user's shopping items as `ShoppingItem` records |
| `users/{uid}/mealPlans/{planId}` | Member 5 | `recipeMatchesProvider` derives recommendations from the recipe catalog and the active user's pantry. Saved meal plans use the meal plan collection. |

The proposed rules allow only the authenticated UID to access the approved documents and collections. The profile and notification settings are fetched by document path. The pantry, shopping, and meal plan collections may be queried under the user's path. The current deployed rule denies all access. The proposed rules are local and require separate deployment approval.

The Firestore Local Emulator Suite passed 69 checks against the proposed rules using a demo project ID. The checks cover owner reads and writes, allowed collection queries, cross-user and anonymous denial, and denial for unknown paths. Rules testing used the Node rules testing library outside the Flutter app.

Keep the existing model conventions. `FoodItem` and `ShoppingItem` use string IDs, names, units, and double quantities. `FoodItem` carries category, location, and an expiration date. `ShoppingItem` carries purchase state. Existing name normalization trims whitespace, folds case, and collapses internal whitespace. Coordinate ingredient names, compatible units, date semantics, and Firestore field serialization before integrating persistence.

## Adoption after merge

1. Run `flutter pub get` from `smart_pantry` and use a configured Android build or isolated provider overrides for development and tests. The generated client configuration is included. Account access is needed if you regenerate it with FlutterFire.
2. Wait for the authenticated session flow before connecting feature writes. Watch authentication state, scope each read and write to the current UID, and avoid starting user queries while authentication is loading or signed out.
3. Key user-scoped providers by UID or rebuild them when the UID changes. Dispose old listeners and invalidate user-scoped caches on logout and account switch. Clear the displayed data while loading the next account and disregard stale in-flight results for the previous UID.
4. Members 2 and 4 must implement their per-user stores. Member 3 must agree on expiration semantics with Member 2 and connect notification preferences. Member 5 must agree on pantry matching inputs with Member 2 and the shopping handoff with Member 4, then implement meal plan persistence. Coordinate each integration through its feature owner.

The Firebase plugin modules require Android SDK Platform 34 alongside the app's existing compile SDK. If Kotlin reports that the project and Pub cache have different roots on Windows, build with the project and Pub cache on the same drive.
