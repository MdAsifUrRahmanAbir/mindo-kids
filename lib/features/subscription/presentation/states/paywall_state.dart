import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

@immutable
class PaywallState {
  final bool isLoading;
  final bool storeAvailable;
  final Map<String, ProductDetails> products;
  final String? selectedPlanId;
  final bool isBusy;
  final String? message;
  final bool messageIsError;

  const PaywallState({
    this.isLoading = true,
    this.storeAvailable = true,
    this.products = const {},
    this.selectedPlanId,
    this.isBusy = false,
    this.message,
    this.messageIsError = false,
  });

  PaywallState copyWith({
    bool? isLoading,
    bool? storeAvailable,
    Map<String, ProductDetails>? products,
    String? selectedPlanId,
    bool? isBusy,
    String? message,
    bool messageIsError = false,
    bool clearMessage = false,
  }) {
    return PaywallState(
      isLoading: isLoading ?? this.isLoading,
      storeAvailable: storeAvailable ?? this.storeAvailable,
      products: products ?? this.products,
      selectedPlanId: selectedPlanId ?? this.selectedPlanId,
      isBusy: isBusy ?? this.isBusy,
      message: clearMessage ? null : (message ?? this.message),
      messageIsError: clearMessage ? false : (message != null ? messageIsError : this.messageIsError),
    );
  }
}
