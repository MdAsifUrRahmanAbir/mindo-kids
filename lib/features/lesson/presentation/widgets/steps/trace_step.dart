import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';

/// Finger tracing.
///
/// If the step has `strokes` (vector guide paths, 0–1 coordinates) the
/// child must cover ~70 % of the guide. Without strokes the faded glyph is
/// shown and any confident tracing over it counts.
class TraceStepView extends StatefulWidget {
  const TraceStepView({super.key, required this.step, required this.events});

  final LessonStep step;
  final StepEvents events;

  @override
  State<TraceStepView> createState() => _TraceStepViewState();
}

class _TraceStepViewState extends State<TraceStepView> {
  final List<List<Offset>> _strokes = [];
  bool _done = false;
  late final List<Offset> _guidePoints = _sampleGuide(widget.step.strokes);

  static List<Offset> _sampleGuide(List<List<Offset>> strokes) {
    final pts = <Offset>[];
    for (final s in strokes) {
      for (var i = 0; i + 1 < s.length; i++) {
        final a = s[i];
        final b = s[i + 1];
        final len = (b - a).distance;
        final n = max(1, (len / 0.03).ceil());
        for (var k = 0; k <= n; k++) {
          pts.add(Offset.lerp(a, b, k / n)!);
        }
      }
    }
    return pts;
  }

  void _check() {
    if (_done) return;
    final user = _strokes.expand((s) => s).toList();
    if (user.isEmpty) return;

    bool solved;
    if (_guidePoints.isNotEmpty) {
      var covered = 0;
      for (final g in _guidePoints) {
        if (user.any((u) => (u - g).distance < 0.08)) covered++;
      }
      solved = covered / _guidePoints.length >= 0.7;
    } else {
      var length = 0.0;
      for (final s in _strokes) {
        for (var i = 0; i + 1 < s.length; i++) {
          length += (s[i + 1] - s[i]).distance;
        }
      }
      solved = length >= 1.6;
    }

    if (solved) {
      setState(() => _done = true);
      widget.events.onAnswer(true);
      widget.events.onSolved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    final color = step.color ?? AppColors.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  step.instruction.isNotEmpty ? step.instruction : 'Trace the letter ${step.letter}',
                  style: AppTheme.heading(21),
                ),
              ),
              SpeakButton(text: step.speakText, audioUrl: step.audioUrl, locale: widget.events.locale),
            ],
          ),
          const SizedBox(height: 14),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: _done ? AppColors.success : AppColors.border, width: _done ? 3 : 1.5),
              ),
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, c) {
                  final size = c.biggest.shortestSide;
                  Offset norm(Offset p) => Offset(p.dx / size, p.dy / size);
                  return GestureDetector(
                    onPanStart: _done ? null : (d) => setState(() => _strokes.add([norm(d.localPosition)])),
                    onPanUpdate: _done
                        ? null
                        : (d) => setState(() {
                            if (_strokes.isEmpty) _strokes.add([]);
                            _strokes.last.add(norm(d.localPosition));
                          }),
                    onPanEnd: _done ? null : (_) => _check(),
                    child: CustomPaint(
                      size: Size.square(size),
                      painter: _TracePainter(
                        letter: step.letter,
                        guide: step.strokes,
                        user: _strokes,
                        color: color,
                        done: _done,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (!_done)
            TextButton.icon(
              onPressed: _strokes.isEmpty ? null : () => setState(_strokes.clear),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Start again'),
            )
          else
            Text('⭐ Beautiful tracing! ⭐', style: AppTheme.heading(20, color: AppColors.success)),
        ],
      ),
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({
    required this.letter,
    required this.guide,
    required this.user,
    required this.color,
    required this.done,
  });

  final String letter;
  final List<List<Offset>> guide;
  final List<List<Offset>> user;
  final Color color;
  final bool done;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;

    // Faded glyph
    if (letter.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: letter,
          style: AppTheme.heading(s * 0.78, color: color.tint(0.82), weight: FontWeight.w700, height: 1),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2));
    }

    // Dashed guide paths + green start dots
    final guidePaint = Paint()
      ..color = color.tint(0.35)
      ..strokeWidth = s * 0.018
      ..strokeCap = StrokeCap.round;
    for (final stroke in guide) {
      for (var i = 0; i + 1 < stroke.length; i++) {
        final a = stroke[i] * s;
        final b = stroke[i + 1] * s;
        final len = (b - a).distance;
        final dashes = max(1, (len / (s * 0.04)).floor());
        for (var k = 0; k < dashes; k += 2) {
          canvas.drawLine(Offset.lerp(a, b, k / dashes)!, Offset.lerp(a, b, min(1.0, (k + 1) / dashes))!, guidePaint);
        }
      }
      if (stroke.isNotEmpty) {
        canvas.drawCircle(stroke.first * s, s * 0.03, Paint()..color = AppColors.success);
      }
    }

    // Child's strokes
    final userPaint = Paint()
      ..color = done ? AppColors.success : color
      ..strokeWidth = s * 0.065
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final stroke in user) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawPoints(ui.PointMode.points, [stroke.first * s], userPaint);
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx * s, stroke.first.dy * s);
      for (final p in stroke.skip(1)) {
        path.lineTo(p.dx * s, p.dy * s);
      }
      canvas.drawPath(path, userPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TracePainter old) => true;
}
