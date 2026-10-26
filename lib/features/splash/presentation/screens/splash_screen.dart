import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';

/// Shown while Firebase Auth restores the session and the child profiles
/// load. The router redirect moves on automatically.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Warm up config + onboarding while auth restores.
    ref.watch(appConfigProvider);
    ref.watch(onboardingSlidesProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/mindo_logo.png', width: 260),
              const SizedBox(height: 28),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
