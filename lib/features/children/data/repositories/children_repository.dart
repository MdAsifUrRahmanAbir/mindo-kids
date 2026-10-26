import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/firestore_paths.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';

final childrenRepositoryProvider = Provider<ChildrenRepository>(
  (ref) => ChildrenRepository(ref.watch(firestoreProvider)),
);

class ChildrenRepository {
  ChildrenRepository(this._db);
  final FirebaseFirestore _db;

  Stream<List<ChildProfile>> watchChildren(String uid) =>
      _db.collection(FirestorePaths.children(uid)).snapshots().map((q) {
        final list = q.docs.map((d) => ChildProfile.fromMap(d.id, d.data())).toList()
          ..sort((a, b) => (a.createdAt ?? DateTime(2000)).compareTo(b.createdAt ?? DateTime(2000)));
        return list;
      });

  Future<String> createChild(
    String uid, {
    required String name,
    required String ageBand,
    AvatarModel? avatar,
    int dailyLimitMinutes = 0,
  }) async {
    final ref = _db.collection(FirestorePaths.children(uid)).doc();
    final write = ref.set({
      'name': name.trim(),
      'ageBand': ageBand,
      'avatarId': avatar?.id ?? '',
      'avatarUrl': avatar?.media.imageUrl ?? '',
      'avatarEmoji': avatar?.media.emoji ?? '🧒',
      'streak': 0,
      'bestStreak': 0,
      'lastActiveDate': '',
      'activeDates': <String>[],
      'lessonsCompleted': 0,
      'stars': 0,
      'dailyLimitMinutes': dailyLimitMinutes,
      'createdAt': DateTime.now(),
    });
    // Applied to the local cache immediately; don't block when offline.
    try {
      await write.timeout(const Duration(seconds: 4));
    } on TimeoutException {
      // queued
    }
    return ref.id;
  }

  Future<void> updateChild(
    String uid,
    String childId, {
    String? name,
    String? ageBand,
    AvatarModel? avatar,
    int? dailyLimitMinutes,
  }) {
    final data = <String, dynamic>{
      if (name != null) 'name': name.trim(),
      'ageBand': ?ageBand,
      if (avatar != null) ...{
        'avatarId': avatar.id,
        'avatarUrl': avatar.media.imageUrl,
        'avatarEmoji': avatar.media.emoji,
      },
      'dailyLimitMinutes': ?dailyLimitMinutes,
    };
    return _db.doc(FirestorePaths.child(uid, childId)).update(data);
  }

  /// Deletes the child plus their progress and badges.
  Future<void> deleteChild(String uid, String childId) async {
    final batch = _db.batch();
    final progress = await _db.collection(FirestorePaths.progress(uid, childId)).get();
    for (final d in progress.docs) {
      batch.delete(d.reference);
    }
    final badges = await _db.collection(FirestorePaths.earnedBadges(uid, childId)).get();
    for (final d in badges.docs) {
      batch.delete(d.reference);
    }
    batch.delete(_db.doc(FirestorePaths.child(uid, childId)));
    await batch.commit();
  }
}
