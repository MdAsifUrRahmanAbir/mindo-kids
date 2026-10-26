import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';

/// One onboarding slide: big headline, subtitle, illustration on a soft
/// coloured blob and an optional hand-written side note — all from
/// Firestore `onboarding/{id}`.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.slide});
  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final artSize = (c.maxHeight * 0.48).clamp(160.0, 340.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(slide.title, style: AppTheme.heading(40, weight: FontWeight.w700, height: 1.05)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 40, left: 4),
                    child: Text('✨', style: TextStyle(fontSize: 26)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (slide.subtitle.isNotEmpty)
                Text(
                  slide.subtitle,
                  style: AppTheme.body(16, color: AppColors.textMuted, weight: FontWeight.w600, height: 1.45),
                ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      right: -40,
                      bottom: 0,
                      child: Container(
                        width: artSize * 1.05,
                        height: artSize * 0.95,
                        decoration: BoxDecoration(
                          color: slide.accent.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(artSize),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: MediaView(slide.media, size: artSize, emojiScale: 0.8),
                    ),
                    if (slide.sideNote.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 24,
                        child: Transform.rotate(
                          angle: -0.18,
                          child: SizedBox(
                            width: 110,
                            child: Text(
                              '${slide.sideNote}\n♡',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.caveat(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: AppColors.navy,
                                height: 1.05,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
