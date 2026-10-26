import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/screen_time/screen_time_guard.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/system/presentation/screens/maintenance_screen.dart';
import 'package:mindo_kids/routes/app_router.dart';

class MindoKidsApp extends ConsumerWidget {
  const MindoKidsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final config = ref.watch(appConfigValueProvider);

    return MaterialApp.router(
      title: config.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      themeMode: ThemeMode.light,
      routerConfig: router,
      builder: (context, child) {
        // Maintenance switch lives in config/app (admin panel).
        if (config.maintenanceMode) {
          return MaintenanceScreen(message: config.maintenanceMessage);
        }
        return ScreenTimeGuard(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
