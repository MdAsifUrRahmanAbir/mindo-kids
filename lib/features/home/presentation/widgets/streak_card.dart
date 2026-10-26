import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/date_utils.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';

/// "You're on a 5 day streak! 🔥" + this week's learning days.
/// Calm by design: no penalties, just a gentle record of learning days.
class StreakCard extends ConsumerWidget {
  const StreakCard({super.key, required this.child});
  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final now = DateTime.now();
    final today = dayKey(now);
    final streak = child.currentStreak(today, dayKey(now.subtract(const Duration(days: 1))));
    final active = child.activeDates.toSet();
    final week = currentWeek(now);

    final title = streak > 0
        ? t('home.streak', 'You\'re on a {count} day streak! 🔥', {'count': streak})
        : t('home.streakStart', 'Start your learning streak today! ✨');

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 14),
      decoration: BoxDecoration(color: const Color(0xFFE9E5FF), borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < 7; i++)
                      _Day(
                        label: t('weekday.$i', weekdayShort[i]),
                        done: active.contains(dayKey(week[i])),
                        isToday: dayKey(week[i]) == today,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('⭐', style: TextStyle(fontSize: 40)),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.label, required this.done, required this.isToday});
  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.primary : const Color(0xFFD9D3FA),
            border: isToday && !done ? Border.all(color: AppColors.primary, width: 2) : null,
          ),
          child: done ? const Icon(Icons.check_rounded, size: 17, color: Colors.white) : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.body(11, color: AppColors.textMuted)),
      ],
    );
  }
}
