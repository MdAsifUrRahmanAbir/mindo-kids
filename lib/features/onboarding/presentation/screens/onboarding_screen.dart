import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/onboarding/presentation/widgets/onboarding_page.dart';
import 'package:mindo_kids/routes/route_names.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final slidesAsync = ref.watch(onboardingSlidesProvider);
    final config = ref.watch(appConfigValueProvider);

    final slides = slidesAsync.value ?? const <OnboardingSlide>[];
    final fallback = OnboardingSlide(id: '_fallback', title: config.appName, subtitle: config.tagline);
    final pages = slides.isEmpty ? [fallback] : slides;
    final isLast = _index >= pages.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF6),
      body: Stack(
        children: [
          // Soft decorative blobs, as in the UI demo.
          Positioned(
            top: -60,
            left: -70,
            child: _Blob(size: 180, color: const Color(0xFFFFE2C2).withValues(alpha: 0.8)),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _Blob(size: 220, color: const Color(0xFFFFE7A6).withValues(alpha: 0.7)),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: isLast
                        ? const SizedBox.shrink()
                        : TextButton(
                            onPressed: () => _controller.animateToPage(
                              pages.length - 1,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeOut,
                            ),
                            style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
                            child: Text(t('onboarding.skip', 'Skip')),
                          ),
                  ),
                ),
                Expanded(
                  child: slidesAsync.isLoading && slides.isEmpty
                      ? const LoadingView()
                      : PageView.builder(
                          controller: _controller,
                          itemCount: pages.length,
                          onPageChanged: (i) => setState(() => _index = i),
                          itemBuilder: (_, i) =>
                              pages[i].id == '_fallback' ? const _LogoPage() : OnboardingPage(slide: pages[i]),
                        ),
                ),
                const SizedBox(height: 8),
                _Dots(count: pages.length, index: _index),
                const SizedBox(height: 22),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: PrimaryButton.navy(
                    label: t('onboarding.cta', 'Let\'s Get Started'),
                    onPressed: () => context.push(RouteNames.signUp),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t('onboarding.haveAccount', 'Already have an account?'),
                      style: AppTheme.body(14, color: AppColors.textMuted),
                    ),
                    TextButton(
                      onPressed: () => context.push(RouteNames.signIn),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      child: Text(
                        t('onboarding.signIn', 'Sign in'),
                        style: AppTheme.body(
                          15,
                          color: AppColors.navy,
                          weight: FontWeight.w800,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoPage extends StatelessWidget {
  const _LogoPage();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(padding: const EdgeInsets.all(32), child: Image.asset('assets/logo/mindo_logo.png')),
  );
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.index});
  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (count <= 1) return const SizedBox(height: 8);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.navy : const Color(0xFFD9D6E8),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
