import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

/// A learning world's lesson journey (lessons where worldId == this world).
class WorldScreen extends ConsumerWidget {
  const WorldScreen({super.key, required this.worldId});
  final String worldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final world = ref.watch(worldByIdProvider(worldId));
    final lessonsAsync = ref.watch(lessonsForWorldProvider(worldId));
    final progress = ref.watch(progressMapProvider).value ?? const {};
    final isPremium = ref.watch(isPremiumProvider);

    if (world == null) {
      return Scaffold(
        appBar: AppBar(),
        body: ref.watch(worldsProvider).isLoading
            ? const LoadingView()
            : MessageView(emoji: '🪐', title: t('world.notFound', 'This world is not available.')),
      );
    }

    final color = world.color;
    final lessons = lessonsAsync.value ?? const <LessonModel>[];
    final completed = lessons.where((l) => progress[l.id]?.completed ?? false).length;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 230,
            backgroundColor: color,
            foregroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleIconButton(icon: Icons.arrow_back_ios_new_rounded, size: 40, onPressed: () => context.pop()),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.tint(0.1), color.shade(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(22, 90, 22, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            world.title,
                            style: AppTheme.heading(28, color: Colors.white, weight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            world.description.isNotEmpty ? world.description : world.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.body(14, color: Colors.white.withValues(alpha: 0.92)),
                          ),
                          const SizedBox(height: 10),
                          if (lessons.isNotEmpty)
                            Text(
                              t('world.progress', '{done} of {total} lessons done', {
                                'done': completed,
                                'total': lessons.length,
                              }),
                              style: AppTheme.body(13, color: Colors.white, weight: FontWeight.w800),
                            ),
                        ],
                      ),
                    ),
                    MediaView(world.icon, size: 96),
                  ],
                ),
              ),
            ),
          ),
          if (lessonsAsync.isLoading && lessons.isEmpty)
            const SliverFillRemaining(child: LoadingView())
          else if (lessons.isEmpty)
            SliverFillRemaining(
              child: MessageView(emoji: '🧩', title: t('world.empty', 'Lessons are on their way!')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              sliver: SliverList.separated(
                itemCount: lessons.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final lesson = lessons[i];
                  return LessonTile(
                    lesson: lesson,
                    index: i,
                    color: color,
                    progress: progress[lesson.id],
                    locked: lesson.isPremium && !isPremium,
                    onTap: () => openLesson(context, ref, lesson),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
