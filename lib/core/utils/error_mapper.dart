import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Turns Firebase exceptions into short, parent-friendly messages.
String friendlyError(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'That e-mail address doesn\'t look right.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail or password is incorrect.';
      case 'email-already-in-use':
      case 'credential-already-in-use':
        return 'An account already exists with this e-mail.';
      case 'weak-password':
        return 'Please choose a stronger password (at least 6 characters).';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'requires-recent-login':
        return 'For your security, please sign in again and retry.';
      default:
        return error.message ?? 'Something went wrong. Please try again.';
    }
  }
  if (error is FirebaseFunctionsException) {
    return error.message ?? 'Something went wrong. Please try again.';
  }
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'This content is locked.';
    }
    if (error.code == 'unavailable') {
      return 'No internet connection.';
    }
    return error.message ?? 'Something went wrong. Please try again.';
  }
  return 'Something went wrong. Please try again.';
}

bool isPermissionDenied(Object error) => error is FirebaseException && error.code == 'permission-denied';
