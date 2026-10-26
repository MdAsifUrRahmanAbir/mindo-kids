import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';

/// Renders pages/{id} (privacy, terms, help …). The body is plain text;
/// lines starting with "# " become headings and "- " become bullets, so the
/// admin panel can use a simple textarea.
class ContentPageScreen extends ConsumerWidget {
  const ContentPageScreen({super.key, required this.pageId});
  final String pageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(pageProvider(pageId));
    return Scaffold(
      appBar: AppBar(title: Text(pageAsync.value?.title ?? '')),
      body: SafeArea(
        child: AsyncBody<ContentPage?>(
          value: pageAsync,
          onRetry: () => ref.invalidate(pageProvider(pageId)),
          builder: (page) {
            if (page == null) {
              return const MessageView(emoji: '📄', title: 'This page is not available yet.');
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
              children: [for (final line in page.body.split('\n')) _line(line)],
            );
          },
        ),
      ),
    );
  }

  Widget _line(String raw) {
    final line = raw.trimRight();
    if (line.isEmpty) return const SizedBox(height: 10);
    if (line.startsWith('# ')) {
      return Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 6),
        child: Text(line.substring(2), style: AppTheme.heading(20)),
      );
    }
    if (line.startsWith('- ')) {
      return Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '•  ',
              style: AppTheme.body(15, color: AppColors.primary, weight: FontWeight.w900),
            ),
            Expanded(
              child: Text(line.substring(2), style: AppTheme.body(15, weight: FontWeight.w500)),
            ),
          ],
        ),
      );
    }
    return Text(line, style: AppTheme.body(15, weight: FontWeight.w500, height: 1.55));
  }
}
