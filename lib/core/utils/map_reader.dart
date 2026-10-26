import 'package:cloud_firestore/cloud_firestore.dart';

/// Tolerant readers for Firestore maps. Admin-panel data can arrive with
/// missing fields or slightly different types (e.g. "3" instead of 3), so
/// models never cast directly.
extension MapReader on Map<String, dynamic> {
  String str(String key, [String fallback = '']) {
    final v = this[key];
    if (v == null) return fallback;
    final s = v.toString();
    return s.isEmpty ? fallback : s;
  }

  int integer(String key, [int fallback = 0]) {
    final v = this[key];
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  double dbl(String key, [double fallback = 0]) {
    final v = this[key];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? fallback;
    return fallback;
  }

  bool boolean(String key, [bool fallback = false]) {
    final v = this[key];
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return fallback;
  }

  List<String> strings(String key) {
    final v = this[key];
    if (v is List) return v.where((e) => e != null).map((e) => e.toString()).toList();
    return const [];
  }

  List<num> numbers(String key) {
    final v = this[key];
    if (v is List) return v.whereType<num>().toList();
    return const [];
  }

  List<Map<String, dynamic>> maps(String key) {
    final v = this[key];
    if (v is List) {
      return v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return const [];
  }

  Map<String, dynamic> obj(String key) {
    final v = this[key];
    if (v is Map) return Map<String, dynamic>.from(v);
    return const <String, dynamic>{};
  }

  DateTime? date(String key) {
    final v = this[key];
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    if (v is String) return DateTime.tryParse(v);
    if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
    return null;
  }
}

extension IterableFind<T> on Iterable<T> {
  T? findOrNull(bool Function(T e) test) {
    for (final e in this) {
      if (test(e)) return e;
    }
    return null;
  }

  T? get firstOrNullX => isEmpty ? null : first;
}
