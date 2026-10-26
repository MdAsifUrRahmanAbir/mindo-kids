import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';
import 'package:mindo_kids/features/progress/data/repositories/progress_repository.dart';

final _activeIdsProvider = Provider<(String?, String?)>((ref) {
  final s = ref.watch(sessionControllerProvider);
  return (s.uid, s.activeChildId);
});

/// All lesson progress for the active child, keyed by lessonId.
final progressMapProvider = StreamProvider<Map<String, LessonProgress>>((ref) {
  final (uid, childId) = ref.watch(_activeIdsProvider);
  if (uid == null || childId == null) return Stream.value(const {});
  return ref
      .watch(progressRepositoryProvider)
      .watchProgress(uid, childId)
      .map((list) => {for (final p in list) p.lessonId: p});
});

/// Most recently touched lessons first.
final recentProgressProvider = Provider<List<LessonProgress>>((ref) {
  final map = ref.watch(progressMapProvider).value ?? const {};
  final list = map.values.toList()
    ..sort((a, b) => (b.updatedAt ?? DateTime(2000)).compareTo(a.updatedAt ?? DateTime(2000)));
  return list;
});

/// badgeId -> earnedAt for the active child.
final earnedBadgesProvider = StreamProvider<Map<String, DateTime?>>((ref) {
  final (uid, childId) = ref.watch(_activeIdsProvider);
  if (uid == null || childId == null) return Stream.value(const {});
  return ref.watch(progressRepositoryProvider).watchEarnedBadges(uid, childId);
});

/// Progress for any child of the signed-in parent (Parent Zone).
final childProgressProvider = StreamProvider.family<List<LessonProgress>, String>((ref, childId) {
  final uid = ref.watch(sessionControllerProvider.select((s) => s.uid));
  if (uid == null) return Stream.value(const []);
  return ref.watch(progressRepositoryProvider).watchProgress(uid, childId);
});
