import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/features/content/providers/content_providers.dart';

/// UI labels with Firestore overrides.
///
/// Every label in the app is read through `t('key', 'Fallback')`. If the
/// admin panel sets `config/strings.{key}` the Firestore value wins, so any
/// wording can be changed without an app update. Keys used by the app are
/// listed in docs/FIRESTORE_SCHEMA.md.
final textsProvider = Provider<AppTexts>((ref) => AppTexts(ref.watch(appStringsProvider).value ?? const {}));

class AppTexts {
  const AppTexts(this._values);
  final Map<String, String> _values;

  String call(String key, String fallback, [Map<String, Object?> args = const {}]) {
    final v = _values[key];
    var out = (v != null && v.trim().isNotEmpty) ? v : fallback;
    args.forEach((k, value) => out = out.replaceAll('{$k}', '${value ?? ''}'));
    return out;
  }
}
