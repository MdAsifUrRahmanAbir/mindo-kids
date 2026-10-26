import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/home/presentation/widgets/badge_tile.dart';
import 'package:mindo_kids/features/progress/providers/progress_providers.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final child = ref.watch(activeChildProvider);
    final badgesAsync = ref.watch(badgesProvider);
    final earned = ref.watch(earnedBadgesProvider).value ?? const {};

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(t('rewards.title', 'My rewards'), style: AppTheme.heading(28, weight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (child != null)
              Row(
                children: [
                  _Stat(emoji: '⭐', value: '${child.stars}', label: t('rewards.stars', 'Stars')),
                  const SizedBox(width: 12),
                  _Stat(emoji: '📚', value: '${child.lessonsCompleted}', label: t('rewards.lessons', 'Lessons')),
                  const SizedBox(width: 12),
                  _Stat(emoji: '🔥', value: '${child.bestStreak}', label: t('rewards.bestStreak', 'Best streak')),
                ],
              ),
            const SizedBox(height: 24),
            SectionHeader(
              title: t('rewards.badges', 'Badges · {earned}/{total}', {
                'earned': earned.length,
                'total': badgesAsync.value?.length ?? 0,
              }),
            ),
            const SizedBox(height: 12),
            AsyncBody<List<BadgeModel>>(
              value: badgesAsync,
              onRetry: () => ref.invalidate(badgesProvider),
              builder: (badges) {
                if (badges.isEmpty) {
                  return MessageView(emoji: '🏅', title: t('rewards.empty', 'Badges are coming soon!'));
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: badges.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemBuilder: (_, i) {
                    final b = badges[i];
                    final has = earned.containsKey(b.id);
                    return BadgeTile(
                      badge: b,
                      earned: has,
                      size: 74,
                      onTap: () => _showBadge(context, b, has, earned[b.id]),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBadge(BuildContext context, BadgeModel b, bool earned, DateTime? when) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: b.color, shape: BoxShape.circle),
              child: MediaView(b.icon, size: 74),
            ),
            const SizedBox(height: 14),
            Text(b.title, style: AppTheme.heading(24)),
            const SizedBox(height: 6),
            Text(
              b.description,
              textAlign: TextAlign.center,
              style: AppTheme.body(15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            Text(
              earned
                  ? (when == null ? 'Earned! 🎉' : 'Earned on ${DateFormat.yMMMd().format(when)} 🎉')
                  : 'Keep learning to unlock this badge!',
              style: AppTheme.body(14, color: earned ? AppColors.success : AppColors.primary, weight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.emoji, required this.value, required this.label});
  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SoftCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(value, style: AppTheme.heading(24)),
            Text(label, style: AppTheme.body(12, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
