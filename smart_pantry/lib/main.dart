import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'providers/firebase_providers.dart';
import 'theme/pantry_theme.dart';

const _emulatorMode = bool.fromEnvironment('USE_FIREBASE_EMULATORS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseEnabled =
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  FirebaseAuth? emulatorAuth;
  FirebaseFirestore? emulatorFirestore;
  try {
    if (_emulatorMode) {
      if (!kDebugMode || !firebaseEnabled) {
        throw UnsupportedError(
          'Firebase emulators require an Android debug build.',
        );
      }

      // Use a separate Firebase app identity so emulator sessions are isolated
      // from the Android production configuration, including across restarts.
      final app = await Firebase.initializeApp(
        demoProjectId: 'demo-smart-pantry',
      );
      emulatorAuth = FirebaseAuth.instanceFor(app: app);
      emulatorFirestore = FirebaseFirestore.instanceFor(app: app);
      await emulatorAuth.useAuthEmulator('10.0.2.2', 19099);
      emulatorFirestore.settings = const Settings(persistenceEnabled: false);
      emulatorFirestore.useFirestoreEmulator('10.0.2.2', 18080);
    } else if (firebaseEnabled) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        context: ErrorDescription('while initializing Firebase'),
      ),
    );
    runApp(const _FirebaseStartupError());
    return;
  }

  runApp(
    ProviderScope(
      overrides: [
        if (emulatorAuth != null)
          firebaseAuthProvider.overrideWithValue(emulatorAuth),
        if (emulatorFirestore != null)
          firestoreProvider.overrideWithValue(emulatorFirestore),
      ],
      child: SmartPantryApp(authenticationEnabled: firebaseEnabled),
    ),
  );
}

class _FirebaseStartupError extends StatelessWidget {
  const _FirebaseStartupError();

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Smart Pantry',
    theme: pantryTheme(),
    home: const Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Smart Pantry could not initialize Firebase. '
              'Close and reopen the app to try again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ),
  );
}
