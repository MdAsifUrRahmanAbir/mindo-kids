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
import 'package:mindo_kids/features/lesson/presentation/lesson_launcher.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Child-facing profile tab. Everything grown-up lives behind the
/// Parent Zone gate.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final session = ref.watch(sessionControllerProvider);
    final child = session.activeChild;
    final isPremium = ref.watch(isPremiumProvider);

    if (child == null) return const Scaffold(body: LoadingView());

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          children: [
            Center(child: ChildAvatar(media: child.avatar, size: 112)),
            const SizedBox(height: 12),
            Text(
              child.name,
              textAlign: TextAlign.center,
              style: AppTheme.heading(28, weight: FontWeight.w700),
            ),
            if (child.ageBand.isNotEmpty)
              Text(
                t('profile.age', 'Age {age}', {'age': child.ageBand}),
                textAlign: TextAlign.center,
                style: AppTheme.body(14, color: AppColors.textMuted),
              ),
            const SizedBox(height: 12),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isPremium ? AppColors.brandYellow : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isPremium ? t('profile.plus', '👑 Mindo Plus') : t('profile.free', 'Free plan'),
                  style: AppTheme.body(13, color: AppColors.navy, weight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 26),
            if (session.isGuest) ...[
              SoftCard(
                color: const Color(0xFFFFF4D6),
                onTap: () async {
                  if (await showParentGate(context) && context.mounted) context.push(RouteNames.signUp);
                },
                child: Row(
                  children: [
                    const Text('💾', style: TextStyle(fontSize: 30)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        t('profile.guestBanner', 'Grown-ups: create an account to keep progress safe.'),
                        style: AppTheme.body(14, color: AppColors.navy, weight: FontWeight.w700),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.navy),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            _MenuTile(
              icon: Icons.switch_account_rounded,
              color: const Color(0xFF6CB8FF),
              title: t('profile.switch', 'Switch learner'),
              onTap: () => context.push(RouteNames.childSelect),
            ),
            if (!isPremium)
              _MenuTile(
                icon: Icons.workspace_premium_rounded,
                color: AppColors.brandYellow,
                title: t('profile.unlock', 'Unlock all worlds'),
                onTap: () => openPaywall(context),
              ),
            _MenuTile(
              icon: Icons.lock_rounded,
              color: AppColors.primary,
              title: t('profile.parentZone', 'Parent Zone'),
              subtitle: t('profile.parentZoneHint', 'Progress, settings & subscription'),
              onTap: () async {
                if (await showParentGate(context) && context.mounted) context.push(RouteNames.parentZone);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.color, required this.title, required this.onTap, this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w800),
                  ),
                  if (subtitle != null) Text(subtitle!, style: AppTheme.body(12.5, color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
