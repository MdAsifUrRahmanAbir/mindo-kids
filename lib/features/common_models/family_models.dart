import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/media_ref.dart';

/// users/{uid}/children/{childId}
///
/// Privacy by design: only a first name / nickname, an avatar and an age
/// band are stored — no birth date, photo or location.
class ChildProfile {
  final String id;
  final String name;
  final String avatarId;
  final MediaRef avatar;
  final String ageBand;
  final int streak;
  final int bestStreak;
  final String lastActiveDate;
  final List<String> activeDates;
  final int lessonsCompleted;
  final int stars;
  final int dailyLimitMinutes;
  final DateTime? createdAt;

  const ChildProfile({
    required this.id,
    required this.name,
    this.avatarId = '',
    this.avatar = const MediaRef(emoji: '🧒'),
    this.ageBand = '',
    this.streak = 0,
    this.bestStreak = 0,
    this.lastActiveDate = '',
    this.activeDates = const [],
    this.lessonsCompleted = 0,
    this.stars = 0,
    this.dailyLimitMinutes = 0,
    this.createdAt,
  });

  factory ChildProfile.fromMap(String id, Map<String, dynamic> m) {
    final avatar = MediaRef.fromMap(m, imageKey: 'avatarUrl', emojiKey: 'avatarEmoji');
    return ChildProfile(
      id: id,
      name: m.str('name', 'Friend'),
      avatarId: m.str('avatarId'),
      avatar: avatar.isEmpty ? const MediaRef(emoji: '🧒') : avatar,
      ageBand: m.str('ageBand'),
      streak: m.integer('streak'),
      bestStreak: m.integer('bestStreak'),
      lastActiveDate: m.str('lastActiveDate'),
      activeDates: m.strings('activeDates'),
      lessonsCompleted: m.integer('lessonsCompleted'),
      stars: m.integer('stars'),
      dailyLimitMinutes: m.integer('dailyLimitMinutes'),
      createdAt: m.date('createdAt'),
    );
  }

  /// Streak that is still "alive" today (learned today or yesterday).
  int currentStreak(String today, String yesterday) =>
      (lastActiveDate == today || lastActiveDate == yesterday) ? streak : 0;
}

/// users/{uid}/children/{childId}/progress/{lessonId}
class LessonProgress {
  final String lessonId;
  final String worldId;
  final bool completed;
  final int stars;
  final int bestScore;
  final int currentStep;
  final int totalSteps;
  final int attempts;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  const LessonProgress({
    required this.lessonId,
    this.worldId = '',
    this.completed = false,
    this.stars = 0,
    this.bestScore = 0,
    this.currentStep = 0,
    this.totalSteps = 0,
    this.attempts = 0,
    this.updatedAt,
    this.completedAt,
  });

  double get fraction {
    if (completed) return 1;
    if (totalSteps <= 0) return 0;
    return (currentStep / totalSteps).clamp(0.0, 1.0);
  }

  factory LessonProgress.fromMap(String id, Map<String, dynamic> m) => LessonProgress(
    lessonId: m.str('lessonId', id),
    worldId: m.str('worldId'),
    completed: m.boolean('completed'),
    stars: m.integer('stars'),
    bestScore: m.integer('bestScore'),
    currentStep: m.integer('currentStep'),
    totalSteps: m.integer('totalSteps'),
    attempts: m.integer('attempts'),
    updatedAt: m.date('updatedAt'),
    completedAt: m.date('completedAt'),
  );
}

/// subscriptions/{uid} — written ONLY by Cloud Functions (or an admin).
class SubscriptionModel {
  final bool active;
  final String planId;
  final String productId;
  final String platform;
  final String source;
  final String status;
  final bool autoRenewing;
  final DateTime? expiresAt;

  const SubscriptionModel({
    this.active = false,
    this.planId = '',
    this.productId = '',
    this.platform = '',
    this.source = '',
    this.status = '',
    this.autoRenewing = false,
    this.expiresAt,
  });

  bool get isActiveNow => active && expiresAt != null && expiresAt!.isAfter(DateTime.now());

  factory SubscriptionModel.fromMap(Map<String, dynamic> m) => SubscriptionModel(
    active: m.boolean('active'),
    planId: m.str('planId'),
    productId: m.str('productId'),
    platform: m.str('platform'),
    source: m.str('source'),
    status: m.str('status'),
    autoRenewing: m.boolean('autoRenewing'),
    expiresAt: m.date('expiresAt'),
  );
}
