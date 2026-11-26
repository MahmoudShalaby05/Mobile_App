import 'package:flutter/material.dart';

import '../../theme/pantry_theme.dart';
import '../../widgets/pantry_widgets.dart';

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email address.';
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
    return 'Enter a valid email address.';
  }
  return null;
}

String? requirePassword(String? value) =>
    value == null || value.trim().isEmpty ? 'Enter your password.' : null;

class AuthForm extends StatefulWidget {
  const AuthForm({
    required this.heading,
    required this.description,
    required this.actionLabel,
    required this.pendingLabel,
    required this.onSubmit,
    required this.buildFields,
    required this.prompt,
    required this.linkLabel,
    required this.onLinkPressed,
    super.key,
  });

  final String heading;
  final String description;
  final String actionLabel;
  final String pendingLabel;
  final Future<String?> Function() onSubmit;
  final List<Widget> Function(VoidCallback submit, bool submitting) buildFields;
  final String prompt;
  final String linkLabel;
  final VoidCallback onLinkPressed;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_submitting || !_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _submitting = true;
      _error = null;
    });

    String? error;
    try {
      error = await widget.onSubmit();
    } catch (_) {
      error = 'Something went wrong. Please try again.';
    }
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 48).clamp(
                0.0,
                double.infinity,
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: AutofillGroup(
                  onDisposeAction: AutofillContextAction.cancel,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: pine,
                              foregroundColor: lime,
                              child: Icon(Icons.restaurant_menu, size: 22),
                            ),
                            SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                'Smart Pantry',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Semantics(
                          header: true,
                          child: PageHeading(
                            widget.heading,
                            widget.description,
                          ),
                        ),
                        ...widget.buildFields(_submit, _submitting),
                        if (_error case final error?) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              error,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _submitting ? null : _submit,
                          child: _submitting
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Flexible(child: Text(widget.pendingLabel)),
                                  ],
                                )
                              : Text(widget.actionLabel),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Text(widget.prompt),
                            TextButton(
                              onPressed: _submitting
                                  ? null
                                  : widget.onLinkPressed,
                              child: Text(widget.linkLabel),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.label,
    required this.controller,
    required this.validator,
    required this.enabled,
    required this.autofillHint,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final bool enabled;
  final String autofillHint;
  final VoidCallback? onSubmitted;

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    enabled: widget.enabled,
    obscureText: _obscureText,
    autocorrect: false,
    enableSuggestions: false,
    keyboardType: TextInputType.visiblePassword,
    autofillHints: [widget.autofillHint],
    textInputAction: widget.onSubmitted == null
        ? TextInputAction.next
        : TextInputAction.done,
    onFieldSubmitted: widget.onSubmitted == null
        ? null
        : (_) => widget.onSubmitted!(),
    validator: widget.validator,
    decoration: InputDecoration(
      labelText: widget.label,
      suffixIcon: IconButton(
        tooltip:
            '${_obscureText ? 'Show' : 'Hide'} ${widget.label.toLowerCase()}',
        onPressed: widget.enabled
            ? () => setState(() => _obscureText = !_obscureText)
            : null,
        icon: Icon(
          _obscureText
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
        ),
      ),
    ),
  );
}
