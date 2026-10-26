import 'package:flutter/material.dart';

import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';

/// Coloured world tile from the dashboard grid (Reading / Math / …).
/// Colour, icon, title and subtitle all come from worlds/{id}.
class WorldCard extends StatelessWidget {
  const WorldCard({super.key, required this.world, required this.onTap, this.footer});

  final WorldModel world;
  final VoidCallback onTap;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final c = world.color;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c.tint(0.08), c], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MediaView(world.icon, size: 46),
                const Spacer(),
                Text(
                  world.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.heading(18, color: Colors.white),
                ),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        footer ?? world.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(12, color: Colors.white.withValues(alpha: 0.92), height: 1.25),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_forward_rounded, size: 18, color: c.shade(0.15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
