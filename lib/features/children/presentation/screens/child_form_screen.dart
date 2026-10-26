import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/constants/app_colors.dart';
import 'package:mindo_kids/core/content/app_texts.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/theme/app_theme.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/features/children/presentation/controllers/child_form_controller.dart';
import 'package:mindo_kids/features/children/presentation/widgets/avatar_picker.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Create (childId == null) or edit a child profile.
class ChildFormScreen extends ConsumerStatefulWidget {
  const ChildFormScreen({super.key, this.childId});
  final String? childId;

  @override
  ConsumerState<ChildFormScreen> createState() => _ChildFormScreenState();
}

class _ChildFormScreenState extends ConsumerState<ChildFormScreen> {
  final _name = TextEditingController();
  String? _avatarId;
  String? _ageBand;

  bool get _isEdit => widget.childId != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final child = ref.read(sessionControllerProvider).children.findOrNull((c) => c.id == widget.childId);
      if (child != null) {
        _name.text = child.name;
        _avatarId = child.avatarId.isEmpty ? null : child.avatarId;
        _ageBand = child.ageBand.isEmpty ? null : child.ageBand;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(List<AvatarModel> avatars) async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      showSnack(context, 'Please type a name.');
      return;
    }
    final ageBands = ref.read(appConfigValueProvider).ageBands;
    final ageBand = _ageBand ?? (ageBands.isEmpty ? '' : ageBands.first);
    final avatar = avatars.findOrNull((a) => a.id == _avatarId) ?? avatars.firstOrNullX;
    final controller = ref.read(childFormControllerProvider.notifier);

    if (_isEdit) {
      final ok = await controller.update(widget.childId!, name: name, ageBand: ageBand, avatar: avatar);
      if (ok && mounted) context.pop();
    } else {
      final id = await controller.create(name: name, ageBand: ageBand, avatar: avatar);
      if (id != null && mounted) context.go(RouteNames.home);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete profile?'),
        content: const Text('This removes the child\'s progress and badges. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await ref.read(childFormControllerProvider.notifier).delete(widget.childId!);
    if (ok && mounted) context.go(RouteNames.parentZone);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(textsProvider);
    final state = ref.watch(childFormControllerProvider);
    final avatarsAsync = ref.watch(avatarsProvider);
    final avatars = avatarsAsync.value ?? const <AvatarModel>[];
    final ageBands = ref.watch(appConfigValueProvider).ageBands;
    final canGoBack = context.canPop();

    _avatarId ??= avatars.firstOrNullX?.id;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: canGoBack,
        title: Text(_isEdit ? t('child.editTitle', 'Edit profile') : t('child.newTitle', 'Who is learning?')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            if (!_isEdit)
              Text(
                t(
                  'child.newSubtitle',
                  'Create a profile for your little learner. We only need a first name or nickname.',
                ),
                style: AppTheme.body(15, color: AppColors.textMuted),
              ),
            const SizedBox(height: 20),
            Text(t('child.pickAvatar', 'Pick an avatar'), style: AppTheme.heading(18)),
            const SizedBox(height: 12),
            if (avatarsAsync.isLoading && avatars.isEmpty)
              const SizedBox(height: 70, child: LoadingView())
            else
              AvatarPicker(
                avatars: avatars,
                selectedId: _avatarId,
                onSelected: (a) => setState(() => _avatarId = a.id),
              ),
            const SizedBox(height: 24),
            Text(t('child.name', 'Name or nickname'), style: AppTheme.heading(18)),
            const SizedBox(height: 10),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              maxLength: 20,
              style: AppTheme.body(17, color: AppColors.navy),
              decoration: InputDecoration(hintText: t('child.nameHint', 'e.g. Amara'), counterText: ''),
            ),
            const SizedBox(height: 20),
            Text(t('child.age', 'Age'), style: AppTheme.heading(18)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final band in ageBands)
                  ChoiceChip(
                    label: Text(band),
                    selected: (_ageBand ?? ageBands.first) == band,
                    onSelected: (_) => setState(() => _ageBand = band),
                    selectedColor: AppColors.primarySoft,
                    labelStyle: AppTheme.body(15, color: AppColors.navy, weight: FontWeight.w800),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: AppColors.border),
                    backgroundColor: AppColors.surface,
                    showCheckmark: false,
                  ),
              ],
            ),
            const SizedBox(height: 28),
            if (state.errorMessage != null) ...[
              Text(state.errorMessage!, style: AppTheme.body(14, color: AppColors.error)),
              const SizedBox(height: 10),
            ],
            PrimaryButton(
              label: _isEdit ? t('child.save', 'Save') : t('child.create', 'Start learning'),
              loading: state.isSaving,
              onPressed: () => _save(avatars),
            ),
            if (_isEdit) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: state.isSaving ? null : _delete,
                icon: const Icon(Icons.delete_outline_rounded),
                label: Text(t('child.delete', 'Delete this profile')),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
