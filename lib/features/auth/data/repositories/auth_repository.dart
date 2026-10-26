import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/firestore_paths.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(firebaseAuthProvider), ref.watch(firestoreProvider)),
);

/// The account always belongs to the PARENT. Children never sign in —
/// they are profiles under the parent's account.
class AuthRepository {
  AuthRepository(this._auth, this._db);
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  User? get currentUser => _auth.currentUser;

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
  }

  /// Creates the parent account. If the parent was using the app as a guest
  /// the guest account is upgraded in place, so children, progress and any
  /// subscription are kept.
  Future<void> signUp({required String name, required String email, required String password}) async {
    final current = _auth.currentUser;
    UserCredential cred;
    if (current != null && current.isAnonymous) {
      cred = await current.linkWithCredential(EmailAuthProvider.credential(email: email.trim(), password: password));
    } else {
      cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
    }
    final user = cred.user!;
    await user.updateDisplayName(name.trim());
    await _db.doc(FirestorePaths.user(user.uid)).set({
      'displayName': name.trim(),
      'email': email.trim(),
      'isGuest': false,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    }, SetOptions(merge: true));
    await user.reload();
  }

  Future<void> continueAsGuest() async {
    final cred = await _auth.signInAnonymously();
    await _db.doc(FirestorePaths.user(cred.user!.uid)).set({
      'isGuest': true,
      'createdAt': DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email.trim());

  Future<void> signOut() => _auth.signOut();

  /// Deletes the Firebase Auth user. The `onUserDeleted` Cloud Function
  /// then removes users/{uid} (children, progress, badges) server-side.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.delete();
  }
}
