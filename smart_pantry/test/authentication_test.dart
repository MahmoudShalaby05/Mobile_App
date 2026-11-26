import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/features/authentication/login_page.dart';
import 'package:smart_pantry/features/authentication/signup_page.dart';
import 'package:smart_pantry/theme/pantry_theme.dart';

Future<String?> _unusedLogin({
  required String email,
  required String password,
}) async => throw StateError('Invalid input must not reach login');

Future<String?> _unusedSignup({
  required String fullName,
  required String email,
  required String password,
}) async => throw StateError('Invalid input must not reach signup');

Finder _field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

Future<void> _show(WidgetTester tester, Widget page) async {
  await tester.pumpWidget(MaterialApp(theme: pantryTheme(), home: page));
}

Widget _login({
  LoginSubmission onLogin = _unusedLogin,
  SignupSubmission onSignup = _unusedSignup,
}) => LoginPage(onLogin: onLogin, onSignup: onSignup);

Widget _signup({SignupSubmission onSignup = _unusedSignup}) =>
    SignupPage(onSignup: onSignup, onBackToLogin: () {});

Future<void> _tap(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pumpAndSettle();
}

Future<void> _fillSignup(
  WidgetTester tester, {
  String name = 'Ada Example',
  String email = 'ada@example.com',
  String password = 'pantry1',
  String confirmation = 'pantry1',
}) async {
  await tester.enterText(_field('Full name'), name);
  await tester.enterText(_field('Email'), email);
  await tester.enterText(_field('Password'), password);
  await tester.enterText(_field('Confirm password'), confirmation);
}

void main() {
  testWidgets('Login renders branding, credentials and signup navigation', (
    tester,
  ) async {
    await _show(tester, _login());

    expect(find.text('Smart Pantry'), findsOneWidget);
    expect(find.text('Welcome back'), findsOneWidget);
    expect(_field('Email'), findsOneWidget);
    expect(_field('Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Log in'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Sign up'), findsOneWidget);
  });

  testWidgets('Signup renders registration fields and login navigation', (
    tester,
  ) async {
    await _show(tester, _signup());

    expect(find.text('Create your account'), findsOneWidget);
    expect(_field('Full name'), findsOneWidget);
    expect(_field('Email'), findsOneWidget);
    expect(_field('Password'), findsOneWidget);
    expect(_field('Confirm password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create account'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Log in'), findsOneWidget);
  });

  testWidgets('Login requires an email and a password', (tester) async {
    await _show(tester, _login());
    await _tap(tester, find.widgetWithText(FilledButton, 'Log in'));

    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('Signup requires all four fields', (tester) async {
    await _show(tester, _signup());
    await _tap(tester, find.widgetWithText(FilledButton, 'Create account'));

    expect(find.text('Enter your full name.'), findsOneWidget);
    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(find.text('Confirm your password.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('Login rejects a malformed email', (tester) async {
    await _show(tester, _login());
    await tester.enterText(_field('Email'), 'ada@');
    await tester.enterText(_field('Password'), 'pantry1');
    await _tap(tester, find.widgetWithText(FilledButton, 'Log in'));

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('Signup rejects a malformed email and a short password', (
    tester,
  ) async {
    await _show(tester, _signup());
    await _fillSignup(
      tester,
      email: 'ada.example.com',
      password: 'short',
      confirmation: 'short',
    );
    await _tap(tester, find.widgetWithText(FilledButton, 'Create account'));

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Use at least 6 characters.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('Signup requires matching passwords', (tester) async {
    await _show(tester, _signup());
    await _fillSignup(tester, confirmation: 'pantry2');
    await _tap(tester, find.widgetWithText(FilledButton, 'Create account'));

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(find.text('Something went wrong. Please try again.'), findsNothing);
  });

  testWidgets('Password visibility controls act on their own fields', (
    tester,
  ) async {
    await _show(tester, _login());
    expect(tester.widget<TextField>(_field('Password')).obscureText, isTrue);
    await _tap(tester, find.byTooltip('Show password'));
    expect(tester.widget<TextField>(_field('Password')).obscureText, isFalse);
    await _tap(tester, find.byTooltip('Hide password'));
    expect(tester.widget<TextField>(_field('Password')).obscureText, isTrue);

    await _tap(tester, find.widgetWithText(TextButton, 'Sign up'));
    expect(
      tester.widget<TextField>(_field('Confirm password')).obscureText,
      isTrue,
    );
    await _tap(tester, find.byTooltip('Show password'));
    expect(tester.widget<TextField>(_field('Password')).obscureText, isFalse);
    expect(
      tester.widget<TextField>(_field('Confirm password')).obscureText,
      isTrue,
    );
    await _tap(tester, find.byTooltip('Show confirm password'));
    expect(
      tester.widget<TextField>(_field('Confirm password')).obscureText,
      isFalse,
    );
  });

  testWidgets('Signup returns to the same login form', (tester) async {
    await _show(tester, _login());
    await tester.enterText(_field('Email'), 'ada@example.com');
    await _tap(tester, find.widgetWithText(TextButton, 'Sign up'));
    expect(find.text('Create your account'), findsOneWidget);
    await _tap(tester, find.widgetWithText(TextButton, 'Log in'));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      tester.widget<TextField>(_field('Email')).controller!.text,
      'ada@example.com',
    );
  });

  testWidgets('Keyboard submission calls login once and displays its error', (
    tester,
  ) async {
    final response = Completer<String?>();
    final submissions = <(String, String)>[];
    await _show(
      tester,
      _login(
        onLogin: ({required email, required password}) {
          submissions.add((email, password));
          return response.future;
        },
      ),
    );
    await tester.enterText(_field('Email'), ' ada@example.com ');
    await tester.enterText(_field('Password'), ' pantry1 ');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();

    expect(submissions, [('ada@example.com', ' pantry1 ')]);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Sign up'))
          .onPressed,
      isNull,
    );

    response.complete('Check your credentials and try again.');
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Check your credentials and try again.'), findsOneWidget);
  });

  testWidgets('Valid six-character signup reaches the route callback', (
    tester,
  ) async {
    final submissions = <(String, String, String)>[];
    await _show(
      tester,
      _login(
        onSignup:
            ({required fullName, required email, required password}) async {
              submissions.add((fullName, email, password));
              return null;
            },
      ),
    );
    await _tap(tester, find.widgetWithText(TextButton, 'Sign up'));
    await _fillSignup(
      tester,
      name: ' Ada Example ',
      email: ' ada@example.com ',
      password: 'secret',
      confirmation: 'secret',
    );
    await _tap(tester, find.widgetWithText(FilledButton, 'Create account'));

    expect(submissions, [('Ada Example', 'ada@example.com', 'secret')]);
    expect(find.text('Create your account'), findsOneWidget);
  });
}
