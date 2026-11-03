import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  PurchaseService({required this.onEntitlementGranted, required this.onEvent});

  static const premiumProductId = 'flycalm_premium_lifetime';

  final Future<void> Function() onEntitlementGranted;
  final Future<void> Function(String name, Map<String, Object?> parameters)
      onEvent;
  final InAppPurchase _store = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? product;
  bool storeAvailable = false;
  String? errorMessage;

  Future<void> initialize() async {
    _subscription ??= _store.purchaseStream.listen(
      _handlePurchases,
      onError: (Object error) {
        errorMessage = 'The store is temporarily unavailable.';
        onEvent('purchase_failed', {'reason': 'purchase_stream'});
      },
    );
    storeAvailable = await _store.isAvailable();
    if (!storeAvailable) return;
    final response = await _store.queryProductDetails({premiumProductId});
    if (response.productDetails.isNotEmpty) {
      product = response.productDetails.first;
    }
    if (response.error != null || response.notFoundIDs.isNotEmpty) {
      errorMessage = 'Premium is not available in this store build yet.';
    }
  }

  Future<bool> buy() async {
    final item = product;
    if (!storeAvailable || item == null) {
      await onEvent('purchase_failed', {'reason': 'product_unavailable'});
      return false;
    }
    await onEvent('purchase_started', {'product_id': premiumProductId});
    return _store.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: item));
  }

  Future<void> restore() async {
    await _store.restorePurchases();
  }

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != premiumProductId) continue;
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // TODO: Replace with backend verification before scaling. Google Play is
        // the source of truth; local persistence keeps the verified entitlement
        // usable in airplane mode.
        await onEntitlementGranted();
        await onEvent(
          purchase.status == PurchaseStatus.restored
              ? 'purchase_restored'
              : 'purchase_completed',
          {'product_id': premiumProductId},
        );
      } else if (purchase.status == PurchaseStatus.error ||
          purchase.status == PurchaseStatus.canceled) {
        await onEvent('purchase_failed', {'reason': purchase.status.name});
      }
      if (purchase.pendingCompletePurchase) {
        await _store.completePurchase(purchase);
      }
    }
  }

  Future<void> dispose() async => _subscription?.cancel();
}
