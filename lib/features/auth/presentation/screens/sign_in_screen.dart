import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mindo_kids/features/auth/presentation/widgets/auth_scaffold.dart';
import 'package:mindo_kids/routes/route_names.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final state = ref.watch(authControllerProvider);

    return AuthScaffold(
      title: t('signIn.title', 'Welcome back!'),
      subtitle: t('signIn.subtitle', 'Grown-ups, sign in to continue the adventure.'),
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              children: [
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
                  autofillHints: const [AutofillHints.password],
                ),
              ],
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(RouteNames.forgotPassword),
            child: Text(t('signIn.forgot', 'Forgot password?')),
          ),
        ),
        const SizedBox(height: 6),
        FormMessage(error: state.errorMessage),
        PrimaryButton.navy(label: t('signIn.button', 'Sign in'), loading: state.isLoading, onPressed: _submit),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(t('signIn.noAccount', 'New here?'), style: AppTheme.body(14, color: AppColors.textMuted)),
            TextButton(
              onPressed: () => context.pushReplacement(RouteNames.signUp),
              child: Text(t('signIn.createAccount', 'Create an account')),
            ),
          ],
        ),
      ],
    );
  }
}
