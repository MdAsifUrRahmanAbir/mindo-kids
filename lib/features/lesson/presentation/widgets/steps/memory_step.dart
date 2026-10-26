import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';

/// Memory cards: every item in `cards` appears twice; find the pairs.
/// Mismatches are part of the game, so they never cost stars.
class MemoryStepView extends StatefulWidget {
  const MemoryStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  State<MemoryStepView> createState() => _MemoryStepViewState();
}

class _MemoryStepViewState extends State<MemoryStepView> {
  late final List<StepOption> _deck = [...widget.step.cards, ...widget.step.cards]..shuffle(Random());
  final Set<int> _found = {};
  final List<int> _open = [];
  bool _busy = false;

  void _flip(int i) {
    if (_busy || _found.contains(i) || _open.contains(i)) return;
    setState(() => _open.add(i));
    if (_open.length < 2) return;

    final a = _open[0];
    final b = _open[1];
    if (_deck[a].key == _deck[b].key) {
      setState(() {
        _found.addAll([a, b]);
        _open.clear();
      });
      if (_found.length == _deck.length) {
        widget.events.onAnswer(true);
        widget.events.onSolved();
      }
    } else {
      _busy = true;
      Timer(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        setState(() {
          _open.clear();
          _busy = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final columns = _deck.length <= 6 ? 3 : 4;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.step.instruction.isNotEmpty ? widget.step.instruction : 'Find the matching pairs',
                  style: AppTheme.heading(21),
                ),
              ),
              SpeakButton(text: widget.step.speakText, audioUrl: widget.step.audioUrl, locale: widget.events.locale),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _deck.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (_, i) {
              final faceUp = _found.contains(i) || _open.contains(i);
              return GestureDetector(
                onTap: () => _flip(i),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                  child: faceUp
                      ? Container(
                          key: ValueKey('up$i'),
                          decoration: BoxDecoration(
                            color: _found.contains(i) ? AppColors.successSoft : Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: _found.contains(i) ? AppColors.success : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: _deck[i].media.isEmpty
                                ? Text(_deck[i].text, style: AppTheme.heading(24))
                                : MediaView(_deck[i].media, size: 56),
                          ),
                        )
                      : Container(
                          key: ValueKey('down$i'),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(child: Text('❓', style: TextStyle(fontSize: 30))),
                        ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
