import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_constants.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/children/data/repositories/children_repository.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';

enum SessionStatus { unknown, signedOut, signedIn }

@immutable
class SessionState {
  final SessionStatus status;
  final User? user;
  final List<ChildProfile> children;
  final bool childrenLoaded;
  final String? activeChildId;

  const SessionState({
    this.status = SessionStatus.unknown,
    this.user,
    this.children = const [],
    this.childrenLoaded = false,
    this.activeChildId,
  });

  String? get uid => user?.uid;
  bool get isGuest => user?.isAnonymous ?? false;
  bool get isReady => status == SessionStatus.signedOut || (status == SessionStatus.signedIn && childrenLoaded);

  ChildProfile? get activeChild => activeChildId == null ? null : children.findOrNull((c) => c.id == activeChildId);

  SessionState copyWith({
    SessionStatus? status,
    User? user,
    List<ChildProfile>? children,
    bool? childrenLoaded,
    String? activeChildId,
    bool clearActiveChild = false,
  }) {
    return SessionState(
      status: status ?? this.status,
      user: user ?? this.user,
      children: children ?? this.children,
      childrenLoaded: childrenLoaded ?? this.childrenLoaded,
      activeChildId: clearActiveChild ? null : (activeChildId ?? this.activeChildId),
    );
  }
}

final sessionControllerProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Single source of truth for "who is using the app":
/// the signed-in parent account + the child profile currently playing.
class SessionController extends Notifier<SessionState> {
  StreamSubscription<User?>? _authSub;
  StreamSubscription<List<ChildProfile>>? _childrenSub;

  @override
  SessionState build() {
    final auth = ref.watch(firebaseAuthProvider);
    _authSub = auth.userChanges().listen(_onUser);
    ref.onDispose(() {
      _authSub?.cancel();
      _childrenSub?.cancel();
    });
    return const SessionState();
  }

  void _onUser(User? user) {
    if (user == null) {
      _childrenSub?.cancel();
      _childrenSub = null;
      state = const SessionState(status: SessionStatus.signedOut);
      return;
    }

    // Same account, profile changed (e.g. guest upgraded) — keep children.
    if (state.uid == user.uid && _childrenSub != null) {
      state = state.copyWith(user: user);
      return;
    }

    _childrenSub?.cancel();
    state = SessionState(status: SessionStatus.signedIn, user: user);

    _childrenSub = ref
        .read(childrenRepositoryProvider)
        .watchChildren(user.uid)
        .listen(
          (children) {
            final prefs = ref.read(sharedPreferencesProvider);
            String? active = state.activeChildId ?? prefs.getString(AppConstants.prefActiveChild(user.uid));
            if (active != null && !children.any((c) => c.id == active)) active = null;
            if (active == null && children.length == 1) active = children.first.id;
            state = state.copyWith(
              children: children,
              childrenLoaded: true,
              activeChildId: active,
              clearActiveChild: active == null,
            );
          },
          onError: (Object e) {
            state = state.copyWith(children: const [], childrenLoaded: true);
          },
        );
  }

  Future<void> selectChild(String childId) async {
    final uid = state.uid;
    if (uid == null) return;
    await ref.read(sharedPreferencesProvider).setString(AppConstants.prefActiveChild(uid), childId);
    state = state.copyWith(activeChildId: childId);
  }

  Future<void> signOut() async {
    await ref.read(firebaseAuthProvider).signOut();
  }
}

/// The child currently playing (null until one is chosen).
final activeChildProvider = Provider<ChildProfile?>((ref) => ref.watch(sessionControllerProvider).activeChild);
