import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/progress/providers/progress_providers.dart';

class ContinueItem {
  final LessonModel lesson;
  final double fraction;
  const ContinueItem(this.lesson, this.fraction);
}

/// Lesson for the "Continue Learning" card: the most recent unfinished
/// lesson, otherwise the next lesson the child hasn't completed yet.
final continueLearningProvider = Provider<ContinueItem?>((ref) {
  final lessons = ref.watch(allLessonsProvider).value ?? const <LessonModel>[];
  if (lessons.isEmpty) return null;
  final byId = {for (final l in lessons) l.id: l};

  for (final p in ref.watch(recentProgressProvider)) {
    final lesson = byId[p.lessonId];
    if (!p.completed && lesson != null) return ContinueItem(lesson, p.fraction);
  }

  final worlds = ref.watch(worldsProvider).value ?? const <WorldModel>[];
  final progress = ref.watch(progressMapProvider).value ?? const {};
  for (final w in worlds) {
    for (final l in lessons) {
      if (l.worldId == w.id && !(progress[l.id]?.completed ?? false)) {
        return ContinueItem(l, 0);
      }
    }
  }
  return null;
});

/// Up to [count] badges for the dashboard: earned first, then the next
/// ones to aim for.
final dashboardBadgesProvider = Provider.family<List<(BadgeModel, bool)>, int>((ref, count) {
  final badges = ref.watch(badgesProvider).value ?? const <BadgeModel>[];
  final earned = ref.watch(earnedBadgesProvider).value ?? const {};
  final list = [
    for (final b in badges)
      if (earned.containsKey(b.id)) (b, true),
    for (final b in badges)
      if (!earned.containsKey(b.id)) (b, false),
  ];
  return list.take(count).toList();
});
