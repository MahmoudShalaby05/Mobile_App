import 'package:firebase_auth/firebase_auth.dart';

Future<String?> signIn(
  FirebaseAuth auth, {
  required String email,
  required String password,
}) async {
  try {
    await auth.signInWithEmailAndPassword(email: email, password: password);
    return null;
  } on FirebaseAuthException catch (error) {
    return authErrorMessage(error);
  }
}

Future<String?> register(
  FirebaseAuth auth, {
  required String fullName,
  required String email,
  required String password,
}) async {
  final UserCredential credential;
  try {
    credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  } on FirebaseAuthException catch (error) {
    return authErrorMessage(error);
  }

  final user = credential.user;
  if (user != null && auth.currentUser?.uid == user.uid) {
    try {
      await user.updateDisplayName(fullName);
    } on FirebaseAuthException {
      // The account already exists. Keep the session and show email in Account.
    }
  }
  return null;
}

String authErrorMessage(FirebaseAuthException error) => switch (error.code) {
  'invalid-email' => 'Enter a valid email address.',
  'invalid-credential' ||
  'invalid-login-credentials' ||
  'wrong-password' ||
  'user-not-found' ||
  'user-disabled' => 'Check your email and password and try again.',
  'email-already-in-use' => 'Unable to create an account with these details. Try logging in if you already have an account.',
  'weak-password' => 'Choose a stronger password and try again.',
  'too-many-requests' => 'Too many attempts. Wait a moment and try again.',
  'network-request-failed' => 'Check your connection and try again.',
  'operation-not-allowed' => 'Email and password sign-in is unavailable.',
  _ => 'Authentication could not be completed. Please try again.',
};
