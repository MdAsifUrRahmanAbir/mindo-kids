import 'package:flutter/material.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, this.message = ''});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🛠️', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 16),
                Text('We\'ll be right back!', textAlign: TextAlign.center, style: AppTheme.heading(26)),
                const SizedBox(height: 10),
                Text(
                  message.isNotEmpty
                      ? message
                      : 'Mindo Kids is getting new learning adventures ready. Please check back soon.',
                  textAlign: TextAlign.center,
                  style: AppTheme.body(15, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
