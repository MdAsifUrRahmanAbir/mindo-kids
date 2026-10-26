import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/features/subscription/data/services/purchase_service.dart';

class MainShellScreen extends ConsumerStatefulWidget {
  const MainShellScreen({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends ConsumerState<MainShellScreen> {
  @override
  void initState() {
    super.initState();
    // Listen for store purchases (incl. ones finished while the app was
    // closed) as soon as a parent is signed in.
    ref.read(purchaseServiceProvider).start();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final shell = widget.navigationShell;
    final items = [
      (Icons.home_rounded, Icons.home_outlined, t('nav.home', 'Home')),
      (Icons.explore_rounded, Icons.explore_outlined, t('nav.explore', 'Explore')),
      (Icons.emoji_events_rounded, Icons.emoji_events_outlined, t('nav.rewards', 'Rewards')),
      (Icons.person_rounded, Icons.person_outline_rounded, t('nav.profile', 'Profile')),
    ];

    return Scaffold(
      body: shell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5B45C9).withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () => shell.goBranch(i, initialLocation: i == shell.currentIndex),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            i == shell.currentIndex ? items[i].$1 : items[i].$2,
                            color: i == shell.currentIndex ? AppColors.primary : AppColors.textMuted,
                            size: 27,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            items[i].$3,
                            style: AppTheme.body(
                              12,
                              color: i == shell.currentIndex ? AppColors.primary : AppColors.textMuted,
                              weight: i == shell.currentIndex ? FontWeight.w800 : FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
