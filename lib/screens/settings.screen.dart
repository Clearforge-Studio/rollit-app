import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/helpers/buy.dart';
import 'package:rollit/helpers/url.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/providers/purchase.provider.dart';
import 'package:rollit/screens/store.screen.dart';
import 'package:rollit/services/consent_manager.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:rollit/services/review.service.dart';
import 'package:share_plus/share_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:rollit/services/update.service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late bool soundEnabled;
  late bool vibrationEnabled;
  String? _versionLabel;

  @override
  void initState() {
    super.initState();
    soundEnabled = PreferencesService.getSound();
    vibrationEnabled = PreferencesService.getVibration();
    _loadVersionInfo();
  }

  Future<void> _loadVersionInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _versionLabel = '${info.version} (${info.buildNumber})';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _versionLabel = "—";
      });
    }
  }

  void ensureMinimumOneCategoryEnabled(
    bool changingCategoryEnabled,
    String categoryId,
    Function? callback,
  ) {
    final enabledCategories = PreferencesService.getEnabledCategories();

    if (!changingCategoryEnabled &&
        enabledCategories.length <= 1 &&
        enabledCategories.contains(categoryId)) {
      // Empêche de désactiver la dernière catégorie restante

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(I18nKeys.instance.settings.minCategory.tr()),
          duration: Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    // Met à jour la préférence
    if (callback != null) {
      setState(() {});
      callback();
    }
  }

  Future<void> _showLanguageDialog() async {
    final localeLabels = <String, String>{
      'en': 'English',
      'fr': 'Français',
    };
    final localeFlags = <String, String>{
      'en': '🇬🇧',
      'fr': '🇫🇷',
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return SimpleDialog(
          title: Text(I18nKeys.instance.settings.languageDialogTitle.tr()),
          children: [
            for (final locale in context.supportedLocales)
              SimpleDialogOption(
                onPressed: () async {
                  await context.setLocale(locale);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: Row(
                  children: [
                    Text(
                      localeFlags[locale.languageCode] ?? '',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        localeLabels[locale.languageCode] ??
                            locale.languageCode,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (context.locale == locale)
                      const Icon(Icons.check, size: 20),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _showAboutDialog() async {
    if (!mounted) return;
    showAboutDialog(
      context: context,
      applicationName: "RollIt!",
      applicationVersion: _versionLabel ?? "—",
      applicationIcon: Container(
        width: 60,
        height: 60,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7F3DFF), Color(0xFF46167A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [],
        ),
        child: Image.asset(
          "assets/images/dice/challenge.png",
          color: Colors.white,
        ),
      ),
      applicationLegalese: "",
      children: [
        const SizedBox(height: 16),
        Text(
          I18nKeys.instance.settings.aboutDescription.tr(),
          style: const TextStyle(
            fontSize: 15,
            height: 1.35,
            color: Color(0xFF2C2C2C),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final removeAdsOwned = PurchaseService.instance.adsRemoved;
    final wtfPlusOwned = PurchaseService.instance.wtfPlusOwned;
    final challengeExtremeOwned =
        PurchaseService.instance.challengeExtremeOwned;
    final enabledCategories = PreferencesService.getEnabledCategories();
    final purchaseNotifier = ref.read(purchaseControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 242, 242, 251),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).appBarTheme.systemOverlayStyle!
            .copyWith(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              systemStatusBarContrastEnforced: true,

              systemNavigationBarColor: Color.fromARGB(255, 38, 10, 85),
              systemNavigationBarContrastEnforced: true,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
        title: Text(
          I18nKeys.instance.settings.title.tr(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 40.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 650.0),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              children: [
                _sectionTitle(
                  I18nKeys.instance.settings.sectionPreferences.tr(),
                ),

                _switchTile(
                  icon: Icons.volume_up,
                  title: I18nKeys.instance.settings.sounds.tr(),
                  value: soundEnabled,
                  onChanged: (val) {
                    setState(() => soundEnabled = val);
                    PreferencesService.setSound(val);
                  },
                ),

                _switchTile(
                  icon: Icons.vibration,
                  title: I18nKeys.instance.settings.vibrations.tr(),
                  value: vibrationEnabled,
                  onChanged: (val) {
                    setState(() => vibrationEnabled = val);
                    PreferencesService.setVibration(val);
                  },
                ),
                _navTile(
                  icon: Icons.language,
                  title: I18nKeys.instance.settings.language.tr(),
                  onTap: _showLanguageDialog,
                ),

                const SizedBox(height: 30),

                _sectionTitle(
                  I18nKeys.instance.settings.sectionCategories.tr(),
                ),

                _switchTile(
                  icon: Icons.theater_comedy,
                  title: I18nKeys.instance.categories.imitation.tr(),
                  value: enabledCategories.contains(
                    DiceCategory.imitationCategory,
                  ),
                  onChanged: (val) {
                    ensureMinimumOneCategoryEnabled(
                      val,
                      DiceCategory.imitationCategory,
                      () => PreferencesService.setImitationEnabled(val),
                    );
                  },
                ),

                _switchTile(
                  icon: Icons.flag,
                  title: I18nKeys.instance.categories.challenge.tr(),
                  value: enabledCategories.contains(
                    DiceCategory.challengeCategory,
                  ),
                  onChanged: (val) {
                    ensureMinimumOneCategoryEnabled(
                      val,
                      DiceCategory.challengeCategory,
                      () => PreferencesService.setChallengeEnabled(val),
                    );
                  },
                ),

                if (challengeExtremeOwned)
                  _switchTile(
                    icon: Icons.flash_on,
                    title: I18nKeys.instance.categories.extremeChallenge.tr(),
                    value: enabledCategories.contains(
                      DiceCategory.challengeExtremeCategory,
                    ),
                    onChanged: (val) {
                      ensureMinimumOneCategoryEnabled(
                        val,
                        DiceCategory.challengeExtremeCategory,
                        () =>
                            PreferencesService.setChallengeExtremeEnabled(val),
                      );
                    },
                  ),

                _switchTile(
                  icon: Icons.sentiment_satisfied,
                  title: I18nKeys.instance.categories.funQuestion.tr(),
                  value: enabledCategories.contains(DiceCategory.funCategory),
                  onChanged: (val) {
                    ensureMinimumOneCategoryEnabled(
                      val,
                      DiceCategory.funCategory,
                      () => PreferencesService.setFunEnabled(val),
                    );
                  },
                ),

                _switchTile(
                  icon: Icons.whatshot,
                  title: I18nKeys.instance.categories.wtf.tr(),
                  value: enabledCategories.contains(DiceCategory.wtfCategory),
                  onChanged: (val) {
                    ensureMinimumOneCategoryEnabled(
                      val,
                      DiceCategory.wtfCategory,
                      () => PreferencesService.setWtfEnabled(val),
                    );
                  },
                ),

                if (wtfPlusOwned)
                  _switchTile(
                    icon: Icons.star,
                    title: I18nKeys.instance.categories.wtfPlus.tr(),
                    value: enabledCategories.contains(
                      DiceCategory.wtfPlusCategory,
                    ),
                    onChanged: (val) {
                      ensureMinimumOneCategoryEnabled(
                        val,
                        DiceCategory.wtfPlusCategory,
                        () => PreferencesService.setWtfPlusEnabled(val),
                      );
                    },
                  ),

                _switchTile(
                  icon: Icons.videogame_asset,
                  title: I18nKeys.instance.categories.miniGames.tr(),
                  value: enabledCategories.contains(
                    DiceCategory.miniGameCategory,
                  ),
                  onChanged: (val) {
                    ensureMinimumOneCategoryEnabled(
                      val,
                      DiceCategory.miniGameCategory,
                      () => PreferencesService.setMiniGameEnabled(val),
                    );
                  },
                ),

                const SizedBox(height: 30),

                _sectionTitle(I18nKeys.instance.settings.sectionStore.tr()),

                _navTile(
                  icon: Icons.store,
                  title: I18nKeys.instance.settings.store.tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StoreScreen()),
                    );
                  },
                ),

                if (!removeAdsOwned)
                  _navTile(
                    icon: Icons.block,
                    title: I18nKeys.instance.settings.removeAds.tr(),
                    color: const Color(0xFF55E6C1),
                    onTap: () async {
                      await handleBuy(context, () async {
                        return await purchaseNotifier.buy(
                          PurchaseService.entRemoveAds,
                        );
                      });

                      setState(() {});
                    },
                  ),

                _navTile(
                  icon: Icons.refresh,
                  title: I18nKeys.instance.settings.restorePurchases.tr(),
                  onTap: () async {
                    await handleBuy(context, () async {
                      return await purchaseNotifier.restore();
                    });
                    setState(() {});
                  },
                ),

                const SizedBox(height: 30),

                _sectionTitle(I18nKeys.instance.settings.sectionSupport.tr()),

                _infoTile(
                  icon: Icons.support_agent,
                  title: I18nKeys.instance.settings.contactSupport.tr(),
                  onTap: () {
                    openUrl(
                      "mailto:support@clearforgestudio.com"
                      "?subject=Support%20RollIt!",
                    );
                  },
                ),

                _infoTile(
                  icon: Icons.lightbulb_outline,
                  title: I18nKeys.instance.settings.suggestFeature.tr(),
                  onTap: () {
                    openUrl(
                      "mailto:support@clearforgestudio.com"
                      "?subject=Suggestion%20RollIt!",
                    );
                  },
                ),

                if (Platform.isAndroid)
                  _infoTile(
                    icon: Icons.share,
                    title: I18nKeys.instance.settings.shareApp.tr(),
                    onTap: () {
                      Share.share(
                        "https://play.google.com/store/apps/details?id=com.clearforge.rollit",
                      );
                    },
                  ),

                const SizedBox(height: 30),

                _sectionTitle(
                  I18nKeys.instance.settings.sectionCommunity.tr(),
                ),

                _infoTile(
                  icon: Icons.star_rate_rounded,
                  title: I18nKeys.instance.settings.rateTheApp.tr(),
                  onTap: () async {
                    ReviewService.openStore();
                  },
                ),

                if (Platform.isAndroid)
                  _infoTile(
                    icon: Icons.storefront,
                    title: I18nKeys.instance.settings.otherApps.tr(),
                    onTap: () {
                      openUrl(
                        "https://play.google.com/store/apps/developer?id=Clearforge+Studio",
                      );
                    },
                  ),

                if (Platform.isAndroid)
                  _infoTile(
                    icon: Icons.system_update_alt,
                    title: I18nKeys.instance.settings.checkUpdates.tr(),
                    onTap: () async {
                      final result = await UpdateService.checkForUpdates(
                        force: true,
                      );
                      if (!context.mounted) return;
                      if (result == UpdateCheckResult.noUpdate) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              I18nKeys.instance.settings.noUpdate.tr(),
                            ),
                          ),
                        );
                      } else if (result == UpdateCheckResult.failed) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              I18nKeys.instance.settings.updateCheckFailed.tr(),
                            ),
                          ),
                        );
                      }
                    },
                  ),

                const SizedBox(height: 30),

                _sectionTitle(I18nKeys.instance.settings.sectionLegal.tr()),

                _infoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: I18nKeys.instance.settings.privacyPolicy.tr(),
                  onTap: () {
                    openUrl(
                      "https://clearforgestudio.com/rollit/privacy-policy",
                    );
                  },
                ),

                _infoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: I18nKeys.instance.settings.adsPreferences.tr(),
                  onTap: () => ConsentManager.instance.showPrivacyOptionsForm(),
                ),

                const SizedBox(height: 30),

                _sectionTitle(I18nKeys.instance.settings.sectionAbout.tr()),

                _infoTile(
                  icon: Icons.info_outline,
                  title: I18nKeys.instance.settings.about.tr(),
                  onTap: _showAboutDialog,
                ),

                _infoTile(
                  icon: Icons.code,
                  title: I18nKeys.instance.settings.version.tr(),
                  subtitle: _versionLabel ?? "—",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4C7DF0),
        ),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 26, color: Colors.grey.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          Platform.isIOS
              ? CupertinoSwitch(
                  value: value,
                  activeTrackColor: const Color.fromARGB(255, 45, 54, 226),
                  onChanged: onChanged,
                )
              : Switch(
                  value: value,
                  activeThumbColor: const Color.fromARGB(255, 45, 54, 226),
                  onChanged: onChanged,
                ),
        ],
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = const Color.fromARGB(255, 97, 97, 97),
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, size: 26),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 26, color: Colors.grey.shade700),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
