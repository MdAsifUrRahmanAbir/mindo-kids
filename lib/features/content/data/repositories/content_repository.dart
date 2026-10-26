import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/firestore_paths.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/features/common_models/app_config_model.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) => ContentRepository(ref.watch(firestoreProvider)));

/// Read-only access to everything the admin panel manages.
///
/// Collections are small, so they are fetched whole and filtered/sorted on
/// the device (`isActive`, `order`). That means no composite indexes to
/// maintain and a document missing `order` still shows up (at the top).
class ContentRepository {
  ContentRepository(this._db);
  final FirebaseFirestore _db;

  // ---------- config ----------

  Stream<AppConfigModel> watchAppConfig() =>
      _db.doc(FirestorePaths.appConfig).snapshots().map((s) => AppConfigModel.fromMap(s.data() ?? const {}));

  Stream<Map<String, String>> watchStrings() => _db
      .doc(FirestorePaths.strings)
      .snapshots()
      .map((s) => (s.data() ?? const {}).map((k, v) => MapEntry(k, v?.toString() ?? '')));

  Stream<PaywallConfig> watchPaywall() =>
      _db.doc(FirestorePaths.paywall).snapshots().map((s) => PaywallConfig.fromMap(s.data() ?? const {}));

  // ---------- collections ----------

  Stream<List<OnboardingSlide>> watchOnboarding() => _watchAll(
    _db.collection(FirestorePaths.onboarding),
    OnboardingSlide.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<List<WorldModel>> watchWorlds() => _watchAll(
    _db.collection(FirestorePaths.worlds),
    WorldModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<List<LessonModel>> watchAllLessons() => _watchAll(
    _db.collection(FirestorePaths.lessons),
    LessonModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<List<LessonModel>> watchLessonsForWorld(String worldId) => _watchAll(
    _db.collection(FirestorePaths.lessons).where('worldId', isEqualTo: worldId),
    LessonModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<List<LessonModel>> watchDailySparkLessons() => _watchAll(
    _db.collection(FirestorePaths.lessons).where('isDailySpark', isEqualTo: true),
    LessonModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<LessonModel?> watchLesson(String lessonId) => _db.doc(FirestorePaths.lesson(lessonId)).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : LessonModel.fromMap(s.id, data);
  });

  /// Throws FirebaseException(permission-denied) for a premium lesson when
  /// the user has no active subscription (enforced by firestore.rules).
  Future<List<LessonStep>> getSteps(String lessonId) async {
    final q = await _db.collection(FirestorePaths.steps(lessonId)).get();
    final steps =
        q.docs.map((d) => LessonStep.fromMap(d.id, d.data())).where((s) => s.type != StepType.unknown).toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return steps;
  }

  Stream<List<BadgeModel>> watchBadges() => _watchAll(
    _db.collection(FirestorePaths.badges),
    BadgeModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Future<List<BadgeModel>> getBadges() async {
    final q = await _db.collection(FirestorePaths.badges).get();
    return q.docs.map((d) => BadgeModel.fromMap(d.id, d.data())).where((b) => b.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  Stream<List<AvatarModel>> watchAvatars() => _watchAll(
    _db.collection(FirestorePaths.avatars),
    AvatarModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<List<PlanModel>> watchPlans() => _watchAll(
    _db.collection(FirestorePaths.plans),
    PlanModel.fromMap,
    active: (e) => e.isActive,
    order: (e) => e.order,
  );

  Stream<List<ContentPage>> watchPages() =>
      _watchAll(_db.collection(FirestorePaths.pages), ContentPage.fromMap, active: (_) => true, order: (e) => e.order);

  Stream<ContentPage?> watchPage(String pageId) => _db.doc(FirestorePaths.page(pageId)).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : ContentPage.fromMap(s.id, data);
  });

  Stream<List<Announcement>> watchAnnouncements() => _db.collection(FirestorePaths.announcements).snapshots().map((q) {
    final list = q.docs.map((d) => Announcement.fromMap(d.id, d.data())).where((a) => a.isActive).toList()
      ..sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    return list;
  });

  // ---------- helpers ----------

  Stream<List<T>> _watchAll<T>(
    Query<Map<String, dynamic>> query,
    T Function(String id, Map<String, dynamic> data) parse, {
    required bool Function(T e) active,
    required int Function(T e) order,
  }) {
    return query.snapshots().map((q) {
      final list = q.docs.map((d) => parse(d.id, d.data())).where(active).toList()
        ..sort((a, b) => order(a).compareTo(order(b)));
      return list;
    });
  }
}
