import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:mindo_kids/core/utils/error_mapper.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/content/providers/content_providers.dart';
import 'package:mindo_kids/features/subscription/data/services/purchase_service.dart';
import 'package:mindo_kids/features/subscription/presentation/states/paywall_state.dart';

final paywallControllerProvider = NotifierProvider.autoDispose<PaywallController, PaywallState>(PaywallController.new);

class PaywallController extends Notifier<PaywallState> {
  StreamSubscription<PurchaseEvent>? _sub;
  Timer? _restoreTimer;

  PurchaseService get _service => ref.read(purchaseServiceProvider);

  @override
  PaywallState build() {
    final service = ref.read(purchaseServiceProvider);
    service.start();
    _sub = service.events.listen(_onEvent);
    ref.onDispose(() {
      _sub?.cancel();
      _restoreTimer?.cancel();
    });
    Future.microtask(_load);
    return const PaywallState();
  }

  Future<void> _load() async {
    try {
      final plans = await ref.read(plansProvider.future);
      final available = await _service.isAvailable();
      final products = available
          ? await _service.loadProducts(plans.map((p) => p.productId).toSet())
          : <String, ProductDetails>{};
      if (!ref.mounted) return;
      final preferred = plans.findOrNull((p) => p.isHighlighted) ?? plans.firstOrNullX;
      state = state.copyWith(
        isLoading: false,
        storeAvailable: available,
        products: products,
        selectedPlanId: preferred?.id,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, message: friendlyError(e), messageIsError: true);
    }
  }

  void select(String planId) => state = state.copyWith(selectedPlanId: planId, clearMessage: true);

  Future<void> buy(PlanModel plan) async {
    final product = state.products[plan.productId];
    if (product == null) {
      state = state.copyWith(
        message: 'This plan isn\'t available in the store yet. Please try again later.',
        messageIsError: true,
      );
      return;
    }
    state = state.copyWith(isBusy: true, clearMessage: true);
    try {
      await _service.buy(product);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(isBusy: false, message: friendlyError(e), messageIsError: true);
    }
  }

  Future<void> restore() async {
    state = state.copyWith(isBusy: true, clearMessage: true);
    try {
      await _service.restore();
    } catch (e) {
      if (ref.mounted) state = state.copyWith(isBusy: false, message: friendlyError(e), messageIsError: true);
      return;
    }
    // The store sends nothing back when there is nothing to restore.
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(seconds: 8), () {
      if (ref.mounted && state.isBusy) {
        state = state.copyWith(isBusy: false, message: 'No previous subscription was found on this store account.');
      }
    });
  }

  void _onEvent(PurchaseEvent e) {
    if (!ref.mounted) return;
    switch (e.status) {
      case PurchaseFlowStatus.pending:
        state = state.copyWith(isBusy: true, clearMessage: true);
      case PurchaseFlowStatus.verifying:
        state = state.copyWith(isBusy: true, message: 'Confirming your purchase…');
      case PurchaseFlowStatus.success:
        _restoreTimer?.cancel();
        state = state.copyWith(isBusy: false, message: 'Welcome to Mindo Plus! Every world is now unlocked 🎉');
      case PurchaseFlowStatus.canceled:
        state = state.copyWith(isBusy: false, clearMessage: true);
      case PurchaseFlowStatus.error:
        state = state.copyWith(isBusy: false, message: e.message, messageIsError: true);
    }
  }
}
