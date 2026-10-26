import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/core/widgets/media_view.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';

/// News from the Mindo team (announcements collection).
class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(textsProvider);
    final async = ref.watch(announcementsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(t('news.title', 'What\'s new'))),
      body: SafeArea(
        child: AsyncBody<List<Announcement>>(
          value: async,
          onRetry: () => ref.invalidate(announcementsProvider),
          builder: (items) {
            if (items.isEmpty) {
              return MessageView(emoji: '📭', title: t('news.empty', 'No news yet'));
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = items[i];
                return SoftCard(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!a.media.isEmpty) ...[
                        MediaView(a.media, size: 56, borderRadius: 14, fit: BoxFit.cover),
                        const SizedBox(width: 14),
                      ],
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.title,
                              style: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w800),
                            ),
                            if (a.createdAt != null)
                              Text(
                                DateFormat.yMMMd().format(a.createdAt!),
                                style: AppTheme.body(12, color: AppColors.textMuted),
                              ),
                            const SizedBox(height: 6),
                            Text(a.body, style: AppTheme.body(14, weight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
