import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:mindo_kids/core/session/session_controller.dart';
import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';

enum PurchaseFlowStatus { pending, verifying, success, canceled, error }

class PurchaseEvent {
  final PurchaseFlowStatus status;
  final String message;
  const PurchaseEvent(this.status, [this.message = '']);
}

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  final service = PurchaseService(ref);
  ref.onDispose(service.dispose);
  return service;
});

/// Wraps `in_app_purchase` (Google Play Billing / StoreKit).
///
/// Flow: buy → store returns a purchase → token is sent to the
/// `verifyPurchase` Cloud Function → function checks it with Google Play,
/// writes subscriptions/{uid} → the app sees the entitlement through
/// [subscriptionProvider]. A client-side "success" never unlocks content.
class PurchaseService {
  PurchaseService(this._ref);

  final Ref _ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  final _events = StreamController<PurchaseEvent>.broadcast();
  StreamSubscription<List<PurchaseDetails>>? _sub;

  Stream<PurchaseEvent> get events => _events.stream;

  /// Call once the parent is signed in (MainShell does this) so purchases
  /// that finished while the app was closed are verified too.
  void start() {
    _sub ??= _iap.purchaseStream.listen(
      _onPurchases,
      onError: (Object e) => _emit(PurchaseFlowStatus.error, 'Store error. Please try again.'),
    );
  }

  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } catch (_) {
      return false;
    }
  }

  /// productId -> store product (with localized price).
  Future<Map<String, ProductDetails>> loadProducts(Set<String> productIds) async {
    final ids = productIds.where((e) => e.isNotEmpty).toSet();
    if (ids.isEmpty) return const {};
    final response = await _iap.queryProductDetails(ids);
    if (response.notFoundIDs.isNotEmpty) {
      debugPrint('Store products not found: ${response.notFoundIDs}');
    }
    final map = <String, ProductDetails>{};
    for (final p in response.productDetails) {
      map.putIfAbsent(p.id, () => p);
    }
    return map;
  }

  Future<void> buy(ProductDetails product) async {
    start();
    final uid = _ref.read(sessionControllerProvider).uid;
    _emit(PurchaseFlowStatus.pending);
    final ok = await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: product, applicationUserName: uid),
    );
    if (!ok) _emit(PurchaseFlowStatus.error, 'Could not start the purchase.');
  }

  Future<void> restore() async {
    start();
    _emit(PurchaseFlowStatus.pending);
    await _iap.restorePurchases();
  }

  Future<void> _onPurchases(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      final status = p.status;
      if (status == PurchaseStatus.pending) {
        _emit(PurchaseFlowStatus.pending);
      } else if (status == PurchaseStatus.canceled) {
        _emit(PurchaseFlowStatus.canceled);
      } else if (status == PurchaseStatus.error) {
        _emit(PurchaseFlowStatus.error, p.error?.message ?? 'Purchase failed.');
      } else if (status == PurchaseStatus.purchased || status == PurchaseStatus.restored) {
        await _verify(p);
      }

      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p);
        } catch (e) {
          debugPrint('completePurchase failed: $e');
        }
      }
    }
  }

  Future<void> _verify(PurchaseDetails p) async {
    _emit(PurchaseFlowStatus.verifying);
    try {
      await _ref
          .read(subscriptionRepositoryProvider)
          .verifyPurchase(
            platform: Platform.isIOS ? 'ios' : 'android',
            productId: p.productID,
            purchaseToken: p.verificationData.serverVerificationData,
          );
      _emit(PurchaseFlowStatus.success);
    } catch (e) {
      _emit(PurchaseFlowStatus.error, friendlyError(e));
    }
  }

  void _emit(PurchaseFlowStatus status, [String message = '']) {
    if (!_events.isClosed) _events.add(PurchaseEvent(status, message));
  }

  void dispose() {
    _sub?.cancel();
    _events.close();
  }
}
