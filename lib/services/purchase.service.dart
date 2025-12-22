import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseService {
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  // Entitlements (clé RevenueCat)
  static const String entWtfPlus = "wtf_plus_access";
  static const String entChallengeExtreme = "challenge_extreme_access";
  static const String entRemoveAds = "remove_ads_access";

  bool wtfPlusOwned = false;
  bool challengeExtremeOwned = false;
  bool adsRemoved = false;

  static const String _androidApiKey = String.fromEnvironment(
    "REVENUECAT_ANDROID_KEY",
    defaultValue: "",
  );
  static const String _iosApiKey = String.fromEnvironment(
    "REVENUECAT_IOS_KEY",
    defaultValue: "",
  );

  String? _currentApiKey() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _androidApiKey;
      case TargetPlatform.iOS:
        return _iosApiKey;
      default:
        return null;
    }
  }

  Future<void> init() async {
    final apiKey = _currentApiKey();
    if (apiKey == null) {
      throw Exception(
        "Clé API RevenueCat non définie pour cette plateforme: $defaultTargetPlatform",
      );
    }

    await Purchases.configure(PurchasesConfiguration(apiKey));

    await refreshEntitlements();
  }

  // 🔄 Rafraîchir l’état premium
  Future<void> refreshEntitlements() async {
    final info = await Purchases.getCustomerInfo();
    final active = info.entitlements.active;

    wtfPlusOwned = active.containsKey(entWtfPlus);
    challengeExtremeOwned = active.containsKey(entChallengeExtreme);
    adsRemoved =
        active.containsKey(entRemoveAds) ||
        wtfPlusOwned ||
        challengeExtremeOwned;
  }

  // 💳 Achat via offering
  Future<void> buy(String entitlementKey) async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) {
      throw Exception("Aucune offering disponible");
    }

    final package = offering.availablePackages.firstWhere(
      (p) =>
          p.storeProduct.identifier.contains(entitlementKey.split('_').first),
      orElse: () => throw Exception("Produit non trouvé"),
    );

    final result = await Purchases.purchase(PurchaseParams.package(package));
    if (result.customerInfo.entitlements.active.isEmpty) {
      throw Exception("Achat échoué ou annulé");
    }

    await refreshEntitlements();
  }

  // 🔁 Restore (facultatif, souvent automatique)
  Future<void> restore() async {
    await Purchases.restorePurchases();
    await refreshEntitlements();
  }

  Future<StoreProduct?> getProduct(String entitlementKey) async {
    final offerings = await Purchases.getOfferings();
    final offering = offerings.current;

    if (offering == null) {
      throw Exception("Aucune offering disponible");
    }

    final package = offering.availablePackages.firstWhere(
      (p) =>
          p.storeProduct.identifier.contains(entitlementKey.split('_').first),
      orElse: () => throw Exception("Produit non trouvé"),
    );

    return package.storeProduct;
  }
}
