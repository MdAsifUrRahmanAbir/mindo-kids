import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';

/// "Continue Learning" row: thumbnail, title, progress bar, %.
class LessonProgressCard extends StatelessWidget {
  const LessonProgressCard({
    super.key,
    required this.lesson,
    required this.fraction,
    required this.onTap,
    this.color,
    this.locked = false,
  });

  final LessonModel lesson;
  final double fraction;
  final VoidCallback onTap;
  final Color? color;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final percent = (fraction * 100).round();
    final tint = color ?? AppColors.primary;
    return SoftCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 96,
            height: 72,
            decoration: BoxDecoration(color: tint.tint(0.75), borderRadius: BorderRadius.circular(16)),
            clipBehavior: Clip.antiAlias,
            child: MediaView(lesson.thumbnail, width: 96, height: 72, fit: BoxFit.cover, emojiScale: 0.75),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 7,
                          backgroundColor: const Color(0xFFEDEBF5),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF59C9A5)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$percent%',
                      style: AppTheme.body(12, color: const Color(0xFF3BAF8A), weight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            locked ? Icons.lock_rounded : Icons.arrow_forward_rounded,
            color: locked ? AppColors.textMuted : AppColors.primary,
          ),
        ],
      ),
    );
  }
}
