import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/features/auth/data/repositories/auth_repository.dart';
import 'package:mindo_kids/features/auth/presentation/states/auth_state.dart';

final authControllerProvider = NotifierProvider.autoDispose<AuthController, AuthFormState>(AuthController.new);

/// Form actions for sign-in / sign-up / reset. Navigation after success is
/// handled by the router redirect reacting to the auth state.
class AuthController extends Notifier<AuthFormState> {
  AuthRepository get _repo => ref.read(authRepositoryProvider);

  @override
  AuthFormState build() => const AuthFormState();

  Future<bool> signIn(String email, String password) => _run(() => _repo.signIn(email, password));

  Future<bool> signUp({required String name, required String email, required String password}) =>
      _run(() => _repo.signUp(name: name, email: email, password: password));

  Future<bool> continueAsGuest() => _run(_repo.continueAsGuest);

  Future<bool> sendReset(String email) async {
    final ok = await _run(() => _repo.sendPasswordReset(email));
    if (ok) {
      state = state.copyWith(infoMessage: 'Check your inbox for a link to reset your password.');
    }
    return ok;
  }

  Future<bool> _run(Future<void> Function() action) async {
    state = state.copyWith(isLoading: true);
    try {
      await action();
      if (ref.mounted) state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      if (ref.mounted) state = state.copyWith(isLoading: false, errorMessage: friendlyError(e));
      return false;
    }
  }
}
