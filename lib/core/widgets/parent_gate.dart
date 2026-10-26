import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';

/// "Ask a grown-up" check placed in front of purchases, settings,
/// external links and account actions (concept doc §12).
Future<bool> showParentGate(BuildContext context) async {
  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.of(ctx).padding.bottom),
      child: ParentGatePanel(onResult: (passed) => Navigator.of(ctx).pop(passed)),
    ),
  );
  return ok ?? false;
}

class ParentGatePanel extends StatefulWidget {
  const ParentGatePanel({super.key, required this.onResult, this.showCancel = true});

  final ValueChanged<bool> onResult;
  final bool showCancel;

  @override
  State<ParentGatePanel> createState() => _ParentGatePanelState();
}

class _ParentGatePanelState extends State<ParentGatePanel> {
  final _rand = Random();
  late int _a;
  late int _b;
  late List<int> _choices;
  bool _wrong = false;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    _a = 3 + _rand.nextInt(7);
    _b = 3 + _rand.nextInt(7);
    final answer = _a * _b;
    final set = <int>{answer};
    while (set.length < 4) {
      final delta = (_rand.nextInt(9) + 1) * (_rand.nextBool() ? 1 : -1);
      final v = answer + delta;
      if (v > 0) set.add(v);
    }
    _choices = set.toList()..shuffle(_rand);
  }

  void _pick(int v) {
    if (v == _a * _b) {
      widget.onResult(true);
    } else {
      setState(() {
        _wrong = true;
        _newQuestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 5,
          decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(height: 18),
        const Text('🔒', style: TextStyle(fontSize: 40)),
        const SizedBox(height: 8),
        Text('Grown-ups only', style: AppTheme.heading(22)),
        const SizedBox(height: 6),
        Text('To continue, answer this question.', style: AppTheme.body(14, color: AppColors.textMuted)),
        const SizedBox(height: 18),
        Text('$_a × $_b = ?', style: AppTheme.heading(34, color: AppColors.primary)),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.6,
          children: [
            for (final c in _choices)
              Material(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => _pick(c),
                  child: Center(child: Text('$c', style: AppTheme.heading(22))),
                ),
              ),
          ],
        ),
        if (_wrong) ...[
          const SizedBox(height: 12),
          Text('Not quite — here is a new one.', style: AppTheme.body(13, color: AppColors.error)),
        ],
        if (widget.showCancel) ...[
          const SizedBox(height: 8),
          TextButton(onPressed: () => widget.onResult(false), child: const Text('Cancel')),
        ],
      ],
    );
  }
}
