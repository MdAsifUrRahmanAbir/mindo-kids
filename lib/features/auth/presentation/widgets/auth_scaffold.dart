import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Shared layout for the parent account screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.title, required this.subtitle, required this.children});

  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(RouteNames.onboarding);
                    }
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(child: Image.asset('assets/logo/mindo_mark.png', height: 120)),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTheme.heading(28, weight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTheme.body(15, color: AppColors.textMuted),
              ),
              const SizedBox(height: 26),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.autofillHints,
    this.prefixText,
    this.hintText,
  });

  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final String? prefixText;
  final String? hintText;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: widget.controller,
        obscureText: _hidden,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onSubmitted,
        validator: widget.validator,
        autofillHints: widget.autofillHints,
        style: AppTheme.body(16, color: AppColors.navy),
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          prefixText: widget.prefixText == null ? null : '${widget.prefixText} ',
          prefixStyle: AppTheme.body(16, color: AppColors.navy, weight: FontWeight.w700),
          prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: AppColors.textMuted),
          suffixIcon: widget.obscure
              ? IconButton(
                  icon: Icon(_hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  color: AppColors.textMuted,
                  onPressed: () => setState(() => _hidden = !_hidden),
                )
              : null,
        ),
      ),
    );
  }
}

class FormMessage extends StatelessWidget {
  const FormMessage({super.key, this.error, this.info});
  final String? error;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final text = error ?? info;
    if (text == null) return const SizedBox.shrink();
    final isError = error != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorSoft : AppColors.successSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(text, style: AppTheme.body(14, color: isError ? const Color(0xFFC0392B) : const Color(0xFF1E8A52))),
    );
  }
}

String? validateEmail(String? v) {
  final value = v?.trim() ?? '';
  if (value.isEmpty) return 'Please enter your e-mail';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) return 'Please enter a valid e-mail';
  return null;
}

/// Digits only, 6–14 long. When the country has no dial code the number
/// must include it ("+…").
String? validatePhone(String? v, {required bool needsCountryCode}) {
  final raw = v?.trim() ?? '';
  if (raw.isEmpty) return 'Please enter your phone number';
  if (needsCountryCode && !raw.startsWith('+')) return 'Include your country code, e.g. +44…';
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 6 || digits.length > 14) return 'Please enter a valid phone number';
  return null;
}

/// International format: dial code + national number without leading 0s.
String toInternationalPhone(String input, String dialCode) {
  final raw = input.trim();
  final digits = raw.replaceAll(RegExp(r'\D'), '');
  if (dialCode.isEmpty || raw.startsWith('+')) return '+$digits';
  final dialDigits = dialCode.replaceAll(RegExp(r'\D'), '');
  var national = digits;
  // The parent may type the code anyway (8801…); don't double it.
  if (national.startsWith(dialDigits) && national.length > dialDigits.length + 6) {
    national = national.substring(dialDigits.length);
  }
  national = national.replaceFirst(RegExp(r'^0+'), '');
  return '+$dialDigits$national';
}

String? validatePassword(String? v) {
  if ((v ?? '').length < 6) return 'At least 6 characters';
  return null;
}
