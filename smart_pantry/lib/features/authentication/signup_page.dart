import 'package:flutter/material.dart';

import 'auth_form.dart';

/// Submits registration details and returns a user-facing message on failure.
/// The caller owns any navigation or session changes after success.
typedef SignupSubmission = Future<String?> Function({
  required String fullName,
  required String email,
  required String password,
});

class SignupPage extends StatefulWidget {
  const SignupPage({
    required this.onSignup,
    required this.onBackToLogin,
    super.key,
  });

  final SignupSubmission onSignup;
  final VoidCallback onBackToLogin;

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    final requiredError = requirePassword(value);
    if (requiredError != null) return requiredError;
    if (value!.length < 6) return 'Use at least 6 characters.';
    return null;
  }

  String? _validateConfirmation(String? value) {
    if (value == null || value.isEmpty) return 'Confirm your password.';
    if (value != _password.text) return 'Passwords do not match.';
    return null;
  }

  @override
  Widget build(BuildContext context) => AuthForm(
    heading: 'Create your account',
    description: 'Start tracking what’s in your pantry.',
    actionLabel: 'Create account',
    pendingLabel: 'Creating account…',
    onSubmit: () => widget.onSignup(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
    ),
    prompt: 'Already have an account?',
    linkLabel: 'Log in',
    onLinkPressed: widget.onBackToLogin,
    buildFields: (submit, submitting) => [
      TextFormField(
        controller: _name,
        enabled: !submitting,
        keyboardType: TextInputType.name,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.name],
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Enter your full name.'
            : null,
        decoration: const InputDecoration(labelText: 'Full name'),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _email,
        enabled: !submitting,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        autocorrect: false,
        validator: validateEmail,
        decoration: const InputDecoration(labelText: 'Email'),
      ),
      const SizedBox(height: 16),
      AuthPasswordField(
        label: 'Password',
        controller: _password,
        validator: _validatePassword,
        enabled: !submitting,
        autofillHint: AutofillHints.newPassword,
      ),
      const SizedBox(height: 16),
      AuthPasswordField(
        label: 'Confirm password',
        controller: _confirmation,
        validator: _validateConfirmation,
        enabled: !submitting,
        autofillHint: AutofillHints.newPassword,
        onSubmitted: submit,
      ),
    ],
  );
}
