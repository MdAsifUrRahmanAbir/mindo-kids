import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';

/// "Let's Read!" — speech bubble with highlighted words, illustration and
/// an optional comprehension question (exactly the demo's lesson screen).
class StoryStepView extends ConsumerWidget {
  const StoryStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SpeechBubble(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        step.title.isNotEmpty ? step.title : t('lesson.letsRead', 'Let\'s Read!'),
                        style: AppTheme.heading(24, weight: FontWeight.w700),
                      ),
                    ),
                    SpeakButton(text: step.speakText, audioUrl: step.audioUrl, locale: events.locale),
                  ],
                ),
                const SizedBox(height: 10),
                HighlightedText(text: step.text, highlights: step.highlights),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Center(
              child: LayoutBuilder(
                builder: (_, c) => MediaView(step.media, width: c.maxWidth, height: c.maxHeight, emojiScale: 0.85),
              ),
            ),
          ),
        ),
        if (step.hasQuestion)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step.question,
                  textAlign: TextAlign.center,
                  style: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                QuestionOptions(step: step, events: events),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: child,
        ),
        Positioned(
          bottom: -10,
          left: 70,
          child: Transform.rotate(angle: 0.785398, child: Container(width: 22, height: 22, color: Colors.white)),
        ),
      ],
    );
  }
}

/// Renders text and puts a soft marker behind the words listed in
/// `highlights` (case-insensitive). Works for any script (Bangla, Hindi …).
class HighlightedText extends StatelessWidget {
  const HighlightedText({super.key, required this.text, required this.highlights, this.fontSize = 21});

  final String text;
  final List<String> highlights;
  final double fontSize;

  static final _tokens = RegExp(r"[\p{L}\p{M}\p{N}']+|[^\p{L}\p{M}\p{N}']+", unicode: true);
  static const _markers = [Color(0xFFCDEFD9), Color(0xFFFFE9A8), Color(0xFFE2DAFF), Color(0xFFFFD9D9)];

  @override
  Widget build(BuildContext context) {
    final style = AppTheme.body(fontSize, color: AppColors.navy, weight: FontWeight.w600, height: 1.6);
    final wanted = highlights.map((h) => h.toLowerCase()).toList();
    var markerIndex = 0;

    final spans = <InlineSpan>[];
    for (final m in _tokens.allMatches(text)) {
      final token = m.group(0)!;
      final idx = wanted.indexOf(token.toLowerCase());
      if (idx >= 0) {
        final color = _markers[markerIndex++ % _markers.length];
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              child: Text(token, style: style.copyWith(fontWeight: FontWeight.w800, height: 1.25)),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: token, style: style));
      }
    }
    return Text.rich(TextSpan(children: spans));
  }
}
