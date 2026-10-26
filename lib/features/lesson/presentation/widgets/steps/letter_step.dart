import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/services/audio_service.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';

/// Letter / number recognition: big glyph + "A is for Apple" + picture.
/// Tapping the glyph replays the pronunciation.
class LetterStepView extends ConsumerWidget {
  const LetterStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = step.color ?? AppColors.primary;
    void speak() =>
        ref.read(audioServiceProvider).speak(audioUrl: step.audioUrl, text: step.speakText, locale: events.locale);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          if (step.instruction.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Text(step.instruction, textAlign: TextAlign.center, style: AppTheme.heading(20)),
            ),
          GestureDetector(
            onTap: speak,
            child: Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.tint(0.15), color],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 22, offset: const Offset(0, 10)),
                ],
              ),
              child: Center(
                child: FittedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      step.letter,
                      style: AppTheme.heading(150, color: Colors.white, weight: FontWeight.w700, height: 1),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          SoftCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                MediaView(step.media, size: 86, borderRadius: 18),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    step.word,
                    style: AppTheme.heading(30, color: color.shade(0.15), weight: FontWeight.w700),
                  ),
                ),
                SpeakButton(text: step.speakText, audioUrl: step.audioUrl, locale: events.locale, size: 52),
              ],
            ),
          ),
          if (step.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              step.text,
              textAlign: TextAlign.center,
              style: AppTheme.body(16, color: AppColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}
