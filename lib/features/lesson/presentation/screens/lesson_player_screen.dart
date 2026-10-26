import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/services/audio_service.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/parent_gate.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/lesson_step_model.dart';
import 'package:mindo_kids/features/content/data/repositories/content_repository.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/lesson_complete_view.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/step_common.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/steps/letter_step.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/steps/match_step.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/steps/memory_step.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/steps/quiz_step.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/steps/story_step.dart';
import 'package:mindo_kids/features/lesson/presentation/widgets/steps/trace_step.dart';
import 'package:mindo_kids/features/progress/data/repositories/progress_repository.dart';
import 'package:mindo_kids/features/progress/providers/progress_providers.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Data-driven lesson player: renders lessons/{id}/steps in order using
/// the activity widget for each step `type`.
class LessonPlayerScreen extends ConsumerStatefulWidget {
  const LessonPlayerScreen({super.key, required this.lessonId});
  final String lessonId;

  @override
  ConsumerState<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends ConsumerState<LessonPlayerScreen> {
  LessonModel? _lesson;
  List<LessonStep> _steps = const [];
  bool _loading = true;
  bool _locked = false;
  Object? _error;

  int _index = 0;
  final Set<int> _solved = {};
  final Set<int> _interactive = {};
  final Set<int> _mistakes = {};

  bool _finishing = false;
  LessonCompletion? _completion;

  String? _feedback;
  bool _feedbackGood = true;
  Timer? _feedbackTimer;
  final _rand = Random();
  late final AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
    _load();
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    _audio.stop();
    super.dispose();
  }

