import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';

/// Badge circle + title. Not-yet-earned badges are shown faded with a lock.
class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge, required this.earned, this.size = 62, this.onTap});

  final BadgeModel badge;
  final bool earned;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: earned ? 1 : 0.45,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: size,
                  height: size,
                  padding: EdgeInsets.all(size * 0.16),
                  decoration: BoxDecoration(
                    color: badge.color,
                    shape: BoxShape.circle,
                    boxShadow: earned
                        ? [
                            BoxShadow(
                              color: badge.color.withValues(alpha: 0.6),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: MediaView(badge.icon, size: size * 0.68),
                ),
                if (!earned)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.lock_rounded, size: 13, color: AppColors.textMuted),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: size + 18,
              child: Text(
                badge.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.body(11.5, color: AppColors.navy, weight: FontWeight.w700, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
