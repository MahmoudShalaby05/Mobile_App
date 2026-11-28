import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/app.dart';
import 'package:smart_pantry/features/authentication/auth_actions.dart';
import 'package:smart_pantry/providers/firebase_providers.dart';

class _User extends Fake implements User {
  _User(this.uid, this.displayName, this.email);

  @override
  final String uid;
  @override
  final String displayName;
  @override
  final String email;
}

class _Auth extends Fake implements FirebaseAuth {
  final states = StreamController<User?>.broadcast();

  @override
  Stream<User?> authStateChanges() => states.stream;

  @override
  Stream<User?> userChanges() => states.stream;

  @override
  Future<void> signOut() async => states.add(null);
}

Future<_Auth> _mountApp(WidgetTester tester) async {
  final auth = _Auth();
  addTearDown(auth.states.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [firebaseAuthProvider.overrideWithValue(auth)],
      child: const SmartPantryApp(authenticationEnabled: true),
    ),
  );
  return auth;
}

Future<void> _emit(WidgetTester tester, _Auth auth, User? user) async {
  auth.states.add(user);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Loading and auth stream errors never show protected pages', (
    tester,
  ) async {
    final auth = await _mountApp(tester);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);

    auth.states.addError(StateError('private failure details'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load your account session.'), findsOneWidget);
    expect(find.textContaining('private'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await _emit(tester, auth, null);
    expect(find.text('Welcome back'), findsOneWidget);
  });

  testWidgets('Logout discards account details and the Android Back stack', (
    tester,
  ) async {
    final auth = await _mountApp(tester);
    await _emit(tester, auth, _User('a', 'Account A', 'a@example.test'));
    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Account A'), findsOneWidget);
    expect(find.text('a@example.test'), findsOneWidget);

    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('a@example.test'), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('A UID change drops the previous route and mutable shell state', (
    tester,
  ) async {
    final auth = await _mountApp(tester);
    await _emit(tester, auth, _User('a', 'Account A', 'a@example.test'));
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pantry'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Mark Tomato as used'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mark Tomato as used'), findsNothing);

    await tester.tap(find.byTooltip('Account'));
    await tester.pumpAndSettle();
    await _emit(tester, auth, _User('b', 'Account B', 'b@example.test'));
    expect(find.text('a@example.test'), findsNothing);
    expect(find.text('Cook from your pantry'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Pantry'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mark Tomato as used'), findsOneWidget);
  });

  test('Credential failures avoid account enumeration and raw errors', () {
    String message(String code) => authErrorMessage(
      FirebaseAuthException(code: code, message: 'private SDK message'),
    );
    expect(message('invalid-credential'), message('user-not-found'));
    expect(message('wrong-password'), message('user-disabled'));
    expect(message('network-request-failed'), contains('connection'));
    expect(message('too-many-requests'), contains('Too many'));
    expect(message('some-unknown-code'), isNot(contains('private')));
  });
}
