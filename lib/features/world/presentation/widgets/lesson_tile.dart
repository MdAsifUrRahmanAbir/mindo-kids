import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';

/// One stop on a world's lesson journey.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    required this.index,
    required this.color,
    required this.progress,
    required this.locked,
    required this.onTap,
  });

  final LessonModel lesson;
  final int index;
  final Color color;
  final LessonProgress? progress;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final done = progress?.completed ?? false;
    final stars = progress?.stars ?? 0;
    final started = !done && (progress?.currentStep ?? 0) > 0;

    return SoftCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(color: color.tint(0.78), borderRadius: BorderRadius.circular(18)),
                clipBehavior: Clip.antiAlias,
                child: MediaView(lesson.thumbnail, size: 70, fit: BoxFit.cover),
              ),
              Positioned(
                left: -6,
                top: -6,
                child: CircleAvatar(
                  radius: 13,
                  backgroundColor: color,
                  child: Text(
                    '${index + 1}',
                    style: AppTheme.body(12, color: Colors.white, weight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(15.5, color: AppColors.navy, weight: FontWeight.w800),
                      ),
                    ),
                    if (lesson.isPremium) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          'PRO',
                          style: AppTheme.body(10, color: AppColors.navy, weight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ],
                ),
                if (lesson.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    lesson.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.body(12.5, color: AppColors.textMuted),
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Icon(Icons.star_rounded, size: 18, color: i < stars ? AppColors.star : const Color(0xFFE3E0EF)),
                    const SizedBox(width: 8),
                    Icon(Icons.schedule_rounded, size: 14, color: AppColors.textMuted.withValues(alpha: 0.8)),
                    const SizedBox(width: 3),
                    Text('${lesson.durationMinutes} min', style: AppTheme.body(12, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _StateIcon(done: done, started: started, locked: locked, color: color),
        ],
      ),
    );
  }
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.done, required this.started, required this.locked, required this.color});
  final bool done;
  final bool started;
  final bool locked;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (locked) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.surfaceSoft,
        child: Icon(Icons.lock_rounded, size: 18, color: AppColors.textMuted),
      );
    }
    if (done) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: AppColors.success,
        child: Icon(Icons.check_rounded, size: 20, color: Colors.white),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: color,
      child: Icon(started ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded, size: 20, color: Colors.white),
    );
  }
}
