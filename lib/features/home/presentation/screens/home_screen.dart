import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/home/presentation/controllers/home_providers.dart';
import 'package:mindo_kids/features/home/presentation/widgets/badge_tile.dart';
import 'package:mindo_kids/features/home/presentation/widgets/home_header.dart';
import 'package:mindo_kids/features/home/presentation/widgets/lesson_progress_card.dart';
import 'package:mindo_kids/features/home/presentation/widgets/streak_card.dart';
import 'package:mindo_kids/features/home/presentation/widgets/world_card.dart';
import 'package:mindo_kids/features/lesson/presentation/lesson_launcher.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Dashboard: greeting, streak, learning worlds, Brain Spark,
/// Continue Learning and badges — every item comes from Firestore.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final child = ref.watch(activeChildProvider);
    final worldsAsync = ref.watch(worldsProvider);
    final spark = ref.watch(dailySparkProvider).value;
    final continueItem = ref.watch(continueLearningProvider);
    final badges = ref.watch(dashboardBadgesProvider(4));
    final isPremium = ref.watch(isPremiumProvider);

    if (child == null) return const Scaffold(body: LoadingView());

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(worldsProvider);
            ref.invalidate(allLessonsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              HomeHeader(child: child),
              const SizedBox(height: 18),
              StreakCard(child: child),
              const SizedBox(height: 18),

              // ---- Learning worlds ----
              AsyncBody<List<WorldModel>>(
                value: worldsAsync,
                onRetry: () => ref.invalidate(worldsProvider),
                builder: (worlds) {
                  if (worlds.isEmpty) {
                    return MessageView(emoji: '🪐', title: t('home.noWorlds', 'New worlds are coming soon!'));
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: worlds.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.12,
                    ),
                    itemBuilder: (_, i) =>
                        WorldCard(world: worlds[i], onTap: () => context.push(RouteNames.world(worlds[i].id))),
                  );
                },
              ),

              // ---- Brain Spark ----
              if (spark != null) ...[
                const SizedBox(height: 22),
                _BrainSparkCard(
                  lesson: spark,
                  title: t('home.sparkTitle', 'Today\'s Brain Spark ⚡'),
                  subtitle: t('home.sparkSubtitle', '{min}-minute challenge', {'min': spark.durationMinutes}),
                  locked: spark.isPremium && !isPremium,
                  onTap: () => openLesson(context, ref, spark),
                ),
              ],

              // ---- Continue learning ----
              if (continueItem != null) ...[
                const SizedBox(height: 22),
                SectionHeader(
                  title: t('home.continue', 'Continue Learning'),
                  actionLabel: t('common.seeAll', 'See all'),
                  onAction: () => context.go(RouteNames.explore),
                ),
                const SizedBox(height: 8),
                LessonProgressCard(
                  lesson: continueItem.lesson,
                  fraction: continueItem.fraction,
                  color: ref.watch(worldByIdProvider(continueItem.lesson.worldId))?.color,
                  locked: continueItem.lesson.isPremium && !isPremium,
                  onTap: () => openLesson(context, ref, continueItem.lesson),
                ),
              ],

              // ---- Badges ----
              if (badges.isNotEmpty) ...[
                const SizedBox(height: 22),
                SectionHeader(
                  title: t('home.badges', 'Badges'),
                  actionLabel: t('common.seeAll', 'See all'),
                  onAction: () => context.go(RouteNames.rewards),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [for (final (badge, earned) in badges) BadgeTile(badge: badge, earned: earned)],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BrainSparkCard extends StatelessWidget {
  const _BrainSparkCard({
    required this.lesson,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.locked,
  });

  final LessonModel lesson;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(24)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: MediaView(lesson.thumbnail, size: 58),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTheme.heading(18, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        '${lesson.title} · $subtitle',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(13, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ],
                  ),
                ),
                Icon(locked ? Icons.lock_rounded : Icons.play_circle_fill_rounded, color: Colors.white, size: 34),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
