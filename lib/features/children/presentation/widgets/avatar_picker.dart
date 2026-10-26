import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/media_ref.dart';

/// Circular avatar used across the app (dashboard header, profile …).
class ChildAvatar extends StatelessWidget {
  const ChildAvatar({super.key, required this.media, this.size = 52, this.background, this.ring = false});

  final MediaRef media;
  final double size;
  final Color? background;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFFFE3EC),
        shape: BoxShape.circle,
        border: ring ? Border.all(color: AppColors.primary, width: 3) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: media.hasImage
          ? MediaView(media, size: size, fit: BoxFit.cover)
          : MediaView(media, size: size, emojiScale: 0.62),
    );
  }
}

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, required this.avatars, required this.selectedId, required this.onSelected});

  final List<AvatarModel> avatars;
  final String? selectedId;
  final ValueChanged<AvatarModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final a in avatars)
          GestureDetector(
            onTap: () => onSelected(a),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: a.id == selectedId ? 1.08 : 1,
              child: ChildAvatar(media: a.media, size: 64, background: a.background, ring: a.id == selectedId),
            ),
          ),
      ],
    );
  }
}
