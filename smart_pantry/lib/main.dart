import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'theme/pantry_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
  }

  runApp(const ProviderScope(child: SmartPantryApp()));
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