  // ---------------------------------------------------------------- data

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _locked = false;
      _error = null;
    });
    final repo = ref.read(contentRepositoryProvider);
    try {
      final lesson = await repo.watchLesson(widget.lessonId).first;
      if (lesson == null) throw StateError('Lesson not found');

      List<LessonStep> steps;
      try {
        steps = await repo.getSteps(lesson.id);
      } catch (e) {
        if (isPermissionDenied(e)) {
          if (!mounted) return;
          setState(() {
            _lesson = lesson;
            _locked = true;
            _loading = false;
          });
          return;
        }
        rethrow;
      }

      _solved.clear();
      _interactive.clear();
      _mistakes.clear();
      for (var i = 0; i < steps.length; i++) {
        if (_isPassive(steps[i])) {
          _solved.add(i);
        } else {
          _interactive.add(i);
        }
      }

      // Resume where the child left off.
      final saved = ref.read(progressMapProvider).value?[lesson.id];
      var start = 0;
      if (saved != null && !saved.completed && saved.currentStep > 0 && saved.currentStep < steps.length) {
        start = saved.currentStep;
      }

      if (!mounted) return;
      setState(() {
        _lesson = lesson;
        _steps = steps;
        _index = start;
        _loading = false;
      });
      _narrate();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  bool _isPassive(LessonStep s) => switch (s.type) {
    StepType.letter => true,
    StepType.story => !s.hasQuestion,
    StepType.quiz || StepType.count => s.options.length < 2,
    StepType.match => s.pairs.isEmpty,
    StepType.memory => s.cards.isEmpty,
    StepType.trace => false,
    StepType.unknown => true,
  };

  WorldModel? get _world => _lesson == null ? null : ref.read(worldByIdProvider(_lesson!.worldId));

  String get _locale {
    final l = _lesson?.ttsLocale ?? '';
    if (l.isNotEmpty) return l;
    return _world?.ttsLocale ?? 'en-US';
  }

  void _narrate() {
    if (_steps.isEmpty) return;
    final step = _steps[_index];
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted || _completion != null || _steps[_index].id != step.id) return;
      ref.read(audioServiceProvider).speak(audioUrl: step.audioUrl, text: step.speakText, locale: _locale);
    });
  }

  // -------------------------------------------------------------- events

  void _onAnswer(bool correct) {
    final config = ref.read(appConfigValueProvider);
    final audio = ref.read(audioServiceProvider);
    if (correct) {
      audio.effect(config.correctSoundUrl);
      _showFeedback(config.praiseMessages[_rand.nextInt(config.praiseMessages.length)], good: true);
    } else {
      _mistakes.add(_index);
      audio.effect(config.wrongSoundUrl);
      _showFeedback(config.retryMessages[_rand.nextInt(config.retryMessages.length)], good: false);
    }
  }

  void _onSolved() {
    if (!mounted) return;
    setState(() => _solved.add(_index));
  }

  void _showFeedback(String text, {required bool good}) {
    _feedbackTimer?.cancel();
    setState(() {
      _feedback = text;
      _feedbackGood = good;
    });
    _feedbackTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _feedback = null);
    });
  }

  Future<void> _next() async {
    if (_index < _steps.length - 1) {
      setState(() {
        _index++;
        _feedback = null;
      });
      _saveStep();
      _narrate();
    } else {
      await _finish();
    }
  }

  void _saveStep() {
    final session = ref.read(sessionControllerProvider);
    final lesson = _lesson;
    if (session.uid == null || session.activeChildId == null || lesson == null) return;
    ref
        .read(progressRepositoryProvider)
        .saveStep(
          uid: session.uid!,
          childId: session.activeChildId!,
          lesson: lesson,
          currentStep: _index,
          totalSteps: _steps.length,
        );
  }

  int get _correctFirstTry => _interactive.where((i) => !_mistakes.contains(i)).length;

  Future<void> _finish() async {
    final session = ref.read(sessionControllerProvider);
    final child = session.activeChild;
    final lesson = _lesson;
    if (session.uid == null || child == null || lesson == null) return;

    setState(() => _finishing = true);
    final total = _interactive.length;
    final score = total == 0 ? 100 : (_correctFirstTry * 100 / total).round();
    final stars = score >= 90 ? 3 : (score >= 60 ? 2 : 1);

    var badges = ref.read(badgesProvider).value;
    if (badges == null) {
      try {
        badges = await ref.read(contentRepositoryProvider).getBadges();
      } catch (_) {
        badges = const [];
      }
    }

    try {
      final completion = await ref
          .read(progressRepositoryProvider)
          .completeLesson(
            uid: session.uid!,
            child: child,
            lesson: lesson,
            stars: stars,
            score: score,
            totalSteps: _steps.length,
            progress: ref.read(progressMapProvider).value ?? const {},
            earnedBadgeIds: (ref.read(earnedBadgesProvider).value ?? const {}).keys.toSet(),
            badges: badges,
          );
      ref.read(audioServiceProvider).effect(ref.read(appConfigValueProvider).completeSoundUrl);
      if (!mounted) return;
      setState(() {
        _completion = completion;
        _finishing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _finishing = false);
      showSnack(context, friendlyError(e));
    }
  }

  LessonModel? _nextLesson() {
    final lesson = _lesson;
    if (lesson == null) return null;
    final list = ref.read(lessonsForWorldProvider(lesson.worldId)).value ?? const <LessonModel>[];
    final i = list.indexWhere((l) => l.id == lesson.id);
    if (i < 0 || i + 1 >= list.length) return null;
    return list[i + 1];
  }

  Future<void> _unlock() async {
    if (!await showParentGate(context) || !mounted) return;
    await context.push(RouteNames.paywall);
    if (mounted && ref.read(isPremiumProvider)) _load();
  }

  // ----------------------------------------------------------------- UI

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    // Keep these alive while playing: colour/locale, and the data the
    // completion step computes stars, streaks and badges from.
    ref.watch(worldsProvider);
    ref.watch(progressMapProvider);
    ref.watch(earnedBadgesProvider);
    ref.watch(badgesProvider);
    final world = _lesson == null ? null : ref.watch(worldByIdProvider(_lesson!.worldId));
    final lesson = _lesson;
    if (lesson != null) ref.watch(lessonsForWorldProvider(lesson.worldId));

    final accent = world?.color ?? AppColors.primary;

    if (_completion != null) {
      final next = _nextLesson();
      return Scaffold(
        body: LessonCompleteView(
          completion: _completion!,
          correct: _correctFirstTry,
          total: _interactive.length,
          onHome: () => context.go(RouteNames.home),
          onNext: next == null
              ? null
              : () {
                  if (next.isPremium && !ref.read(isPremiumProvider)) {
                    _unlockNext(next);
                  } else {
                    context.pushReplacement(RouteNames.lesson(next.id));
                  }
                },
        ),
      );
    }

    Widget body;
    if (_loading) {
      body = const LoadingView();
    } else if (_locked) {
      body = MessageView(
        emoji: '🔒',
        title: t('lesson.lockedTitle', 'This lesson is part of Mindo Plus'),
        subtitle: t('lesson.lockedSubtitle', 'Ask a grown-up to unlock all worlds.'),
        actionLabel: t('lesson.unlock', 'Unlock'),
        onAction: _unlock,
      );
    } else if (_error != null) {
      body = MessageView(
        emoji: '😕',
        title: t('lesson.error', 'We couldn\'t open this lesson'),
        subtitle: friendlyError(_error!),
        actionLabel: t('common.retry', 'Try again'),
        onAction: _load,
      );
    } else if (_steps.isEmpty) {
      body = MessageView(emoji: '🧩', title: t('lesson.empty', 'This lesson is being prepared.'));
    } else {
      body = _buildPlayer(t, world, accent);
    }

    final step = _steps.isEmpty || _loading ? null : _steps[_index];
    final bg = step?.background ?? accent.tint(0.86);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [bg, Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _Header(
                title: world?.title ?? lesson?.title ?? '',
                current: _steps.isEmpty ? 0 : _index + 1,
                total: _steps.length,
                showProgress: !_loading && !_locked && _steps.isNotEmpty,
                onBack: () => context.pop(),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _unlockNext(LessonModel next) async {
    if (!await showParentGate(context) || !mounted) return;
    await context.push(RouteNames.paywall);
    if (mounted && ref.read(isPremiumProvider)) {
      context.pushReplacement(RouteNames.lesson(next.id));
    }
  }

  Widget _buildPlayer(AppTexts t, WorldModel? world, Color accent) {
    final step = _steps[_index];
    final events = StepEvents(onAnswer: _onAnswer, onSolved: _onSolved, locale: _locale);
    final canNext = _solved.contains(_index) && !_finishing;
    final isLast = _index == _steps.length - 1;

    final Widget view = switch (step.type) {
      StepType.story => StoryStepView(step: step, events: events),
      StepType.quiz => QuizStepView(step: step, events: events),
      StepType.count => CountStepView(step: step, events: events),
      StepType.letter => LetterStepView(step: step, events: events),
      StepType.trace => TraceStepView(step: step, events: events),
      StepType.match => MatchStepView(step: step, events: events),
      StepType.memory => MemoryStepView(step: step, events: events),
      StepType.unknown => const SizedBox.shrink(),
    };

    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: (world?.isRtl ?? false) ? TextDirection.rtl : TextDirection.ltr,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              child: KeyedSubtree(key: ValueKey('${step.id}-$_index'), child: view),
            ),
          ),
        ),
        Container(
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(20, 6, 20, 16 + MediaQuery.of(context).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _feedback == null
                    ? const SizedBox(height: 34)
                    : Container(
                        key: ValueKey(_feedback),
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: _feedbackGood ? AppColors.successSoft : AppColors.errorSoft,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _feedback!,
                          style: AppTheme.body(
                            14,
                            color: _feedbackGood ? const Color(0xFF1E8A52) : const Color(0xFFC0392B),
                            weight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: isLast ? t('lesson.finish', 'Finish') : t('lesson.next', 'Next'),
                loading: _finishing,
                onPressed: canNext ? _next : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.current,
    required this.total,
    required this.showProgress,
    required this.onBack,
  });

  final String title;
  final int current;
  final int total;
  final bool showProgress;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              CircleIconButton(icon: Icons.arrow_back_ios_new_rounded, size: 42, onPressed: onBack),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.heading(20),
                ),
              ),
              const SizedBox(width: 42),
            ],
          ),
          if (showProgress) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SizedBox(width: 42),
                Expanded(
                  child: SegmentedProgress(total: total, current: current),
                ),
                SizedBox(
                  width: 42,
                  child: Text(
                    '$current/$total',
                    textAlign: TextAlign.right,
                    style: AppTheme.body(13, color: AppColors.navy, weight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
