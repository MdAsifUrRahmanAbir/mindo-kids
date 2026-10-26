import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/children/data/repositories/children_repository.dart';
import 'package:mindo_kids/features/children/presentation/widgets/avatar_picker.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/progress/providers/progress_providers.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Parent view of one child: progress per world + daily screen-time limit.
class ParentChildScreen extends ConsumerWidget {
  const ParentChildScreen({super.key, required this.childId});
  final String childId;

  static const _limits = [0, 15, 30, 45, 60, 90];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final session = ref.watch(sessionControllerProvider);
    final child = session.children.findOrNull((c) => c.id == childId);
    final progress = ref.watch(childProgressProvider(childId)).value ?? const <LessonProgress>[];
    final worlds = ref.watch(worldsProvider).value ?? const <WorldModel>[];
    final lessons = ref.watch(allLessonsProvider).value ?? const <LessonModel>[];

    if (child == null) {
      return Scaffold(appBar: AppBar(), body: const LoadingView());
    }

    final completedIds = {
      for (final p in progress)
        if (p.completed) p.lessonId,
    };
    final starsById = {for (final p in progress) p.lessonId: p.stars};

    return Scaffold(
      appBar: AppBar(
        title: Text(child.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push(RouteNames.childEdit(child.id)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            SoftCard(
              child: Row(
                children: [
                  ChildAvatar(media: child.avatar, size: 64),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _Mini(label: t('parentChild.lessons', 'Lessons'), value: '${child.lessonsCompleted}'),
                        _Mini(label: t('parentChild.stars', 'Stars'), value: '${child.stars}'),
                        _Mini(label: t('parentChild.streak', 'Streak'), value: '${child.streak}'),
                        _Mini(label: t('parentChild.best', 'Best'), value: '${child.bestStreak}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ---- Screen time ----
            SectionHeader(title: t('parentChild.screenTime', 'Daily screen time')),
            const SizedBox(height: 4),
            Text(
              t('parentChild.screenTimeHint', 'When the limit is reached, a calm break screen appears on this device.'),
              style: AppTheme.body(13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in _limits)
                  ChoiceChip(
                    label: Text(m == 0 ? t('parentChild.noLimit', 'No limit') : '$m min'),
                    selected: child.dailyLimitMinutes == m,
                    selectedColor: AppColors.primarySoft,
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.border),
                    showCheckmark: false,
                    labelStyle: AppTheme.body(14, color: AppColors.navy, weight: FontWeight.w800),
                    onSelected: (_) async {
                      try {
                        await ref
                            .read(childrenRepositoryProvider)
                            .updateChild(session.uid!, child.id, dailyLimitMinutes: m);
                      } catch (e) {
                        if (context.mounted) showSnack(context, friendlyError(e));
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 26),

            // ---- Progress by world ----
            SectionHeader(title: t('parentChild.progress', 'Progress by world')),
            const SizedBox(height: 8),
            for (final w in worlds) ...[
              _WorldProgress(
                world: w,
                lessons: lessons.where((l) => l.worldId == w.id).toList(),
                completedIds: completedIds,
                starsById: starsById,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(value, style: AppTheme.heading(20)),
      Text(label, style: AppTheme.body(12, color: AppColors.textMuted)),
    ],
  );
}

class _WorldProgress extends StatelessWidget {
  const _WorldProgress({
    required this.world,
    required this.lessons,
    required this.completedIds,
    required this.starsById,
  });

  final WorldModel world;
  final List<LessonModel> lessons;
  final Set<String> completedIds;
  final Map<String, int> starsById;

  @override
  Widget build(BuildContext context) {
    final done = lessons.where((l) => completedIds.contains(l.id)).length;
    final c = world.color;
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c.tint(0.78), borderRadius: BorderRadius.circular(12)),
            child: MediaView(world.icon, size: 44),
          ),
          title: Text(
            world.title,
            style: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w800),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: lessons.isEmpty ? 0 : done / lessons.length,
                minHeight: 6,
                backgroundColor: c.tint(0.85),
                valueColor: AlwaysStoppedAnimation(c),
              ),
            ),
          ),
          trailing: Text(
            '$done/${lessons.length}',
            style: AppTheme.body(13, color: c.shade(0.2), weight: FontWeight.w800),
          ),
          children: [
            for (final l in lessons)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  completedIds.contains(l.id) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: completedIds.contains(l.id) ? AppColors.success : AppColors.border,
                ),
                title: Text(l.title, style: AppTheme.body(14, color: AppColors.navy)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < 3; i++)
                      Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: i < (starsById[l.id] ?? 0) ? AppColors.star : const Color(0xFFE3E0EF),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
