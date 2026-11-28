import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/firebase_providers.dart';
import '../../widgets/pantry_widgets.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({this.user, super.key});

  final User? user;

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  Stream<User?>? _profileChanges;
  bool _signingOut = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _profileChanges = ref.read(firebaseAuthProvider).userChanges();
    }
  }

  Future<void> _signOut() async {
    if (_signingOut) return;
    setState(() {
      _signingOut = true;
      _error = null;
    });
    try {
      await ref.read(firebaseAuthProvider).signOut();
    } catch (_) {
      if (mounted) {
        setState(() {
          _signingOut = false;
          _error = 'Could not log out. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BackButton(),
              if (user == null) ...[
                const PageHeading(
                  'Account',
                  'You’re browsing a local demo in guest mode.',
                ),
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Guest'),
                  subtitle: Text('Changes last until the app restarts.'),
                ),
              ] else ...[
                const PageHeading('Account', 'Your Smart Pantry account.'),
                StreamBuilder<User?>(
                  stream: _profileChanges,
                  initialData: user,
                  builder: (context, snapshot) {
                    final profile = snapshot.data;
                    if (profile?.uid != user.uid) {
                      return const SizedBox.shrink();
                    }
                    final name = profile?.displayName?.trim() ?? '';
                    return ListTile(
                      leading: const Icon(Icons.person_outline),
                      title: Text(name.isEmpty ? 'Signed in' : name),
                      subtitle: Text(profile?.email ?? 'Email unavailable'),
                    );
                  },
                ),
                if (_error case final error?)
                  Semantics(liveRegion: true, child: Text(error)),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _signingOut ? null : _signOut,
                  child: Text(_signingOut ? 'Logging out…' : 'Log out'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
