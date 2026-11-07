import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/app_config_model.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/data/repositories/content_repository.dart';
import 'package:mindo_kids/features/country/providers/country_providers.dart';

// ---------------- config ----------------

final appConfigProvider = StreamProvider<AppConfigModel>(
  (ref) => ref.watch(contentRepositoryProvider).watchAppConfig(),
);

/// Current config, or defaults while loading/offline.
final appConfigValueProvider = Provider<AppConfigModel>(
  (ref) => ref.watch(appConfigProvider).value ?? const AppConfigModel(),
);

final appStringsProvider = StreamProvider<Map<String, String>>(
  (ref) => ref.watch(contentRepositoryProvider).watchStrings(),
);

final paywallConfigProvider = StreamProvider<PaywallConfig>(
  (ref) => ref.watch(contentRepositoryProvider).watchPaywall(),
);

// ---------------- collections ----------------

final onboardingSlidesProvider = StreamProvider<List<OnboardingSlide>>(
  (ref) => ref.watch(contentRepositoryProvider).watchOnboarding(),
);

/// Every world, ignoring the family's country (for lookups by id).
final allWorldsProvider = StreamProvider<List<WorldModel>>((ref) => ref.watch(contentRepositoryProvider).watchWorlds());

/// Worlds for the family's country (see config/countries), in that
/// country's order. This is what every screen lists.
final worldsProvider = StreamProvider<List<WorldModel>>((ref) async* {
  final allowed = await ref.watch(allowedWorldIdsProvider.future);
  yield* ref.watch(contentRepositoryProvider).watchWorlds().map((l) => filterWorldsForCountry(l, allowed));
});

final worldByIdProvider = Provider.family<WorldModel?, String>(
  (ref, id) => ref.watch(allWorldsProvider).value?.findOrNull((w) => w.id == id),
);

/// Lessons of the worlds available in the family's country.
final allLessonsProvider = StreamProvider<List<LessonModel>>((ref) async* {
  final allowed = await ref.watch(allowedWorldIdsProvider.future);
  yield* ref
      .watch(contentRepositoryProvider)
      .watchAllLessons()
      .map((l) => allowed == null ? l : l.where((e) => isWorldAllowed(e.worldId, allowed)).toList());
});

final lessonsForWorldProvider = StreamProvider.family<List<LessonModel>, String>(
  (ref, worldId) => ref.watch(contentRepositoryProvider).watchLessonsForWorld(worldId),
);

final lessonProvider = StreamProvider.family<LessonModel?, String>(
  (ref, lessonId) => ref.watch(contentRepositoryProvider).watchLesson(lessonId),
);

/// "Brain Spark" of the day: rotates through lessons flagged isDailySpark.
final dailySparkProvider = StreamProvider<LessonModel?>((ref) async* {
  final allowed = await ref.watch(allowedWorldIdsProvider.future);
  yield* ref.watch(contentRepositoryProvider).watchDailySparkLessons().map((all) {
    final list = all.where((l) => isWorldAllowed(l.worldId, allowed)).toList();
    if (list.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return list[dayOfYear % list.length];
  });
});

/// Badges, minus "finish N lessons in this world" badges for worlds the
/// family's country doesn't show.
final badgesProvider = StreamProvider<List<BadgeModel>>((ref) async* {
  final allowed = await ref.watch(allowedWorldIdsProvider.future);
  yield* ref.watch(contentRepositoryProvider).watchBadges().map(
    (l) => l
        .where((b) => b.ruleType != 'world_lessons' || b.ruleWorldId.isEmpty || isWorldAllowed(b.ruleWorldId, allowed))
        .toList(),
  );
});

final avatarsProvider = StreamProvider<List<AvatarModel>>((ref) => ref.watch(contentRepositoryProvider).watchAvatars());

final plansProvider = StreamProvider<List<PlanModel>>((ref) => ref.watch(contentRepositoryProvider).watchPlans());

final pagesProvider = StreamProvider<List<ContentPage>>((ref) => ref.watch(contentRepositoryProvider).watchPages());

final pageProvider = StreamProvider.family<ContentPage?, String>(
  (ref, id) => ref.watch(contentRepositoryProvider).watchPage(id),
);

final announcementsProvider = StreamProvider<List<Announcement>>(
  (ref) => ref.watch(contentRepositoryProvider).watchAnnouncements(),
);
