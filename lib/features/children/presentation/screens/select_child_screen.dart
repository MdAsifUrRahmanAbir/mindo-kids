import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/parent_gate.dart';
import 'package:mindo_kids/features/children/presentation/widgets/avatar_picker.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// "Who's learning today?" — switch between child profiles.
class SelectChildScreen extends ConsumerWidget {
  const SelectChildScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final session = ref.watch(sessionControllerProvider);

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: context.canPop()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t('selectChild.title', 'Who\'s learning today?'),
                textAlign: TextAlign.center,
                style: AppTheme.heading(28, weight: FontWeight.w700),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: 0.9,
                  children: [
                    for (final c in session.children)
                      SoftCard(
                        onTap: () async {
                          await ref.read(sessionControllerProvider.notifier).selectChild(c.id);
                          if (context.mounted) context.go(RouteNames.home);
                        },
                        border: c.id == session.activeChildId ? Border.all(color: AppColors.primary, width: 2) : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ChildAvatar(media: c.avatar, size: 84),
                            const SizedBox(height: 12),
                            Text(c.name, style: AppTheme.heading(20), overflow: TextOverflow.ellipsis),
                            if (c.ageBand.isNotEmpty)
                              Text(c.ageBand, style: AppTheme.body(13, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                    SoftCard(
                      color: AppColors.surfaceSoft,
                      onTap: () async {
                        if (await showParentGate(context) && context.mounted) {
                          context.push(RouteNames.childNew);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_circle_rounded, size: 56, color: AppColors.primary),
                          const SizedBox(height: 10),
                          Text(t('selectChild.add', 'Add child'), style: AppTheme.heading(18)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
