import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/app_config_model.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/data/repositories/content_repository.dart';

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

final worldsProvider = StreamProvider<List<WorldModel>>((ref) => ref.watch(contentRepositoryProvider).watchWorlds());

final worldByIdProvider = Provider.family<WorldModel?, String>(
  (ref, id) => ref.watch(worldsProvider).value?.findOrNull((w) => w.id == id),
);

final allLessonsProvider = StreamProvider<List<LessonModel>>(
  (ref) => ref.watch(contentRepositoryProvider).watchAllLessons(),
);

final lessonsForWorldProvider = StreamProvider.family<List<LessonModel>, String>(
  (ref, worldId) => ref.watch(contentRepositoryProvider).watchLessonsForWorld(worldId),
);

final lessonProvider = StreamProvider.family<LessonModel?, String>(
  (ref, lessonId) => ref.watch(contentRepositoryProvider).watchLesson(lessonId),
);

/// "Brain Spark" of the day: rotates through lessons flagged isDailySpark.
final dailySparkProvider = StreamProvider<LessonModel?>((ref) {
  return ref.watch(contentRepositoryProvider).watchDailySparkLessons().map((list) {
    if (list.isEmpty) return null;
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    return list[dayOfYear % list.length];
  });
});

final badgesProvider = StreamProvider<List<BadgeModel>>((ref) => ref.watch(contentRepositoryProvider).watchBadges());

final avatarsProvider = StreamProvider<List<AvatarModel>>((ref) => ref.watch(contentRepositoryProvider).watchAvatars());

final plansProvider = StreamProvider<List<PlanModel>>((ref) => ref.watch(contentRepositoryProvider).watchPlans());

final pagesProvider = StreamProvider<List<ContentPage>>((ref) => ref.watch(contentRepositoryProvider).watchPages());

final pageProvider = StreamProvider.family<ContentPage?, String>(
  (ref, id) => ref.watch(contentRepositoryProvider).watchPage(id),
);

final announcementsProvider = StreamProvider<List<Announcement>>(
  (ref) => ref.watch(contentRepositoryProvider).watchAnnouncements(),
);
