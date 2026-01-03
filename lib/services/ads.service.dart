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

  Future<void> init() async {
    await MobileAds.instance.initialize();
    _createInterstitialAd();
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

  // CLEANUP -------------------------------------------------------------------

  void dispose() {
    _interstitialAd?.dispose();
  }
}
