import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_pantry/providers/firebase_providers.dart';

class _TestAuth extends Fake implements FirebaseAuth {
  _TestAuth(this.states);

  final Stream<User?> states;

  @override
  Stream<User?> authStateChanges() => states;
}

class _TestUser extends Fake implements User {
  _TestUser(this.uid);

  @override
  final String uid;
}

class _TestFirestore extends Fake implements FirebaseFirestore {}

void main() {
  test(
    'Auth state emits initial guest, sign-in, sign-out and account switch',
    () async {
      final source = StreamController<User?>();
      final observedUids = StreamController<String?>();
      final container = ProviderContainer(
        overrides: [
          firebaseAuthProvider.overrideWithValue(_TestAuth(source.stream)),
        ],
      );
      final subscription = container.listen(authStateProvider, (_, next) {
        if (next case AsyncData(:final value)) {
          observedUids.add(value?.uid);
        }
      });
      addTearDown(() async {
        subscription.close();
        container.dispose();
        await source.close();
        await observedUids.close();
      });

      expect(container.read(authStateProvider).isLoading, isTrue);
      final states = expectLater(
        observedUids.stream,
        emitsInOrder([isNull, 'user-a', isNull, 'user-b']),
      );
      source
        ..add(null)
        ..add(_TestUser('user-a'))
        ..add(null)
        ..add(_TestUser('user-b'));
      await states;
    },
  );

  test('Firestore instance can be overridden without Firebase startup', () {
    final firestore = _TestFirestore();
    final container = ProviderContainer(
      overrides: [firestoreProvider.overrideWithValue(firestore)],
    );
    addTearDown(container.dispose);

    expect(container.read(firestoreProvider), same(firestore));
  });
}
