import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:rollit/services/preferences.service.dart';

class PurchaseService {
  // Singleton
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  // Produits disponibles sur Google Play
  static const String productWtfPlus = "wtf_plus";
  static const String productChallengeExtreme = "challenge_extreme";
  static const String productRemoveAds = "remove_ads";

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Liste des produits récupérés sur Google Play
  List<ProductDetails> products = [];

  // Statuts locaux
  bool wtfPlusOwned = false;
  bool challengeExtremeOwned = false;
  bool adsRemoved = true;

  Future<void> init() async {
    // Lecture des achats enregistrés localement
    wtfPlusOwned = PreferencesService.getWtfPlusOwned();
    challengeExtremeOwned = PreferencesService.getChallengeExtremeOwned();
    adsRemoved = PreferencesService.getAdsRemoved();

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

  Future<void> buyChallengeExtreme() async {
    final product = products.firstWhere(
      (p) => p.id == productChallengeExtreme,
      orElse: () => throw Exception("Produit Challenge Extrême introuvable"),
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
        await PreferencesService.setWtfPlusOwned(true);
        print("WTF+ débloqué");
        break;

      case productChallengeExtreme:
        challengeExtremeOwned = true;
        await PreferencesService.setChallengeExtremeOwned(true);
        print("Challenge Extrême débloqué");
        break;

      case productRemoveAds:
        adsRemoved = true;
        await PreferencesService.setAdsRemoved(true);
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
