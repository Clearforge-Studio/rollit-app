import 'dart:developer';

import 'package:flutter_riverpod/legacy.dart';
import 'package:rollit/services/purchase.service.dart';

class PurchaseState {
  final bool loading;
  final String? error;

  final bool wtfPlusOwned;
  final bool challengeExtremeOwned;
  final bool adsRemoved;
  final String? wtfPlusPrice;
  final String? challengeExtremePrice;
  final String? removeAdsPrice;

  const PurchaseState({
    required this.loading,
    required this.wtfPlusOwned,
    required this.challengeExtremeOwned,
    required this.adsRemoved,
    this.wtfPlusPrice,
    this.challengeExtremePrice,
    this.removeAdsPrice,
    this.error,
  });

  factory PurchaseState.initial() => const PurchaseState(
    loading: true,
    wtfPlusOwned: false,
    challengeExtremeOwned: false,
    adsRemoved: false,
    wtfPlusPrice: null,
    challengeExtremePrice: null,
    removeAdsPrice: null,
    error: null,
  );

  PurchaseState copyWith({
    bool? loading,
    bool? wtfPlusOwned,
    bool? challengeExtremeOwned,
    bool? adsRemoved,
    String? error,
    String? wtfPlusPrice,
    String? challengeExtremePrice,
    String? removeAdsPrice,
  }) {
    return PurchaseState(
      loading: loading ?? this.loading,
      wtfPlusOwned: wtfPlusOwned ?? this.wtfPlusOwned,
      challengeExtremeOwned:
          challengeExtremeOwned ?? this.challengeExtremeOwned,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      error: error,
      wtfPlusPrice: wtfPlusPrice ?? this.wtfPlusPrice,
      challengeExtremePrice:
          challengeExtremePrice ?? this.challengeExtremePrice,
      removeAdsPrice: removeAdsPrice ?? this.removeAdsPrice,
    );
  }
}

final purchaseControllerProvider =
    StateNotifierProvider<PurchaseController, PurchaseState>(
      (ref) => PurchaseController(),
    );

class PurchaseController extends StateNotifier<PurchaseState> {
  final _service = PurchaseService.instance;

  PurchaseController() : super(PurchaseState.initial()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await _service.init();
      _syncFromService();
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> _syncFromService() async {
    final wtfPlusProduct = await _service.getProduct(
      PurchaseService.entWtfPlus,
    );
    final challengeExtremeProduct = await _service.getProduct(
      PurchaseService.entChallengeExtreme,
    );
    final removeAdsProduct = await _service.getProduct(
      PurchaseService.entRemoveAds,
    );

    String? wtfPlusPrice;
    if (wtfPlusProduct != null) {
      wtfPlusPrice = wtfPlusProduct.priceString;
    }

    String? challengeExtremePrice;
    if (challengeExtremeProduct != null) {
      challengeExtremePrice = challengeExtremeProduct.priceString;
    }

    String? removeAdsPrice;
    if (removeAdsProduct != null) {
      removeAdsPrice = removeAdsProduct.priceString;
    }

    state = state.copyWith(
      loading: false,
      wtfPlusOwned: _service.wtfPlusOwned,
      challengeExtremeOwned: _service.challengeExtremeOwned,
      adsRemoved: _service.adsRemoved,
      wtfPlusPrice: wtfPlusPrice,
      challengeExtremePrice: challengeExtremePrice,
      removeAdsPrice: removeAdsPrice,
    );
  }

  Future<BuyResult> buy(String entitlementKey) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final success = await _service.buy(entitlementKey);
      await _syncFromService();
      return success;
    } catch (e) {
      state = state.copyWith(loading: false, error: null);
      return BuyResult(BuyStatus.failed, message: e.toString());
    }
  }

  Future<BuyResult> restore() async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _service.restore();
      await _syncFromService();
      return BuyResult(BuyStatus.restored);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return BuyResult(BuyStatus.failed, message: e.toString());
    }
  }

  bool shouldSeeAds() {
    return !_service.adsRemoved &&
        !state.wtfPlusOwned &&
        !state.challengeExtremeOwned;
  }
}
