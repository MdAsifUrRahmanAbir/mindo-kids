import 'dart:async';
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/firestore_paths.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/core/utils/date_utils.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(firestoreProvider)),
);

class LessonCompletion {
  final int stars;
  final bool firstCompletion;
  final int streak;
  final List<BadgeModel> newBadges;

  const LessonCompletion({
    required this.stars,
    required this.firstCompletion,
    required this.streak,
    required this.newBadges,
  });
}

/// Offline-first progress.
///
/// * Progress is written per lesson (item-level merge, as the concept doc
///   recommends) so two devices never overwrite each other's history.
/// * Everything is computed from data already in the local cache and
///   written with a batch — no transactions — so finishing a lesson works
///   with no internet. Firestore applies the write locally at once and
///   syncs it when the device is back online.
class ProgressRepository {
  ProgressRepository(this._db);
  final FirebaseFirestore _db;

  Stream<List<LessonProgress>> watchProgress(String uid, String childId) => _db
      .collection(FirestorePaths.progress(uid, childId))
      .snapshots()
      .map((q) => q.docs.map((d) => LessonProgress.fromMap(d.id, d.data())).toList());

  Stream<Map<String, DateTime?>> watchEarnedBadges(String uid, String childId) => _db
      .collection(FirestorePaths.earnedBadges(uid, childId))
      .snapshots()
      .map((q) => {for (final d in q.docs) d.id: d.data().date('earnedAt')});

  /// Saves "where the child is" inside a lesson (Continue Learning card).
  void saveStep({
    required String uid,
    required String childId,
    required LessonModel lesson,
    required int currentStep,
    required int totalSteps,
  }) {
    unawaited(
      _settle(
        _db.doc(FirestorePaths.progressDoc(uid, childId, lesson.id)).set({
          'lessonId': lesson.id,
          'worldId': lesson.worldId,
          'currentStep': currentStep,
          'totalSteps': totalSteps,
          'updatedAt': DateTime.now(),
        }, SetOptions(merge: true)),
      ),
    );
  }

  Future<LessonCompletion> completeLesson({
    required String uid,
    required ChildProfile child,
    required LessonModel lesson,
    required int stars,
    required int score,
    required int totalSteps,
    required Map<String, LessonProgress> progress,
    required Set<String> earnedBadgeIds,
    required List<BadgeModel> badges,
  }) async {
    final now = DateTime.now();
    final today = dayKey(now);
    final yesterday = dayKey(now.subtract(const Duration(days: 1)));

    final previous = progress[lesson.id];
    final wasCompleted = previous?.completed ?? false;
    final oldStars = previous?.stars ?? 0;
    final starGain = stars > oldStars ? stars - oldStars : 0;

    var streak = child.streak;
    if (child.lastActiveDate != today) {
      streak = child.lastActiveDate == yesterday ? streak + 1 : 1;
    }
    final bestStreak = math.max(child.bestStreak, streak);
    final dates = {...child.activeDates, today}.toList()..sort();
    final trimmed = dates.length > 60 ? dates.sublist(dates.length - 60) : dates;
    final lessonsCompleted = child.lessonsCompleted + (wasCompleted ? 0 : 1);
    final totalStars = child.stars + starGain;

    final batch = _db.batch();
    batch.set(_db.doc(FirestorePaths.progressDoc(uid, child.id, lesson.id)), {
      'lessonId': lesson.id,
      'worldId': lesson.worldId,
      'completed': true,
      'stars': math.max(stars, oldStars),
      'bestScore': math.max(score, previous?.bestScore ?? 0),
      'currentStep': totalSteps,
      'totalSteps': totalSteps,
      'attempts': FieldValue.increment(1),
      'updatedAt': now,
      if (!wasCompleted) 'completedAt': now,
    }, SetOptions(merge: true));
    batch.update(_db.doc(FirestorePaths.child(uid, child.id)), {
      'streak': streak,
      'bestStreak': bestStreak,
      'lastActiveDate': today,
      'activeDates': trimmed,
      'lessonsCompleted': lessonsCompleted,
      'stars': totalStars,
    });

    // Badges — evaluated against the numbers after this lesson.
    final worldCounts = <String, int>{};
    for (final p in progress.values) {
      if (p.completed && p.lessonId != lesson.id) {
        worldCounts[p.worldId] = (worldCounts[p.worldId] ?? 0) + 1;
      }
    }
    worldCounts[lesson.worldId] = (worldCounts[lesson.worldId] ?? 0) + 1;

    final newBadges = <BadgeModel>[];
    for (final b in badges) {
      if (earnedBadgeIds.contains(b.id)) continue;
      final earned = switch (b.ruleType) {
        'lessons_completed' || 'first_lesson' => lessonsCompleted >= b.ruleValue,
        'streak' => streak >= b.ruleValue,
        'stars' => totalStars >= b.ruleValue,
        'world_lessons' => (worldCounts[b.ruleWorldId] ?? 0) >= b.ruleValue,
        _ => false,
      };
      if (!earned) continue;
      newBadges.add(b);
      batch.set(_db.doc('${FirestorePaths.earnedBadges(uid, child.id)}/${b.id}'), {
        'badgeId': b.id,
        'title': b.title,
        'earnedAt': now,
      });
    }

    await _settle(batch.commit());

    return LessonCompletion(stars: stars, firstCompletion: !wasCompleted, streak: streak, newBadges: newBadges);
  }

  /// Firestore write futures only complete once the SERVER confirms, which
  /// never happens offline. The write is already applied locally, so don't
  /// keep the child waiting.
  Future<void> _settle(Future<void> write) async {
    try {
      await write.timeout(const Duration(seconds: 4));
    } on TimeoutException {
      // Queued; will sync when back online.
    }
  }
}
