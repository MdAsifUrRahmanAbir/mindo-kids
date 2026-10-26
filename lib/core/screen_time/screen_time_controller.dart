import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_constants.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/utils/date_utils.dart';

@immutable
class ScreenTimeState {
  final bool enabled;
  final int usedSeconds;
  final int limitSeconds;
  final int baseLimitMinutes;

  const ScreenTimeState({this.enabled = false, this.usedSeconds = 0, this.limitSeconds = 0, this.baseLimitMinutes = 0});

  bool get locked => enabled && limitSeconds > 0 && usedSeconds >= limitSeconds;

  int get remainingMinutes {
    if (!enabled) return -1;
    final left = limitSeconds - usedSeconds;
    return left <= 0 ? 0 : (left / 60).ceil();
  }

  ScreenTimeState copyWith({int? usedSeconds, int? limitSeconds}) => ScreenTimeState(
    enabled: enabled,
    usedSeconds: usedSeconds ?? this.usedSeconds,
    limitSeconds: limitSeconds ?? this.limitSeconds,
    baseLimitMinutes: baseLimitMinutes,
  );
}

final screenTimeControllerProvider = NotifierProvider<ScreenTimeController, ScreenTimeState>(ScreenTimeController.new);

/// Daily screen-time limit per child (set by the parent in the Parent Zone,
/// stored on the child document as `dailyLimitMinutes`; 0 = no limit).
/// Usage is counted on this device while the app is in the foreground.
class ScreenTimeController extends Notifier<ScreenTimeState> {
  static const _tickSeconds = 15;

  Timer? _timer;
  bool _foreground = true;
  String? _childId;
  String _day = '';

  @override
  ScreenTimeState build() {
    final (childId, limit) = ref.watch(
      sessionControllerProvider.select((s) => (s.activeChild?.id, s.activeChild?.dailyLimitMinutes ?? 0)),
    );

    _timer?.cancel();
    ref.onDispose(() => _timer?.cancel());

    _childId = childId;
    if (childId == null || limit <= 0) return const ScreenTimeState();

    _day = todayKey();
    final prefs = ref.read(sharedPreferencesProvider);
    final used = prefs.getInt(AppConstants.prefScreenTimeUsed(childId, _day)) ?? 0;
    final extra = prefs.getInt(AppConstants.prefScreenTimeExtra(childId, _day)) ?? 0;

    _timer = Timer.periodic(const Duration(seconds: _tickSeconds), (_) => _tick());

    return ScreenTimeState(
      enabled: true,
      usedSeconds: used,
      limitSeconds: (limit + extra) * 60,
      baseLimitMinutes: limit,
    );
  }

  void setForeground(bool value) => _foreground = value;

  void _tick() {
    final childId = _childId;
    if (!_foreground || !state.enabled || state.locked || childId == null) return;
    final prefs = ref.read(sharedPreferencesProvider);

    final today = todayKey();
    if (today != _day) {
      _day = today;
      state = state.copyWith(usedSeconds: 0, limitSeconds: state.baseLimitMinutes * 60);
    }
    final used = state.usedSeconds + _tickSeconds;
    prefs.setInt(AppConstants.prefScreenTimeUsed(childId, _day), used);
    state = state.copyWith(usedSeconds: used);
  }

  /// Parent unlocked "a little more time" on the break screen.
  Future<void> grantExtraTime() async {
    final childId = _childId;
    if (childId == null) return;
    final prefs = ref.read(sharedPreferencesProvider);
    final key = AppConstants.prefScreenTimeExtra(childId, _day);
    final extra = (prefs.getInt(key) ?? 0) + AppConstants.screenTimeExtensionMinutes;
    await prefs.setInt(key, extra);
    state = state.copyWith(limitSeconds: state.limitSeconds + AppConstants.screenTimeExtensionMinutes * 60);
  }
}
