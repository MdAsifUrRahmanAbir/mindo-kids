import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/features/children/data/repositories/children_repository.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';

@immutable
class ChildFormState {
  final bool isSaving;
  final String? errorMessage;
  const ChildFormState({this.isSaving = false, this.errorMessage});
}

final childFormControllerProvider = NotifierProvider.autoDispose<ChildFormController, ChildFormState>(
  ChildFormController.new,
);

class ChildFormController extends Notifier<ChildFormState> {
  @override
  ChildFormState build() => const ChildFormState();

  /// Creates a child, makes it the active profile and returns its id.
  Future<String?> create({required String name, required String ageBand, AvatarModel? avatar}) async {
    final uid = ref.read(sessionControllerProvider).uid;
    if (uid == null) return null;
    state = const ChildFormState(isSaving: true);
    try {
      final id = await ref
          .read(childrenRepositoryProvider)
          .createChild(
            uid,
            name: name,
            ageBand: ageBand,
            avatar: avatar,
            dailyLimitMinutes: ref.read(appConfigValueProvider).defaultDailyLimitMinutes,
          );
      await ref.read(sessionControllerProvider.notifier).selectChild(id);
      if (ref.mounted) state = const ChildFormState();
      return id;
    } catch (e) {
      if (ref.mounted) state = ChildFormState(errorMessage: friendlyError(e));
      return null;
    }
  }

  Future<bool> update(String childId, {required String name, required String ageBand, AvatarModel? avatar}) async {
    final uid = ref.read(sessionControllerProvider).uid;
    if (uid == null) return false;
    state = const ChildFormState(isSaving: true);
    try {
      await ref
          .read(childrenRepositoryProvider)
          .updateChild(uid, childId, name: name, ageBand: ageBand, avatar: avatar);
      if (ref.mounted) state = const ChildFormState();
      return true;
    } catch (e) {
      if (ref.mounted) state = ChildFormState(errorMessage: friendlyError(e));
      return false;
    }
  }

  Future<bool> delete(String childId) async {
    final uid = ref.read(sessionControllerProvider).uid;
    if (uid == null) return false;
    state = const ChildFormState(isSaving: true);
    try {
      await ref.read(childrenRepositoryProvider).deleteChild(uid, childId);
      if (ref.mounted) state = const ChildFormState();
      return true;
    } catch (e) {
      if (ref.mounted) state = ChildFormState(errorMessage: friendlyError(e));
      return false;
    }
  }
}
