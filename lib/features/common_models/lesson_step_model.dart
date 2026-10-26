import 'package:flutter/material.dart';

import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/media_ref.dart';

/// Activity types the lesson player can render. New types can be added to
/// the admin panel only after the app ships a widget for them — unknown
/// types are skipped safely.
enum StepType { story, quiz, letter, trace, match, memory, count, unknown }

StepType stepTypeFrom(String raw) => switch (raw) {
  'story' || 'read' => StepType.story,
  'quiz' || 'choice' => StepType.quiz,
  'letter' || 'recognition' => StepType.letter,
  'trace' || 'tracing' => StepType.trace,
  'match' || 'matching' => StepType.match,
  'memory' => StepType.memory,
  'count' || 'counting' => StepType.count,
  _ => StepType.unknown,
};

/// One answer / card / side of a pair: a text label and/or a picture.
class StepOption {
  final String text;
  final MediaRef media;
  final String audioUrl;

  const StepOption({this.text = '', this.media = const MediaRef(), this.audioUrl = ''});

  factory StepOption.fromMap(Map<String, dynamic> m) =>
      StepOption(text: m.str('text'), media: MediaRef.fromMap(m), audioUrl: m.str('audioUrl'));

  /// Options can also be stored as plain strings: ["A bed", "A mat"].
  static List<StepOption> listFrom(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map<StepOption>((e) {
      if (e is Map) return StepOption.fromMap(Map<String, dynamic>.from(e));
      return StepOption(text: e.toString());
    }).toList();
  }

  /// Identity used by memory/match games.
  String get key => '${media.imageUrl}|${media.emoji}|$text';
}

class MatchPair {
  final StepOption left;
  final StepOption right;
  const MatchPair(this.left, this.right);
}

/// lessons/{lessonId}/steps/{stepId}
class LessonStep {
  final String id;
  final int order;
  final StepType type;

  // Shared
  final String title;
  final String instruction;
  final MediaRef media;
  final String audioUrl;
  final Color? background;

  // story
  final String text;
  final List<String> highlights;

  // question (story / quiz / count)
  final String question;
  final List<StepOption> options;
  final int correctIndex;
  final String hint;

  // letter / trace
  final String letter;
  final String word;
  final Color? color;
  final List<List<Offset>> strokes;

  // match / memory
  final List<MatchPair> pairs;
  final List<StepOption> cards;

  // count
  final int count;

  const LessonStep({
    required this.id,
    required this.type,
    this.order = 0,
    this.title = '',
    this.instruction = '',
    this.media = const MediaRef(),
    this.audioUrl = '',
    this.background,
    this.text = '',
    this.highlights = const [],
    this.question = '',
    this.options = const [],
    this.correctIndex = 0,
    this.hint = '',
    this.letter = '',
    this.word = '',
    this.color,
    this.strokes = const [],
    this.pairs = const [],
    this.cards = const [],
    this.count = 0,
  });

  bool get hasQuestion => question.isNotEmpty && options.length >= 2;

  /// What the speaker button reads when no audio file is uploaded.
  String get speakText {
    switch (type) {
      case StepType.story:
        return text;
      case StepType.letter:
        // `text` lets each language phrase it naturally ("অ-তে অজগর").
        if (text.isNotEmpty) return '$letter. $text';
        return word.isEmpty ? letter : '$letter. $letter is for $word.';
      case StepType.trace:
        return instruction.isNotEmpty ? instruction : 'Trace the letter $letter';
      case StepType.quiz:
      case StepType.count:
        return question;
      default:
        return instruction;
    }
  }

  factory LessonStep.fromMap(String id, Map<String, dynamic> m) {
    final type = stepTypeFrom(m.str('type'));

    final strokes = <List<Offset>>[];
    for (final s in m.maps('strokes')) {
      final pts = s.numbers('points');
      final path = <Offset>[];
      for (var i = 0; i + 1 < pts.length; i += 2) {
        path.add(Offset(pts[i].toDouble(), pts[i + 1].toDouble()));
      }
      if (path.length >= 2) strokes.add(path);
    }

    final pairs = <MatchPair>[];
    for (final p in m.maps('pairs')) {
      pairs.add(MatchPair(StepOption.fromMap(p.obj('left')), StepOption.fromMap(p.obj('right'))));
    }

    final bg = m.str('bgColor');
    final color = m.str('color');

    return LessonStep(
      id: id,
      type: type,
      order: m.integer('order'),
      title: m.str('title'),
      instruction: m.str('instruction'),
      media: MediaRef.fromMap(m),
      audioUrl: m.str('audioUrl'),
      background: bg.isEmpty ? null : hexToColor(bg),
      text: m.str('text'),
      highlights: m.strings('highlights'),
      question: m.str('question'),
      options: StepOption.listFrom(m['options']),
      correctIndex: m.integer('correctIndex'),
      hint: m.str('hint'),
      letter: m.str('letter'),
      word: m.str('word'),
      color: color.isEmpty ? null : hexToColor(color),
      strokes: strokes,
      pairs: pairs,
      cards: StepOption.listFrom(m['cards']),
      count: m.integer('count'),
    );
  }
}
