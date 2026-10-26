import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/children/presentation/widgets/avatar_picker.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/routes/route_names.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key, required this.child});
  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final hasNews = (ref.watch(announcementsProvider).value ?? const []).isNotEmpty;

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.push(RouteNames.childSelect),
          child: ChildAvatar(media: child.avatar, size: 56),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('home.greeting', 'Hi, {name}! 👋', {'name': child.name}),
                style: AppTheme.heading(24, weight: FontWeight.w700),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                t('home.subtitle', 'Ready to learn something new?'),
                style: AppTheme.body(14, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        CircleIconButton(
          icon: Icons.notifications_none_rounded,
          color: Colors.transparent,
          size: 48,
          badge: hasNews,
          onPressed: () => context.push(RouteNames.announcements),
        ),
      ],
    );
  }
}
