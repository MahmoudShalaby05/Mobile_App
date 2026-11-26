import 'package:flutter/material.dart';

import 'auth_form.dart';
import 'signup_page.dart';

/// Submits credentials and returns a user-facing message if the attempt fails.
/// The caller owns any navigation or session changes after success.
typedef LoginSubmission = Future<String?> Function({
  required String email,
  required String password,
});

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onLogin, required this.onSignup, super.key});

  final LoginSubmission onLogin;
  final SignupSubmission onSignup;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _openSignup() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => SignupPage(
          onSignup: widget.onSignup,
          onBackToLogin: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AuthForm(
    heading: 'Welcome back',
    description: 'Log in to your Smart Pantry account.',
    actionLabel: 'Log in',
    pendingLabel: 'Logging in…',
    onSubmit: () =>
        widget.onLogin(email: _email.text.trim(), password: _password.text),
    prompt: 'New to Smart Pantry?',
    linkLabel: 'Sign up',
    onLinkPressed: _openSignup,
    buildFields: (submit, submitting) => [
      TextFormField(
        controller: _email,
        enabled: !submitting,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
        autocorrect: false,
        validator: validateEmail,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: 16),
      AuthPasswordField(
        label: 'Password',
        controller: _password,
        validator: requirePassword,
        enabled: !submitting,
        autofillHint: AutofillHints.password,
        onSubmitted: submit,
      ),
    ],
  );
}
