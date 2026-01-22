import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static final AdsService instance = AdsService._internal();
  AdsService._internal();

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  final int maxFailedLoadAttempts = 3;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  final int maxFailedRewardedLoadAttempts = 3;

  // compteur pour décider quand afficher une pub
  int actionCount = 0;
  final int showEvery = 10; // pub toutes les 10 actions
  int partyModeGameCount = 0;

  // IDs de test par défaut
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return "ca-app-pub-3940256099942544/1033173712"; // TEST Android
      }

      return "ca-app-pub-2859118390192986/5174279550"; // PROD Android
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return "ca-app-pub-3940256099942544/4411468910"; // TEST iOS
      }

      return "ca-app-pub-2859118390192986/6363977148";
    }

    return "";
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      if (kDebugMode) {
        return "ca-app-pub-3940256099942544/5224354917"; // TEST Android
      }

      return "ca-app-pub-2859118390192986/3053775724"; // PROD Android
    } else if (Platform.isIOS) {
      if (kDebugMode) {
        return "ca-app-pub-3940256099942544/1712485313"; // TEST iOS
      }

      return "";
    }

    return "";
  }

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _createInterstitialAd();
    _createRewardedAd();
  }

  // CHARGEMENT INTERSTITIEL ---------------------------------------------------

  void _createInterstitialAd() {
    if (PurchaseService.instance.adsRemoved) {
      print("Ads disabled (Remove Ads acheté)");
      return;
    }
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print("Interstitial Loaded");
          _interstitialAd = ad;
          _numInterstitialLoadAttempts = 0;

          ad.setImmersiveMode(true);

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              print("Interstitial dismissed");
              ad.dispose();
              _createInterstitialAd(); // recharger une nouvelle pub
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
                  print("Failed to show interstitial: $error");
                  ad.dispose();
                  _createInterstitialAd();
                },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Failed to load interstitial: $error");
          _numInterstitialLoadAttempts += 1;
          _interstitialAd = null;

          if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        },
      ),
    );
  }

  // CHARGEMENT REWARDED ------------------------------------------------------

  void _createRewardedAd() {
    if (PurchaseService.instance.adsRemoved) {
      print("Ads disabled (Remove Ads acheté)");
      return;
    }
    final adUnitId = rewardedAdUnitId;
    if (adUnitId.isEmpty) {
      return;
    }
    RewardedAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          print("Rewarded Loaded");
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          print("Failed to load rewarded: $error");
          _numRewardedLoadAttempts += 1;
          _rewardedAd = null;
          if (_numRewardedLoadAttempts < maxFailedRewardedLoadAttempts) {
            _createRewardedAd();
          }
        },
      ),
    );
  }

  // AFFICHAGE ----------------------------------------------------------------

  Future<bool> tryShowInterstitial() async {
    if (PurchaseService.instance.adsRemoved) {
      print("Ads disabled (Remove Ads)");
      return false;
    }

    actionCount++;

    if (actionCount < showEvery) return false; // pas encore

    // reset compteur
    actionCount = 0;

    if (_interstitialAd != null) {
      print("SHOWING interstitial");
      await _interstitialAd!.show();
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } else {
      print("Interstitial not ready, loading...");
      _createInterstitialAd();
      return false;
    }
  }

  Future<bool> tryShowPartyInterstitial() async {
    if (PurchaseService.instance.adsRemoved) {
      print("Ads disabled (Remove Ads)");
      return false;
    }

    partyModeGameCount++;

    if (partyModeGameCount != 1 &&
        (partyModeGameCount - 1) % 3 != 0) {
      return false;
    }

    if (_interstitialAd != null) {
      print("SHOWING interstitial (party mode)");
      await _interstitialAd!.show();
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } else {
      print("Interstitial not ready, loading...");
      _createInterstitialAd();
      return false;
    }
  }

  Future<bool> showRewardedAd() async {
    if (PurchaseService.instance.adsRemoved) {
      print("Ads disabled (Remove Ads)");
      return false;
    }
    if (kIsWeb || !Platform.isAndroid) {
      return false;
    }

    if (_rewardedAd == null) {
      _createRewardedAd();
      return false;
    }

    final ad = _rewardedAd!;
    _rewardedAd = null;

    final completer = Completer<bool>();
    var rewarded = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _createRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(rewarded);
        }
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _createRewardedAd();
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    ad.show(onUserEarnedReward: (_, __) {
      rewarded = true;
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });

    return completer.future;
  }

  // CLEANUP -------------------------------------------------------------------

  void dispose() {
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
