import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/auth/data/repositories/auth_repository.dart';
import 'package:mindo_kids/features/children/presentation/widgets/avatar_picker.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Grown-ups only (reached through the parent gate).
class ParentZoneScreen extends ConsumerWidget {
  const ParentZoneScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final session = ref.watch(sessionControllerProvider);
    final sub = ref.watch(subscriptionProvider).value;
    final isPremium = ref.watch(isPremiumProvider);
    final pages = (ref.watch(pagesProvider).value ?? const []).where((p) => p.showInParentZone).toList();
    final config = ref.watch(appConfigValueProvider);
    final user = session.user;
    final expires = sub?.expiresAt;
    final subLine = (isPremium && expires != null)
        ? t('parent.renews', '{verb} {date}', {
            'verb': (sub?.autoRenewing ?? false) ? 'Renews on' : 'Ends on',
            'date': DateFormat.yMMMd().format(expires),
          })
        : t('parent.upgrade', 'Unlock every world, story and game');

    return Scaffold(
      appBar: AppBar(title: Text(t('parent.title', 'Parent Zone'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ---- Account ----
            SoftCard(
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(Icons.family_restroom_rounded, color: AppColors.primary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.isGuest
                              ? t('parent.guest', 'Guest account')
                              : (user?.displayName?.isNotEmpty ?? false)
                              ? user!.displayName!
                              : t('parent.account', 'Parent account'),
                          style: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w800),
                        ),
                        Text(
                          session.isGuest
                              ? t('parent.guestHint', 'Create an account to keep progress safe')
                              : (user?.email ?? ''),
                          style: AppTheme.body(13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (session.isGuest)
                    TextButton(
                      onPressed: () => context.push(RouteNames.signUp),
                      child: Text(t('parent.createAccount', 'Create')),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Subscription ----
            SoftCard(
              color: isPremium ? const Color(0xFFFFF4D6) : AppColors.surface,
              onTap: () => context.push(RouteNames.paywall),
              child: Row(
                children: [
                  Text(isPremium ? '👑' : '🚀', style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPremium ? t('parent.plusActive', 'Mindo Plus is active') : t('parent.free', 'Free plan'),
                          style: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w800),
                        ),
                        Text(subLine, style: AppTheme.body(13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Children ----
            SectionHeader(title: t('parent.children', 'Children')),
            const SizedBox(height: 8),
            for (final c in session.children)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SoftCard(
                  padding: const EdgeInsets.all(12),
                  onTap: () => context.push(RouteNames.parentChild(c.id)),
                  child: Row(
                    children: [
                      ChildAvatar(media: c.avatar, size: 50),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.name,
                              style: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w800),
                            ),
                            Text(
                              t('parent.childStats', '{lessons} lessons · {stars} stars', {
                                'lessons': c.lessonsCompleted,
                                'stars': c.stars,
                              }),
                              style: AppTheme.body(13, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            TextButton.icon(
              onPressed: () => context.push(RouteNames.childNew),
              icon: const Icon(Icons.add_rounded),
              label: Text(t('parent.addChild', 'Add a child')),
            ),
            const SizedBox(height: 16),

            // ---- Pages (privacy, terms, help …) ----
            if (pages.isNotEmpty || config.supportEmail.isNotEmpty) ...[
              SectionHeader(title: t('parent.info', 'Help & information')),
              const SizedBox(height: 8),
              SoftCard(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Column(
                  children: [
                    for (final p in pages)
                      ListTile(
                        title: Text(
                          p.title,
                          style: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w700),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push(RouteNames.page(p.id)),
                      ),
                    if (config.supportEmail.isNotEmpty)
                      ListTile(
                        leading: const Icon(Icons.mail_outline_rounded, color: AppColors.primary),
                        title: Text(
                          t('parent.contact', 'Contact support'),
                          style: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w700),
                        ),
                        subtitle: Text(config.supportEmail),
                        onTap: () => launchUrl(
                          Uri(
                            scheme: 'mailto',
                            path: config.supportEmail,
                            query: 'subject=${Uri.encodeComponent('${config.appName} support')}',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ---- Account actions ----
            PrimaryButton.navy(
              label: t('parent.signOut', 'Sign out'),
              trailingIcon: Icons.logout_rounded,
              onPressed: () => _signOut(context, ref),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _deleteAccount(context, ref),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
              child: Text(t('parent.delete', 'Delete account')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final isGuest = ref.read(sessionControllerProvider).isGuest;
    if (isGuest) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign out of guest account?'),
          content: const Text(
            'Guest progress cannot be recovered after signing out. Create an account first to keep it.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sign out')),
          ],
        ),
      );
      if (ok != true) return;
    }
    await ref.read(sessionControllerProvider.notifier).signOut();
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text(
          'This permanently deletes your account, all child profiles and their progress. '
          'Store subscriptions must be cancelled separately in Google Play / App Store.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(authRepositoryProvider).deleteAccount();
    } catch (e) {
      if (context.mounted) showSnack(context, friendlyError(e));
    }
  }
}
