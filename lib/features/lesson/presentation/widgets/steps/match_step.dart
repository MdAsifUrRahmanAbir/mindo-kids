import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';

/// Matching: tap an item on the left, then its partner on the right.
class MatchStepView extends StatefulWidget {
  const MatchStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  State<MatchStepView> createState() => _MatchStepViewState();
}

class _MatchStepViewState extends State<MatchStepView> {
  late final List<int> _rightOrder = List.generate(widget.step.pairs.length, (i) => i)..shuffle(Random());
  final Set<int> _matched = {};
  int? _selectedLeft;
  int? _wrongRight;

  void _tapRight(int pairIndex) {
    final left = _selectedLeft;
    if (left == null || _matched.contains(pairIndex)) return;
    final correct = left == pairIndex;
    widget.events.onAnswer(correct);
    setState(() {
      if (correct) {
        _matched.add(pairIndex);
        _selectedLeft = null;
      } else {
        _wrongRight = pairIndex;
      }
    });
    if (!correct) {
      Timer(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _wrongRight = null);
      });
    }
    if (_matched.length == widget.step.pairs.length) widget.events.onSolved();
  }

  @override
  Widget build(BuildContext context) {
    final pairs = widget.step.pairs;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.step.instruction.isNotEmpty ? widget.step.instruction : 'Match the pairs',
                  style: AppTheme.heading(21),
                ),
              ),
              SpeakButton(text: widget.step.speakText, audioUrl: widget.step.audioUrl, locale: widget.events.locale),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    for (var i = 0; i < pairs.length; i++)
                      _MatchCard(
                        option: pairs[i].left,
                        matched: _matched.contains(i),
                        selected: _selectedLeft == i,
                        wrong: false,
                        onTap: _matched.contains(i) ? null : () => setState(() => _selectedLeft = i),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    for (final i in _rightOrder)
                      _MatchCard(
                        option: pairs[i].right,
                        matched: _matched.contains(i),
                        selected: false,
                        wrong: _wrongRight == i,
                        onTap: _matched.contains(i) ? null : () => _tapRight(i),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.option,
    required this.matched,
    required this.selected,
    required this.wrong,
    required this.onTap,
  });

  final StepOption option;
  final bool matched;
  final bool selected;
  final bool wrong;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final border = matched
        ? AppColors.success
        : wrong
        ? AppColors.error
        : selected
        ? AppColors.primary
        : AppColors.border;
    final bg = matched
        ? AppColors.successSoft
        : wrong
        ? AppColors.errorSoft
        : selected
        ? AppColors.primarySoft
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 92,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: selected || matched || wrong ? 2.4 : 1.4),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Center(
              child: option.media.isEmpty
                  ? Text(option.text, style: AppTheme.heading(26))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MediaView(option.media, size: option.text.isEmpty ? 60 : 46),
                        if (option.text.isNotEmpty)
                          Text(
                            option.text,
                            style: AppTheme.body(14, color: AppColors.navy, weight: FontWeight.w800),
                          ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
