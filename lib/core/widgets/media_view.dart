import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/features/common_models/media_ref.dart';

/// Renders a [MediaRef]: the uploaded image if there is one (cached on disk
/// for offline use), otherwise the emoji, otherwise a soft placeholder.
class MediaView extends StatelessWidget {
  const MediaView(
    this.media, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius = 0,
    this.emojiScale = 0.72,
  });

  final MediaRef media;
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;
  final double emojiScale;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;

    Widget child;
    if (media.hasImage) {
      child = CachedNetworkImage(
        imageUrl: media.imageUrl,
        width: w,
        height: h,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 200),
        placeholder: (_, _) => _placeholder(w, h),
        errorWidget: (_, _, _) => media.emoji.isNotEmpty ? _emoji(w, h) : _placeholder(w, h),
      );
    } else if (media.emoji.isNotEmpty) {
      child = _emoji(w, h);
    } else {
      child = _placeholder(w, h);
    }

    if (borderRadius > 0) {
      child = ClipRRect(borderRadius: BorderRadius.circular(borderRadius), child: child);
    }
    return child;
  }

  Widget _emoji(double? w, double? h) {
    final double base = (w != null && h != null) ? (w < h ? w : h) : (w ?? h ?? 64);
    return SizedBox(
      width: w,
      height: h,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(media.emoji, style: TextStyle(fontSize: base * emojiScale, height: 1.1)),
        ),
      ),
    );
  }

  Widget _placeholder(double? w, double? h) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(borderRadius)),
    child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
  );
}
