import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/screen_time/screen_time_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/parent_gate.dart';

/// Wraps the whole app; covers it with a calm "break time" screen once the
/// child's daily limit is used up.
class ScreenTimeGuard extends ConsumerStatefulWidget {
  const ScreenTimeGuard({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<ScreenTimeGuard> createState() => _ScreenTimeGuardState();
}

class _ScreenTimeGuardState extends ConsumerState<ScreenTimeGuard> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(screenTimeControllerProvider.notifier).setForeground(state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) {
    final locked = ref.watch(screenTimeControllerProvider.select((s) => s.locked));
    return Stack(
      children: [
        widget.child,
        if (locked) const Positioned.fill(child: _BreakTimeView()),
      ],
    );
  }
}

class _BreakTimeView extends ConsumerStatefulWidget {
  const _BreakTimeView();

  @override
  ConsumerState<_BreakTimeView> createState() => _BreakTimeViewState();
}

class _BreakTimeViewState extends ConsumerState<_BreakTimeView> {
  bool _showGate = false;

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: _showGate
                ? SoftCard(
                    padding: const EdgeInsets.all(20),
                    child: ParentGatePanel(
                      onResult: (passed) async {
                        if (passed) {
                          await ref.read(screenTimeControllerProvider.notifier).grantExtraTime();
                        }
                        if (mounted) setState(() => _showGate = false);
                      },
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 84)),
                      const SizedBox(height: 16),
                      Text(
                        t('breakTime.title', 'Time for a break!'),
                        textAlign: TextAlign.center,
                        style: AppTheme.heading(30, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t(
                          'breakTime.subtitle',
                          'You learned so much today. Let\'s rest our eyes and play again tomorrow!',
                        ),
                        textAlign: TextAlign.center,
                        style: AppTheme.body(16, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 32),
                      PrimaryButton.navy(
                        label: t('breakTime.parentButton', 'Grown-up: a little more time'),
                        trailingIcon: Icons.lock_outline_rounded,
                        onPressed: () => setState(() => _showGate = true),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
