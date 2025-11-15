import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  /// Initialisation à faire au démarrage de l’app
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setSound(bool value) async {
    await _prefs.setBool('sound', value);
  }

  static bool getSound() {
    return _prefs.getBool('sound') ?? false;
  }

  static Future<void> setVibration(bool value) async {
    await _prefs.setBool('vibration', value);
  }

  static bool getVibration() {
    return _prefs.getBool('vibration') ?? false;
  }

  static bool getWtfPlusOwned() {
    return _prefs.getBool(PurchaseService.productWtfPlus) ?? false;
  }

  static Future<void> setWtfPlusOwned(bool value) async {
    await _prefs.setBool(PurchaseService.productWtfPlus, value);
  }

  static bool getChallengeExtremeOwned() {
    return _prefs.getBool('challenge_extreme_owned') ?? false;
  }

  static Future<void> setChallengeExtremeOwned(bool value) async {
    await _prefs.setBool('challenge_extreme_owned', value);
  }

  static bool getAdsRemoved() {
    return _prefs.getBool(PurchaseService.productRemoveAds) ?? false;
  }

  static Future<void> setAdsRemoved(bool value) async {
    await _prefs.setBool(PurchaseService.productRemoveAds, value);
  }

  static bool imitationEnabled() {
    return _prefs.getBool('imitation_enabled') ?? true;
  }

  static Future<void> setImitationEnabled(bool value) async {
    await _prefs.setBool('imitation_enabled', value);
  }

  static bool challengeEnabled() {
    return _prefs.getBool('challenge_enabled') ?? true;
  }

  static Future<void> setChallengeEnabled(bool value) async {
    await _prefs.setBool('challenge_enabled', value);
  }

  static bool funEnabled() {
    return _prefs.getBool('fun_enabled') ?? true;
  }

  static Future<void> setFunEnabled(bool value) async {
    await _prefs.setBool('fun_enabled', value);
  }

  static bool wtfEnabled() {
    return _prefs.getBool('wtf_enabled') ?? true;
  }

  static Future<void> setWtfEnabled(bool value) async {
    await _prefs.setBool('wtf_enabled', value);
  }

  static bool wtfPlusEnabled() {
    if (!PurchaseService.instance.wtfPlusOwned) {
      return false;
    }

    return _prefs.getBool('wtf_plus_enabled') ?? true;
  }

  static Future<void> setWtfPlusEnabled(bool value) async {
    await _prefs.setBool('wtf_plus_enabled', value);
  }

  static bool miniGameEnabled() {
    return _prefs.getBool('mini_game_enabled') ?? true;
  }

  static Future<void> setMiniGameEnabled(bool value) async {
    await _prefs.setBool('mini_game_enabled', value);
  }

  static bool challengeExtremeEnabled() {
    return _prefs.getBool('challenge_extreme_enabled') ?? true;
  }

  static Future<void> setChallengeExtremeEnabled(bool value) async {
    await _prefs.setBool('challenge_extreme_enabled', value);
  }

  static List<String> getEnabledCategories() {
    final imitationEnabled = PreferencesService.imitationEnabled();
    final challengeEnabled = PreferencesService.challengeEnabled();
    final funEnabled = PreferencesService.funEnabled();
    final wtfEnabled = PreferencesService.wtfEnabled();
    final wtfPlusEnabled = PreferencesService.wtfPlusEnabled();
    final miniGameEnabled = PreferencesService.miniGameEnabled();
    final challengeExtremeEnabled =
        PreferencesService.challengeExtremeEnabled();

    final enabledCategories = <String>[];

    if (imitationEnabled) {
      enabledCategories.add(DiceCategory.imitationCategory);
    }
    if (challengeEnabled) {
      enabledCategories.add(DiceCategory.challengeCategory);
    }
    if (funEnabled) {
      enabledCategories.add(DiceCategory.funCategory);
    }
    if (wtfEnabled) {
      enabledCategories.add(DiceCategory.wtfCategory);
    }
    if (wtfPlusEnabled) {
      enabledCategories.add(DiceCategory.wtfPlusCategory);
    }
    if (miniGameEnabled) {
      enabledCategories.add(DiceCategory.miniGameCategory);
    }

    if (challengeExtremeEnabled) {
      enabledCategories.add(DiceCategory.challengeExtremeCategory);
    }

    return enabledCategories;
  }
}
