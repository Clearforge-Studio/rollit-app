class I18nKeys {
  static final I18nKeys instance = I18nKeys._internal();
  I18nKeys._internal();

  final HomeKeys home = HomeKeys.instance;
  final AddPlayersKeys addPlayers = AddPlayersKeys.instance;
  final SettingsKeys settings = SettingsKeys.instance;
  final CategoriesKeys categories = CategoriesKeys.instance;
  final StoreKeys store = StoreKeys.instance;
  final RemoveAdsPaywallKeys removeAdsPaywall = RemoveAdsPaywallKeys.instance;
  final PaywallSheetKeys paywallSheet = PaywallSheetKeys.instance;
}

class HomeKeys {
  static final HomeKeys instance = HomeKeys._internal();
  HomeKeys._internal();

  final String partyMode = "home.party_mode";
}

class AddPlayersKeys {
  static final AddPlayersKeys instance = AddPlayersKeys._internal();
  AddPlayersKeys._internal();

  final String title = "add_players.title";
  final String playerName = "add_players.player_name";
  final String chooseAvatar = "add_players.choose_avatar";
  final String startGame = "add_players.start_game";
}

class SettingsKeys {
  static final SettingsKeys instance = SettingsKeys._internal();
  SettingsKeys._internal();

  final String title = "settings.title";
  final String sounds = "settings.sounds";
  final String vibrations = "settings.vibrations";
  final String store = "settings.store";
  final String restorePurchases = "settings.restore_purchases";
  final String informations = "settings.informations";
  final String privacyPolicy = "settings.privacy_policy";
  final String adsPreferences = "settings.ads_preferences";
  final String rateTheApp = "settings.rate_the_app";
  final String about = "settings.about";
  final String version = "settings.version";
}

class CategoriesKeys {
  static final CategoriesKeys instance = CategoriesKeys._internal();
  CategoriesKeys._internal();

  final String title = "categories.title";
  final String imitation = "categories.imitation";
  final String challenge = "categories.challenge";
  final String extremeChallenge = "categories.extreme_challenge";
  final String funQuestion = "categories.fun_question";
  final String wtf = "categories.wtf";
  final String wtfPlus = "categories.wtf_plus";
  final String miniGames = "categories.mini_games";
}

class StoreKeys {
  static final StoreKeys instance = StoreKeys._internal();
  StoreKeys._internal();

  final String title = "store.title";
  final String premiumPacks = "store.premium_packs";
  final String otherOptions = "store.other_options";
  final String wtfPlus = "store.wtf_plus";
  final String wtfPlusDescription = "store.wtf_plus_description";
  final String challengeExtreme = "store.challenge_extreme";
  final String challengeExtremeDescription =
      "store.challenge_extreme_description";
  final String removeAds = "store.remove_ads";
  final String removeAdsDescription = "store.remove_ads_description";
}

class RemoveAdsPaywallKeys {
  static final RemoveAdsPaywallKeys instance = RemoveAdsPaywallKeys._internal();
  RemoveAdsPaywallKeys._internal();

  final String title = "remove_ads_paywall.title";
  final String premium = "remove_ads_paywall.premium";
  final String productTitle = "remove_ads_paywall.product.title";
  final String productDescription = "remove_ads_paywall.product.description";
  final String later = "remove_ads_paywall.later";
  final String perkNoAds = "remove_ads_paywall.perk.no_ads";
  final String perkSmootherGames = "remove_ads_paywall.perk.smoother_games";
  final String perkOneTimePurchase =
      "remove_ads_paywall.perk.one_time_purchase";
  final String bought = "remove_ads_paywall.bought";
}

class PaywallSheetKeys {
  static final PaywallSheetKeys instance = PaywallSheetKeys._internal();
  PaywallSheetKeys._internal();

  final String title = "paywall_sheet.title";
  final String premium = "paywall_sheet.premium";
  final String perkUnlockPacks = "paywall_sheet.perk.unlock_packs";
  final String perkOneTimePurchase = "paywall_sheet.perk.one_time_purchase";
  final String perkNoPersonalData = "paywall_sheet.perk.no_personal_data";
  final String wtfPlusProductTitle = "paywall_sheet.product.wtf_plus.title";
  final String wtfPlusProductDescription =
      "paywall_sheet.product.wtf_plus.description";
  final String challengeExtremeProductTitle =
      "paywall_sheet.product.challenge_extreme.title";
  final String challengeExtremeProductDescription =
      "paywall_sheet.product.challenge_extreme.description";
  final String removeAdsProductTitle = "paywall_sheet.product.remove_ads.title";
  final String removeAdsProductDescription =
      "paywall_sheet.product.remove_ads.description";
  final String restore = "paywall_sheet.restore";
  final String bought = "paywall_sheet.bought";
}
