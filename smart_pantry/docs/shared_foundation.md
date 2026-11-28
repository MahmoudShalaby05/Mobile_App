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

`lib/main.dart` waits for Firebase initialization on Android, then enables authentication in `SmartPantryApp`. The router uses the first `authStateProvider` event to choose the existing login flow or the authenticated shell. Firebase Auth persists the native session across restarts. A logout or UID change replaces the navigator and resets the shell’s in-memory state, including the current tab and local demo edits. Non-Android targets still provide the local preview.

Email/password registration saves the full name to the Firebase Auth profile. The Account screen shows the Auth name and email and supports logout. A new account does not create a Firestore profile document or seed feature data. If the profile name cannot be saved, the account remains usable and the Account screen shows the email.

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

The rules deployed to `smart-pantry-10613` on November 28, 2026 allow only the authenticated UID to access the approved documents and collections. The deployed source was verified against this repository's `firestore.rules`. Fetch the profile and notification settings by document path. Query pantry, shopping, and meal plan collections under the user's path. Use the local emulators for automated tests and synthetic fixtures.

The isolated regression suite checks owner CRUD, collection queries, cross-user and anonymous denial, and denied unapproved paths. It uses Auth emulator session tokens against the Firestore emulator.

Keep the existing model conventions. `FoodItem` and `ShoppingItem` use string IDs, names, units, and double quantities. `FoodItem` carries category, location, and an expiration date. `ShoppingItem` carries purchase state. Existing name normalization trims whitespace, folds case, and collapses internal whitespace. Coordinate ingredient names, compatible units, date semantics, and Firestore field serialization before integrating persistence.

## Local Auth and Firestore verification

Run these commands from `smart_pantry`. The loopback-only configuration uses the demo project `demo-smart-pantry` and the repository’s proposed `firestore.rules`. It starts Auth on port 19099 and Firestore on port 18080.

```powershell
firebase.cmd emulators:exec --only auth,firestore --project demo-smart-pantry --config firebase.emulators.json "node test/firestore_emulator_test.mjs"
```

For interactive checks, start the emulators in one terminal, then run the Android build from a second terminal.

```powershell
firebase.cmd emulators:start --only auth,firestore --project demo-smart-pantry --config firebase.emulators.json
flutter run -d <android-emulator-id> --dart-define=USE_FIREBASE_EMULATORS=true
```

The debug flag selects a separate named Firebase app and routes both shared providers to the emulators through Android’s host address `10.0.2.2`. The demo app has a separate persistent Auth session. Stop the emulators when finished. Use local test credentials for signup, login, relaunch, logout, and account-switch checks. A normal Android build uses the existing project configuration.

## Adoption after merge

1. Run `flutter pub get` from `smart_pantry` and use a configured Android build or isolated provider overrides for development and tests. The generated client configuration is included. Account access is needed if you regenerate it with FlutterFire.
2. Watch `ref.watch(authStateProvider)` before starting feature queries. Wait for a signed-in `User` while authentication is settled, then use `user.uid` and obtain the shared Firestore instance with `ref.watch(firestoreProvider)`. Build document and collection references under `users/{uid}` using the table above. Use the local emulators for synthetic data and automated tests.
3. Key user-scoped providers by UID or rebuild them when the UID changes. Dispose old listeners and invalidate user-scoped caches on logout and account switch. Clear the displayed data while loading the next account and disregard stale in-flight results for the previous UID.
4. Members 2 and 4 must implement their per-user stores. Member 3 must agree on expiration semantics with Member 2 and connect notification preferences. Member 5 must agree on pantry matching inputs with Member 2 and the shopping handoff with Member 4, then implement meal plan persistence. Coordinate each integration through its feature owner.

The Firebase plugin modules require Android SDK Platform 34 alongside the app's existing compile SDK. If Kotlin reports that the project and Pub cache have different roots on Windows, build with the project and Pub cache on the same drive.

## Mandatory before final Android distribution

The Android `release` build type currently uses the debug signing configuration. Replace it with the approved release signing configuration and verify the signed release artifact before distribution. Keep signing keys and credentials outside version control. The current milestone covers development and Android debug testing.
