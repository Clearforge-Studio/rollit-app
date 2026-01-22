class I18nKeys {
  static final I18nKeys instance = I18nKeys._internal();
  I18nKeys._internal();

  final HomeKeys home = HomeKeys.instance;
  final CommonKeys common = CommonKeys.instance;
  final AddPlayersKeys addPlayers = AddPlayersKeys.instance;
  final PartyModeKeys partyMode = PartyModeKeys.instance;
  final PartyModeResultKeys partyModeResult = PartyModeResultKeys.instance;
  final SettingsKeys settings = SettingsKeys.instance;
  final CategoriesKeys categories = CategoriesKeys.instance;
  final StoreKeys store = StoreKeys.instance;
  final RemoveAdsPaywallKeys removeAdsPaywall = RemoveAdsPaywallKeys.instance;
  final PaywallSheetKeys paywallSheet = PaywallSheetKeys.instance;
  final PurchaseErrorKeys purchaseErrors = PurchaseErrorKeys.instance;
  final ResultKeys result = ResultKeys.instance;
}

class HomeKeys {
  static final HomeKeys instance = HomeKeys._internal();
  HomeKeys._internal();

  final String partyMode = "home.party_mode";
}

class CommonKeys {
  static final CommonKeys instance = CommonKeys._internal();
  CommonKeys._internal();

  final String roll = "common.roll";
  final String reroll = "common.reroll";
}

class AddPlayersKeys {
  static final AddPlayersKeys instance = AddPlayersKeys._internal();
  AddPlayersKeys._internal();

  final String title = "add_players.title";
  final String playerName = "add_players.player_name";
  final String chooseAvatar = "add_players.choose_avatar";
  final String chooseAvatarTitle = "add_players.choose_avatar_title";
  final String confirmAvatar = "add_players.confirm_avatar";
  final String maxPlayersReached = "add_players.max_players_reached";
  final String editDelete = "add_players.edit.delete";
  final String editSave = "add_players.edit.save";
  final String playersLabel = "add_players.players_label";
  final String emptyTitle = "add_players.empty_title";
  final String emptySubtitle = "add_players.empty_subtitle";
  final String maxPlayersHint = "add_players.max_players_hint";
  final String startGame = "add_players.start_game";
  final String roundsLabel = "add_players.rounds_label";
  final String roundsHint = "add_players.rounds_hint";
  final String roundsCustom = "add_players.rounds_custom";
  final String roundsDialogTitle = "add_players.rounds_dialog_title";
  final String roundsDialogSet = "add_players.rounds_dialog_set";
}

class PartyModeKeys {
  static final PartyModeKeys instance = PartyModeKeys._internal();
  PartyModeKeys._internal();

  final String turnToPlay = "party_mode.turn_to_play";
  final String tapToStart = "party_mode.tap_to_start";
  final String startTimer = "party_mode.start_timer";
  final String roll = "party_mode.roll";
  final String tapToRoll = "party_mode.tap_to_roll";
  final String addPlayersToStart = "party_mode.add_players_to_start";
  final String pass = "party_mode.pass";
  final String done = "party_mode.done";
  final String roundsProgress = "party_mode.rounds_progress";
  final String rerollWithAd = "party_mode.reroll_with_ad";
  final String rerollAdFailed = "party_mode.reroll_ad_failed";
  final String rerollLimit = "party_mode.reroll_limit";
  final String reroll = "party_mode.reroll";
}

class PartyModeResultKeys {
  static final PartyModeResultKeys instance = PartyModeResultKeys._internal();
  PartyModeResultKeys._internal();

  final String title = "party_mode_result.title";
  final String winnerTitle = "party_mode_result.winner_title";
  final String winnerText = "party_mode_result.winner_text";
  final String mostPickedTitle = "party_mode_result.most_picked_title";
  final String mostPickedText = "party_mode_result.most_picked_text";
  final String durationTitle = "party_mode_result.duration_title";
  final String durationText = "party_mode_result.duration_text";
  final String highlightText = "party_mode_result.highlight_text";
  final String replay = "party_mode_result.replay";
  final String backHome = "party_mode_result.back_home";
  final String noData = "party_mode_result.no_data";
  final String categoryTitleImitation =
      "party_mode_result.category_title.imitation";
  final String categoryTitleChallenge =
      "party_mode_result.category_title.challenge";
  final String categoryTitleChallengeExtreme =
      "party_mode_result.category_title.challenge_extreme";
  final String categoryTitleFun = "party_mode_result.category_title.fun";
  final String categoryTitleWtf = "party_mode_result.category_title.wtf";
  final String categoryTitleWtfPlus =
      "party_mode_result.category_title.wtf_plus";
  final String categoryTitleMiniGame =
      "party_mode_result.category_title.mini_game";
}

class SettingsKeys {
  static final SettingsKeys instance = SettingsKeys._internal();
  SettingsKeys._internal();

  final String title = "settings.title";
  final String sectionPreferences = "settings.section_preferences";
  final String sectionCategories = "settings.section_categories";
  final String sectionStore = "settings.section_store";
  final String sectionSupport = "settings.section_support";
  final String sectionCommunity = "settings.section_community";
  final String sectionLegal = "settings.section_legal";
  final String sectionAbout = "settings.section_about";
  final String sounds = "settings.sounds";
  final String vibrations = "settings.vibrations";
  final String store = "settings.store";
  final String removeAds = "settings.remove_ads";
  final String restorePurchases = "settings.restore_purchases";
  final String contactSupport = "settings.contact_support";
  final String suggestFeature = "settings.suggest_feature";
  final String shareApp = "settings.share_app";
  final String otherApps = "settings.other_apps";
  final String checkUpdates = "settings.check_updates";
  final String noUpdate = "settings.no_update";
  final String updateCheckFailed = "settings.update_check_failed";
  final String privacyPolicy = "settings.privacy_policy";
  final String adsPreferences = "settings.ads_preferences";
  final String rateTheApp = "settings.rate_the_app";
  final String about = "settings.about";
  final String aboutDescription = "settings.about_description";
  final String version = "settings.version";
  final String minCategory = "settings.min_category";
  final String language = "settings.language";
  final String languageDialogTitle = "settings.language_dialog_title";
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

class PurchaseErrorKeys {
  static final PurchaseErrorKeys instance = PurchaseErrorKeys._internal();
  PurchaseErrorKeys._internal();

  final String notAllowed = "purchase_errors.not_allowed";
  final String storeProblem = "purchase_errors.store_problem";
  final String cancelled = "purchase_errors.cancelled";
  final String generic = "purchase_errors.generic";
  final String paymentPending = "purchase_errors.payment_pending";
  final String productUnavailable = "purchase_errors.product_unavailable";
  final String invalidCredentials = "purchase_errors.invalid_credentials";
  final String network = "purchase_errors.network";
  final String invalidReceipt = "purchase_errors.invalid_receipt";
  final String unknownBackend = "purchase_errors.unknown_backend";
  final String invalidUser = "purchase_errors.invalid_user";
  final String operationInProgress = "purchase_errors.operation_in_progress";
  final String receiptInUse = "purchase_errors.receipt_in_use";
  final String missingReceipt = "purchase_errors.missing_receipt";
  final String alreadyPurchased = "purchase_errors.already_purchased";
}

class ResultKeys {
  static final ResultKeys instance = ResultKeys._internal();
  ResultKeys._internal();

  final String startTimer = "result.start_timer";
}
