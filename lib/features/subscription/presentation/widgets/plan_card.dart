import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';

class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan, required this.price, required this.selected, required this.onTap});

  final PlanModel plan;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected ? AppColors.primarySoft : AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2.4 : 1.4),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        selected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                        color: selected ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.title, style: AppTheme.heading(19)),
                            if (plan.subtitle.isNotEmpty)
                              Text(plan.subtitle, style: AppTheme.body(13, color: AppColors.textMuted)),
                            for (final f in plan.features)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(f, style: AppTheme.body(13, weight: FontWeight.w600)),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(price, style: AppTheme.heading(20, color: AppColors.primary)),
                          if (plan.periodLabel.isNotEmpty)
                            Text(plan.periodLabel, style: AppTheme.body(12, color: AppColors.textMuted)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (plan.badgeText.isNotEmpty)
            Positioned(
              top: -11,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: AppColors.brandYellow, borderRadius: BorderRadius.circular(10)),
                child: Text(
                  plan.badgeText,
                  style: AppTheme.body(11, color: AppColors.navy, weight: FontWeight.w900),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
