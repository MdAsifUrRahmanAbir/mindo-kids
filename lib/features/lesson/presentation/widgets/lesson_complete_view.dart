import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/home/presentation/widgets/badge_tile.dart';
import 'package:mindo_kids/features/progress/data/repositories/progress_repository.dart';

/// Calm celebration after a lesson: stars, streak and any new badges.
class LessonCompleteView extends ConsumerWidget {
  const LessonCompleteView({
    super.key,
    required this.completion,
    required this.correct,
    required this.total,
    required this.onHome,
    this.onNext,
  });

  final LessonCompletion completion;
  final int correct;
  final int total;
  final VoidCallback onHome;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        child: Column(
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 8),
            Text(
              t('complete.title', 'Lesson complete!'),
              textAlign: TextAlign.center,
              style: AppTheme.heading(32, weight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 450 + i * 250),
                    curve: Curves.elasticOut,
                    builder: (_, v, child) => Transform.scale(scale: v, child: child),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: i == 1 ? 18 : 0),
                      child: Icon(
                        Icons.star_rounded,
                        size: i == 1 ? 84 : 66,
                        color: i < completion.stars ? AppColors.star : const Color(0xFFE3E0EF),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (total > 0)
              Text(
                t('complete.score', 'You got {correct} of {total} right on the first try!', {
                  'correct': correct,
                  'total': total,
                }),
                textAlign: TextAlign.center,
                style: AppTheme.body(16, color: AppColors.textMuted),
              ),
            const SizedBox(height: 16),
            SoftCard(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 26)),
                  const SizedBox(width: 10),
                  Text(
                    t('complete.streak', '{count} day streak', {'count': completion.streak}),
                    style: AppTheme.heading(19, color: AppColors.streak),
                  ),
                ],
              ),
            ),
            if (completion.newBadges.isNotEmpty) ...[
              const SizedBox(height: 26),
              Text(t('complete.newBadge', 'New badge unlocked!'), style: AppTheme.heading(20)),
              const SizedBox(height: 14),
              Wrap(
                spacing: 18,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [for (final b in completion.newBadges) BadgeTile(badge: b, earned: true, size: 76)],
              ),
            ],
            const SizedBox(height: 34),
            if (onNext != null) ...[
              PrimaryButton(label: t('complete.next', 'Next lesson'), onPressed: onNext),
              const SizedBox(height: 12),
            ],
            PrimaryButton.navy(
              label: t('complete.home', 'Back to home'),
              trailingIcon: Icons.home_rounded,
              onPressed: onHome,
            ),
          ],
        ),
      ),
    );
  }
}
