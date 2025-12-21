import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:rollit/services/ads.service.dart';

class ConsentManager {
  ConsentManager._();
  static final instance = ConsentManager._();

  bool _consentRequested = false;
  bool _adsInitialized = false;

  final ValueNotifier<bool> canInitAds = ValueNotifier(false);

  // ─────────────────────────────────────────────
  // MAIN ENTRY POINT
  // ─────────────────────────────────────────────

  Future<void> gatherConsentAndInitAdsIfAllowed() async {
    if (_consentRequested) return;
    _consentRequested = true;

    final params = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      // consentDebugSettings: _debug(),
    );

    final consentInfo = ConsentInformation.instance;

    consentInfo.requestConsentInfoUpdate(
      params,
      () async {
        if (await consentInfo.isConsentFormAvailable()) {
          await _loadAndShowFormIfRequired();
        }

        await _updateConsentState();

        if (canInitAds.value) {
          await _initAdsOnce();
        }
      },
      (error) {
        debugPrint('Consent error: ${error.message}');
      },
    );
  }

  // ─────────────────────────────────────────────
  // ADS INIT (ONCE)
  // ─────────────────────────────────────────────

  Future<void> _initAdsOnce() async {
    if (_adsInitialized) return;
    _adsInitialized = true;

    await AdsService.instance.init();
  }

  // ─────────────────────────────────────────────
  // CONSENT FORM
  // ─────────────────────────────────────────────

  Future<void> _loadAndShowFormIfRequired() async {
    ConsentForm.loadConsentForm(
      (form) async {
        final status = await ConsentInformation.instance.getConsentStatus();

        if (status == ConsentStatus.required) {
          form.show((formError) {
            debugPrint('Consent form error: ${formError?.message}');
          });
        }
      },
      (error) {
        debugPrint('Load consent form error: ${error.message}');
      },
    );
  }

  Future<void> _updateConsentState() async {
    canInitAds.value = await ConsentInformation.instance.canRequestAds();
  }

  // ─────────────────────────────────────────────
  // PRIVACY OPTIONS (SETTINGS)
  // ─────────────────────────────────────────────
  Future<bool> isPrivacyOptionsRequired() async {
    return await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
  }

  void showPrivacyOptionsForm() {
    ConsentForm.showPrivacyOptionsForm((formError) {
      debugPrint('Privacy options error: ${formError?.message}');
    });
  }

  // ─────────────────────────────────────────────
  // DEBUG (DEV ONLY)
  // ─────────────────────────────────────────────

  ConsentDebugSettings _debug() => ConsentDebugSettings(
    debugGeography: DebugGeography.debugGeographyEea,
    testIdentifiers: ["45DA2D7D995D15AE955B19F810848CA5"],
  );
}
