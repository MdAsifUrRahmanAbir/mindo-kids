import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/app_config_model.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/features/subscription/presentation/controllers/paywall_controller.dart';
import 'package:mindo_kids/features/subscription/presentation/widgets/plan_card.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Subscription screen (always opened behind the parent gate).
/// Copy comes from config/paywall, plans from plans/{id}, prices from the
/// store, and the entitlement from subscriptions/{uid}.
class PaywallScreen extends ConsumerWidget {
  const PaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final cfg = ref.watch(paywallConfigProvider).value ?? const PaywallConfig();
    final plans = ref.watch(plansProvider).value ?? const <PlanModel>[];
    final state = ref.watch(paywallControllerProvider);
    final controller = ref.read(paywallControllerProvider.notifier);
    final sub = ref.watch(subscriptionProvider).value;
    final isPremium = ref.watch(isPremiumProvider);

    final selected = plans.findOrNull((p) => p.id == state.selectedPlanId) ?? plans.firstOrNullX;

    String priceOf(PlanModel p) => state.products[p.productId]?.price ?? p.priceLabel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => context.pop()),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          children: [
            Center(child: MediaView(cfg.hero, size: 120)),
            const SizedBox(height: 10),
            Text(
              cfg.title,
              textAlign: TextAlign.center,
              style: AppTheme.heading(28, weight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              cfg.subtitle,
              textAlign: TextAlign.center,
              style: AppTheme.body(15, color: AppColors.textMuted),
            ),
            const SizedBox(height: 18),
            if (cfg.benefits.isNotEmpty)
              SoftCard(
                child: Column(
                  children: [
                    for (final b in cfg.benefits)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.successSoft,
                              child: Icon(Icons.check_rounded, size: 16, color: AppColors.success),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                b,
                                style: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            if (isPremium && sub != null) ...[
              SoftCard(
                color: const Color(0xFFFFF4D6),
                child: Column(
                  children: [
                    const Text('👑', style: TextStyle(fontSize: 40)),
                    const SizedBox(height: 6),
                    Text(t('paywall.active', 'You\'re a Mindo Plus member!'), style: AppTheme.heading(20)),
                    if (sub.expiresAt != null)
                      Text(
                        '${sub.autoRenewing ? 'Renews' : 'Ends'} on ${DateFormat.yMMMd().format(sub.expiresAt!)}',
                        style: AppTheme.body(14, color: AppColors.textMuted),
                      ),
                    const SizedBox(height: 12),
                    if (sub.source != 'manual')
                      TextButton(
                        onPressed: () => launchUrl(
                          Uri.parse(
                            Platform.isIOS
                                ? 'https://apps.apple.com/account/subscriptions'
                                : 'https://play.google.com/store/account/subscriptions',
                          ),
                          mode: LaunchMode.externalApplication,
                        ),
                        child: Text(t('paywall.manage', 'Manage subscription')),
                      ),
                  ],
                ),
              ),
            ] else if (state.isLoading) ...[
              const SizedBox(height: 120, child: LoadingView()),
            ] else ...[
              if (plans.isEmpty)
                MessageView(emoji: '🛠️', title: t('paywall.noPlans', 'Plans are not available yet.'))
              else
                for (final p in plans)
                  PlanCard(
                    plan: p,
                    price: priceOf(p),
                    selected: p.id == selected?.id,
                    onTap: () => controller.select(p.id),
                  ),
              if (!state.storeAvailable)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    t('paywall.storeUnavailable', 'The store isn\'t available on this device right now.'),
                    textAlign: TextAlign.center,
                    style: AppTheme.body(13, color: AppColors.error),
                  ),
                ),
              const SizedBox(height: 6),
              PrimaryButton(
                label: cfg.ctaText,
                loading: state.isBusy,
                onPressed: selected == null || !state.storeAvailable ? null : () => controller.buy(selected),
              ),
              const SizedBox(height: 6),
              TextButton(onPressed: state.isBusy ? null : controller.restore, child: Text(cfg.restoreText)),
            ],

            if (state.message != null) ...[
              const SizedBox(height: 8),
              Text(
                state.message!,
                textAlign: TextAlign.center,
                style: AppTheme.body(
                  14,
                  color: state.messageIsError ? AppColors.error : AppColors.success,
                  weight: FontWeight.w800,
                ),
              ),
            ],

            if (cfg.footerNote.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                cfg.footerNote,
                textAlign: TextAlign.center,
                style: AppTheme.body(12, color: AppColors.textMuted, weight: FontWeight.w500),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => context.push(RouteNames.page('terms')),
                  child: Text(t('paywall.terms', 'Terms')),
                ),
                TextButton(
                  onPressed: () => context.push(RouteNames.page('privacy')),
                  child: Text(t('paywall.privacy', 'Privacy')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
