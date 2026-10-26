import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mindo_kids/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mindo_kids/routes/route_names.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _agreed = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (!_agreed) {
      showSnack(context, 'Please accept the Terms and Privacy Policy.');
      return;
    }
    FocusScope.of(context).unfocus();
    final wasGuest = ref.read(sessionControllerProvider).isGuest;
    final ok = await ref
        .read(authControllerProvider.notifier)
        .signUp(name: _name.text, email: _email.text, password: _password.text);
    if (ok && wasGuest && mounted) {
      showSnack(context, 'Account created — progress saved!');
      context.go(RouteNames.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final state = ref.watch(authControllerProvider);
    final isGuest = ref.watch(sessionControllerProvider.select((s) => s.isGuest));

    return AuthScaffold(
      title: t('signUp.title', 'Create a parent account'),
      subtitle: t('signUp.subtitle', 'Save progress, add your children and unlock every world.'),
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
                AuthTextField(
                  controller: _name,
                  label: t('auth.parentName', 'Your name'),
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v?.trim().isEmpty ?? true) ? 'Please enter your name' : null,
                  autofillHints: const [AutofillHints.name],
                ),
                AuthTextField(
                  controller: _email,
                  label: t('auth.email', 'E-mail'),
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                  autofillHints: const [AutofillHints.email],
                ),
                AuthTextField(
                  controller: _password,
                  label: t('auth.password', 'Password'),
                  icon: Icons.lock_outline_rounded,
                  obscure: true,
                  validator: validatePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  autofillHints: const [AutofillHints.newPassword],
                ),
              ],
            ),
          ),
        ),
        Row(
          children: [
            Checkbox(
              value: _agreed,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _agreed = v ?? false),
            ),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(t('signUp.agree', 'I agree to the '), style: AppTheme.body(13, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.page('terms')),
                    child: Text(
                      t('signUp.terms', 'Terms'),
                      style: AppTheme.body(13, color: AppColors.primary, weight: FontWeight.w800),
                    ),
                  ),
                  Text(' & ', style: AppTheme.body(13, color: AppColors.textMuted)),
                  GestureDetector(
                    onTap: () => context.push(RouteNames.page('privacy')),
                    child: Text(
                      t('signUp.privacy', 'Privacy Policy'),
                      style: AppTheme.body(13, color: AppColors.primary, weight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        FormMessage(error: state.errorMessage),
        PrimaryButton.navy(label: t('signUp.button', 'Create account'), loading: state.isLoading, onPressed: _submit),
        if (!isGuest) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: state.isLoading ? null : () => ref.read(authControllerProvider.notifier).continueAsGuest(),
            child: Text(t('signUp.guest', 'Try it first as a guest')),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                t('onboarding.haveAccount', 'Already have an account?'),
                style: AppTheme.body(14, color: AppColors.textMuted),
              ),
              TextButton(
                onPressed: () => context.pushReplacement(RouteNames.signIn),
                child: Text(t('onboarding.signIn', 'Sign in')),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
