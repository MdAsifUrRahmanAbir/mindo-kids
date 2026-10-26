import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/lesson/presentation/lesson_launcher.dart';
import 'package:mindo_kids/features/progress/providers/progress_providers.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/features/world/presentation/widgets/lesson_tile.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// All learning worlds with their progress, plus lesson search.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final worldsAsync = ref.watch(worldsProvider);
    final lessons = ref.watch(allLessonsProvider).value ?? const <LessonModel>[];
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final isPremium = ref.watch(isPremiumProvider);

    final q = _query.trim().toLowerCase();
    final results = q.isEmpty
        ? const <LessonModel>[]
        : lessons.where((l) => l.title.toLowerCase().contains(q) || l.subtitle.toLowerCase().contains(q)).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(t('explore.title', 'Explore worlds'), style: AppTheme.heading(28, weight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              t('explore.subtitle', 'Pick a world and start an adventure.'),
              style: AppTheme.body(14, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: t('explore.search', 'Search lessons'),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 18),
            if (q.isNotEmpty) ...[
              if (results.isEmpty)
                MessageView(emoji: '🔍', title: t('explore.noResults', 'No lessons found'))
              else
                for (var i = 0; i < results.length; i++) ...[
                  LessonTile(
                    lesson: results[i],
                    index: i,
                    color: ref.watch(worldByIdProvider(results[i].worldId))?.color ?? AppColors.primary,
                    progress: progress[results[i].id],
                    locked: results[i].isPremium && !isPremium,
                    onTap: () => openLesson(context, ref, results[i]),
                  ),
                  const SizedBox(height: 12),
                ],
            ] else
              AsyncBody<List<WorldModel>>(
                value: worldsAsync,
                onRetry: () => ref.invalidate(worldsProvider),
                builder: (worlds) => Column(
                  children: [
                    for (final w in worlds) ...[
                      _WorldRow(
                        world: w,
                        total: lessons.where((l) => l.worldId == w.id).length,
                        done: lessons.where((l) => l.worldId == w.id && (progress[l.id]?.completed ?? false)).length,
                        onTap: () => context.push(RouteNames.world(w.id)),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _WorldRow extends StatelessWidget {
  const _WorldRow({required this.world, required this.total, required this.done, required this.onTap});

  final WorldModel world;
  final int total;
  final int done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = world.color;
    final fraction = total == 0 ? 0.0 : done / total;
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(color: c.tint(0.78), borderRadius: BorderRadius.circular(20)),
            child: MediaView(world.icon, size: 72),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(world.title, style: AppTheme.heading(18)),
                const SizedBox(height: 2),
                Text(
                  world.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body(13, color: AppColors.textMuted),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 7,
                          backgroundColor: c.tint(0.85),
                          valueColor: AlwaysStoppedAnimation(c),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$done/$total',
                      style: AppTheme.body(12, color: c.shade(0.2), weight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: c.shade(0.1), size: 28),
        ],
      ),
    );
  }
}
