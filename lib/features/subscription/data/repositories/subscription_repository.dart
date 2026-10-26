import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mindo_kids/core/constants/app_constants.dart';
import 'package:mindo_kids/core/constants/firestore_paths.dart';
import 'package:mindo_kids/core/providers/firebase_providers.dart';
import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/features/common_models/family_models.dart';

final subscriptionRepositoryProvider = Provider<SubscriptionRepository>(
  (ref) => SubscriptionRepository(ref.watch(firestoreProvider), ref.watch(functionsProvider)),
);

/// The entitlement lives in subscriptions/{uid}. The app can only READ it;
/// it is granted by the `verifyPurchase` Cloud Function after the purchase
/// token is checked with Google Play — never by the client.
class SubscriptionRepository {
  SubscriptionRepository(this._db, this._functions);
  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  Stream<SubscriptionModel?> watch(String uid) => _db.doc(FirestorePaths.subscription(uid)).snapshots().map((s) {
    final data = s.data();
    return data == null ? null : SubscriptionModel.fromMap(data);
  });

  Future<Map<String, dynamic>> verifyPurchase({
    required String platform,
    required String productId,
    required String purchaseToken,
  }) async {
    final result = await _functions.httpsCallable(AppConstants.fnVerifyPurchase).call<dynamic>({
      'platform': platform,
      'productId': productId,
      'purchaseToken': purchaseToken,
    });
    final data = result.data;
    return data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{};
  }
}

final subscriptionProvider = StreamProvider<SubscriptionModel?>((ref) {
  final uid = ref.watch(sessionControllerProvider.select((s) => s.uid));
  if (uid == null) return Stream.value(null);
  return ref.watch(subscriptionRepositoryProvider).watch(uid);
});

/// True when the parent has an active, unexpired subscription.
final isPremiumProvider = Provider<bool>((ref) => ref.watch(subscriptionProvider).value?.isActiveNow ?? false);
