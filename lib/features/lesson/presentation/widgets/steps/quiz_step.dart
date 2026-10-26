import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';

/// Picture question + answers (also used for picture association).
class QuizStepView extends StatelessWidget {
  const QuizStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          SoftCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                if (!step.media.isEmpty) ...[
                  MediaView(step.media, size: 150, borderRadius: 20),
                  const SizedBox(height: 14),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(step.question, textAlign: TextAlign.center, style: AppTheme.heading(21)),
                    ),
                    const SizedBox(width: 8),
                    SpeakButton(text: step.speakText, audioUrl: step.audioUrl, locale: events.locale),
                  ],
                ),
                if (step.instruction.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(step.instruction, style: AppTheme.body(14, color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 22),
          QuestionOptions(step: step, events: events, big: true),
        ],
      ),
    );
  }
}

/// "How many apples?" — shows `count` copies of the item, then answers.
class CountStepView extends StatelessWidget {
  const CountStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  Widget build(BuildContext context) {
    final n = step.count.clamp(0, 20);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          SoftCard(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(step.question, textAlign: TextAlign.center, style: AppTheme.heading(21)),
                    ),
                    const SizedBox(width: 8),
                    SpeakButton(text: step.speakText, audioUrl: step.audioUrl, locale: events.locale),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 10,
                  runSpacing: 10,
                  children: [for (var i = 0; i < n; i++) MediaView(step.media, size: n > 10 ? 40 : 54)],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          QuestionOptions(step: step, events: events, big: true),
        ],
      ),
    );
  }
}
