import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/firestore_paths.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/data/repositories/content_repository.dart';

/// Region of the phone (e.g. "BD" from bn_BD / en_BD), '' if unknown.
String deviceCountryCode() {
  for (final l in PlatformDispatcher.instance.locales) {
    final c = l.countryCode;
    if (c != null && c.isNotEmpty) return c.toUpperCase();
  }
  return '';
}

/// Used only until config/countries has loaded (or if it's missing), so
/// sign-up never blocks. No `worldIds` → every world is shown.
const kFallbackCountries = <CountryModel>[
  CountryModel(code: 'BD', name: 'Bangladesh', flag: '🇧🇩', dialCode: '+880', order: 1),
  CountryModel(code: 'IN', name: 'India', flag: '🇮🇳', dialCode: '+91', order: 2),
  CountryModel(code: 'PK', name: 'Pakistan', flag: '🇵🇰', dialCode: '+92', order: 3),
  CountryModel(code: 'SA', name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966', order: 4),
  CountryModel(code: 'AE', name: 'United Arab Emirates', flag: '🇦🇪', dialCode: '+971', order: 5),
  CountryModel(code: CountryModel.otherCode, name: 'Other country', flag: '🌍', order: 99),
];

/// Everything in config/countries (inactive ones too — they still map
/// existing families to worlds).
final countriesConfigProvider = StreamProvider<List<CountryModel>>(
  (ref) => ref.watch(contentRepositoryProvider).watchCountries(),
);

/// Countries offered in the sign-up picker.
final countriesProvider = Provider<List<CountryModel>>((ref) {
  final list = (ref.watch(countriesConfigProvider).value ?? const <CountryModel>[]).where((c) => c.isActive).toList();
  return list.isEmpty ? kFallbackCountries : list;
});

/// The family's country: users/{uid}.countryCode, falling back to the
/// phone's region for guests, signed-out users and older accounts.
final userCountryCodeProvider = StreamProvider<String>((ref) {
  final uid = ref.watch(sessionControllerProvider.select((s) => s.uid));
  final device = deviceCountryCode();
  if (uid == null) return Stream.value(device);

  return ref
      .watch(firestoreProvider)
      .doc(FirestorePaths.user(uid))
      .snapshots()
      .map((s) {
        final code = (s.data() ?? const <String, dynamic>{}).str('countryCode').trim().toUpperCase();
        return code.isEmpty ? device : code;
      })
      .transform(StreamTransformer<String, String>.fromHandlers(handleError: (_, _, sink) => sink.add(device)))
      .distinct();
});

/// World ids for the family's country, in display order.
/// `null` = no restriction (show every world in its normal order).
final allowedWorldIdsProvider = FutureProvider<List<String>?>((ref) async {
  try {
    final code = await ref.watch(userCountryCodeProvider.future);
    final countries = await ref.watch(countriesConfigProvider.future);
    final country =
        countries.findOrNull((c) => c.code == code) ?? countries.findOrNull((c) => c.code == CountryModel.otherCode);
    if (country == null || country.worldIds.isEmpty) return null;
    return country.worldIds;
  } catch (_) {
    return null; // never hide content because of a config problem
  }
});

/// Keeps only allowed worlds, ordered as listed for the country.
List<WorldModel> filterWorldsForCountry(List<WorldModel> worlds, List<String>? allowed) {
  if (allowed == null) return worlds;
  final rank = {for (var i = 0; i < allowed.length; i++) allowed[i]: i};
  return worlds.where((w) => rank.containsKey(w.id)).toList()..sort((a, b) => rank[a.id]!.compareTo(rank[b.id]!));
}

bool isWorldAllowed(String worldId, List<String>? allowed) => allowed == null || allowed.contains(worldId);
