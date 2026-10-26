import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/auth/presentation/controllers/auth_controller.dart';
import 'package:mindo_kids/features/auth/presentation/widgets/auth_scaffold.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    await ref.read(authControllerProvider.notifier).sendReset(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final state = ref.watch(authControllerProvider);
    return AuthScaffold(
      title: t('forgot.title', 'Reset password'),
      subtitle: t('forgot.subtitle', 'We\'ll e-mail you a link to choose a new password.'),
      children: [
        Form(
          key: _formKey,
          child: AuthTextField(
            controller: _email,
            label: t('auth.email', 'E-mail'),
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: validateEmail,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
        ),
        FormMessage(error: state.errorMessage, info: state.infoMessage),
        PrimaryButton.navy(
          label: t('forgot.button', 'Send reset link'),
          loading: state.isLoading,
          onPressed: _submit,
          trailingIcon: Icons.send_rounded,
        ),
      ],
    );
  }
}
