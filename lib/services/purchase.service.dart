import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseService {
  // Singleton
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  // Produits disponibles sur Google Play
  static const String productWtfPlus = "wtf_plus";
  static const String productRemoveAds = "remove_ads";

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Liste des produits récupérés sur Google Play
  List<ProductDetails> products = [];

  // Statuts locaux
  bool wtfPlusOwned = false;
  bool adsRemoved = false;

  Future<void> init() async {
    final bool available = await _iap.isAvailable();
    if (!available) {
      print("IAP non disponible");
      return;
    }

    // Écoute des mises à jour d'achat
    _subscription = _iap.purchaseStream.listen(
      (purchases) {
        _handlePurchaseUpdates(purchases);
      },
      onDone: () => _subscription.cancel(),
      onError: (error) {
        print("Erreur dans purchaseStream: $error");
      },
    );

    await _loadProducts();
  }

  Future<void> _loadProducts() async {
    const ids = {productWtfPlus, productRemoveAds};

    final response = await _iap.queryProductDetails(ids);

    if (response.notFoundIDs.isNotEmpty) {
      print("Produits introuvables: ${response.notFoundIDs}");
    }

    if (response.error != null) {
      print("Erreur QueryProductDetails: ${response.error}");
    }

    products = response.productDetails;
  }

  // ACHATS -----------------------------------------------------------------

  Future<void> buyWtfPlus() async {
    final product = products.firstWhere(
      (p) => p.id == productWtfPlus,
      orElse: () => throw Exception("Produit WTF+ introuvable"),
    );

    final details = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: details);
  }

  Future<void> removeAds() async {
    final product = products.firstWhere(
      (p) => p.id == productRemoveAds,
      orElse: () => throw Exception("Produit Remove Ads introuvable"),
    );

    final details = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: details);
  }

  // GESTION DES MISES À JOUR ----------------------------------------------

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndApplyPurchase(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _verifyAndApplyPurchase(PurchaseDetails purchase) async {
    switch (purchase.productID) {
      case productWtfPlus:
        wtfPlusOwned = true;
        print("WTF+ débloqué");
        break;

      case productRemoveAds:
        adsRemoved = true;
        print("Les pubs sont retirées");
        break;
    }
  }

  // Récupération lors d’une réinstallation -------------------------------

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  // Nettoyage --------------------------------------------------------------

  void dispose() {
    _subscription.cancel();
  }
}
