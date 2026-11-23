import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rollit/config.dart';

enum BuyStatus { success, failed, cancelled, restored }

class BuyResult {
  final BuyStatus status;
  final String? message;
  BuyResult(this.status, {this.message});
}

class PurchaseService {
  static final PurchaseService instance = PurchaseService._internal();
  PurchaseService._internal();

  // Entitlements (clé RevenueCat)
  static const String entWtfPlus = "wtf_plus";
  static const String entChallengeExtreme = "challenge_extreme";
  static const String entRemoveAds = "remove_ads";

  bool wtfPlusOwned = false;
  bool challengeExtremeOwned = false;
  bool adsRemoved = false;

  static const String _androidApiKey = revenueCatApiKey;
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
    if (apiKey == null || apiKey.isEmpty) {
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

    log('Entitlements actifs: ${active.keys.toList()}');

    wtfPlusOwned = active.containsKey(entWtfPlus);
    challengeExtremeOwned = active.containsKey(entChallengeExtreme);
    adsRemoved =
        active.containsKey(entRemoveAds) ||
        wtfPlusOwned ||
        challengeExtremeOwned;
  }

  // 💳 Achat via offering
  Future<BuyResult> buy(String entitlementKey) async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering = offerings.current;
      if (offering == null) {
        return BuyResult(
          BuyStatus.failed,
          message: "Aucune offering disponible",
        );
      }

      final package = offering.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == entitlementKey,
        orElse: () => throw Exception("Produit non trouvé"),
      );

      final result = await Purchases.purchase(PurchaseParams.package(package));

      log(result.toString());
      final ok = result.customerInfo.entitlements.active.containsKey(
        entitlementKey,
      );
      if (!ok) {
        return BuyResult(
          BuyStatus.failed,
          message: "Achat OK mais entitlement non activé",
        );
      }

      await refreshEntitlements();
      return BuyResult(BuyStatus.success);
    } on PurchasesError catch (e) {
      // Annulation utilisateur
      if (e.code == PurchasesErrorCode.purchaseCancelledError) {
        return BuyResult(BuyStatus.cancelled);
      }
      // Autres erreurs (store, réseau, config, etc.)
      return BuyResult(BuyStatus.failed, message: e.message);
    } on PlatformException catch (e) {
      // Annulation utilisateur
      final code = PurchasesErrorHelper.getErrorCode(e);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        return BuyResult(BuyStatus.cancelled);
      }
      // Autres erreurs (store, réseau, config, etc.)
      return BuyResult(BuyStatus.failed, message: e.message);
    } catch (e) {
      return BuyResult(BuyStatus.failed, message: e.toString());
    }
  }

  // 🔁 Restore (facultatif, souvent automatique)
  Future<BuyResult> restore() async {
    await Purchases.restorePurchases();
    await refreshEntitlements();

    return BuyResult(BuyStatus.restored);
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
