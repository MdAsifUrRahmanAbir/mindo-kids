import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/services/audio_service.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';

/// What every activity widget reports back to the lesson player.
class StepEvents {
  const StepEvents({required this.onAnswer, required this.onSolved, required this.locale});

  /// Called for every attempt (true = correct). Wrong attempts lower the
  /// lesson's stars; they never block the child.
  final ValueChanged<bool> onAnswer;

  /// Called once when the activity is finished — enables "Next".
  final VoidCallback onSolved;

  /// TTS locale of the current world (en-US, bn-BD …).
  final String locale;
}

/// Purple round speaker button ("🔊") — replays narration.
class SpeakButton extends ConsumerWidget {
  const SpeakButton({super.key, required this.text, this.audioUrl = '', required this.locale, this.size = 42});

  final String text;
  final String audioUrl;
  final String locale;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (text.isEmpty && audioUrl.isEmpty) return const SizedBox.shrink();
    return Material(
      color: AppColors.primarySoft,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ref.read(audioServiceProvider).speak(audioUrl: audioUrl, text: text, locale: locale),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.volume_up_rounded, color: AppColors.primary, size: size * 0.55),
        ),
      ),
    );
  }
}

enum OptionState { idle, correct, wrong, disabled }

/// Answer tile ("A bed" / "A mat ✓" / "A table") with picture support.
class OptionTile extends StatefulWidget {
  const OptionTile({super.key, required this.option, required this.state, required this.onTap, this.big = false});

  final StepOption option;
  final OptionState state;
  final VoidCallback? onTap;
  final bool big;

  @override
  State<OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<OptionTile> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

  @override
  void didUpdateWidget(covariant OptionTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == OptionState.wrong && oldWidget.state != OptionState.wrong) {
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    final (bg, border) = switch (s) {
      OptionState.correct => (AppColors.successSoft, AppColors.success),
      OptionState.wrong => (AppColors.errorSoft, AppColors.error),
      OptionState.disabled => (const Color(0xFFF6F5FA), AppColors.border),
      OptionState.idle => (AppColors.surface, AppColors.border),
    };
    final hasMedia = !widget.option.media.isEmpty;

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) =>
          Transform.translate(offset: Offset(sin(_shake.value * pi * 6) * 8 * (1 - _shake.value), 0), child: child),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border, width: s == OptionState.idle ? 1.4 : 2.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B45C9).withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: widget.onTap,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: widget.big ? 14 : 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasMedia) MediaView(widget.option.media, size: widget.big ? 72 : 52),
                      if (hasMedia && widget.option.text.isNotEmpty) const SizedBox(height: 6),
                      if (widget.option.text.isNotEmpty)
                        Text(
                          widget.option.text,
                          textAlign: TextAlign.center,
                          style: AppTheme.body(
                            widget.big ? 22 : 16,
                            color: s == OptionState.correct ? const Color(0xFF1E8A52) : AppColors.navy,
                            weight: FontWeight.w800,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (s == OptionState.correct)
            const Positioned(
              right: -6,
              bottom: -6,
              child: CircleAvatar(
                radius: 13,
                backgroundColor: AppColors.success,
                child: Icon(Icons.check_rounded, size: 17, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shared answer logic for story / quiz / count questions.
class QuestionOptions extends StatefulWidget {
  const QuestionOptions({super.key, required this.step, required this.events, this.big = false});

  final LessonStep step;
  final StepEvents events;
  final bool big;

  @override
  State<QuestionOptions> createState() => _QuestionOptionsState();
}

class _QuestionOptionsState extends State<QuestionOptions> {
  final Set<int> _wrong = {};
  bool _solved = false;

  void _pick(int i) {
    if (_solved || _wrong.contains(i)) return;
    final correct = i == widget.step.correctIndex;
    widget.events.onAnswer(correct);
    setState(() {
      if (correct) {
        _solved = true;
      } else {
        _wrong.add(i);
      }
    });
    if (correct) widget.events.onSolved();
  }

  OptionState _stateOf(int i) {
    if (_solved) return i == widget.step.correctIndex ? OptionState.correct : OptionState.disabled;
    if (_wrong.contains(i)) return OptionState.wrong;
    return OptionState.idle;
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.step.options;
    final columns = options.length >= 4 ? 2 : max(options.length, 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_wrong.isNotEmpty && !_solved && widget.step.hint.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              '💡 ${widget.step.hint}',
              textAlign: TextAlign.center,
              style: AppTheme.body(14, color: AppColors.textMuted),
            ),
          ),
        LayoutBuilder(
          builder: (context, c) {
            const gap = 12.0;
            final w = (c.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < options.length; i++)
                  SizedBox(
                    width: w,
                    child: OptionTile(option: options[i], state: _stateOf(i), big: widget.big, onTap: () => _pick(i)),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}
