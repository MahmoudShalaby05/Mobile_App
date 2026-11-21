import 'package:flutter/material.dart';

import '../../widgets/pantry_widgets.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BackButton(),
            PageHeading(
              'Account',
              'You’re browsing a local demo in guest mode.',
            ),
            ListTile(
              leading: Icon(Icons.person_outline),
              title: Text('Guest'),
              subtitle: Text('Changes last until the app restarts.'),
            ),
          ],
        ),
      ),
    ),
  );
}
