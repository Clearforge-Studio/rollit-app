import 'package:rollit/helpers/buy.dart';
import 'package:rollit/helpers/url.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/screens/store.screen.dart';
import 'package:rollit/services/consent_manager.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:flutter/material.dart';
import 'package:rollit/services/review.service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool soundEnabled;
  late bool vibrationEnabled;

  @override
  void initState() {
    super.initState();
    soundEnabled = PreferencesService.getSound();
    vibrationEnabled = PreferencesService.getVibration();
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
          content: Text("Au moins une catégorie doit être activée."),
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

  @override
  Widget build(BuildContext context) {
    final removeAdsOwned = PurchaseService.instance.adsRemoved;
    final wtfPlusOwned = PurchaseService.instance.wtfPlusOwned;
    final challengeExtremeOwned =
        PurchaseService.instance.challengeExtremeOwned;
    final enabledCategories = PreferencesService.getEnabledCategories();

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
        title: const Text(
          "Paramètres",
          style: TextStyle(
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
                _sectionTitle("Préférences"),

                _switchTile(
                  icon: Icons.volume_up,
                  title: "Sons",
                  value: soundEnabled,
                  onChanged: (val) {
                    setState(() => soundEnabled = val);
                    PreferencesService.setSound(val);
                  },
                ),

                _switchTile(
                  icon: Icons.vibration,
                  title: "Vibration",
                  value: vibrationEnabled,
                  onChanged: (val) {
                    setState(() => vibrationEnabled = val);
                    PreferencesService.setVibration(val);
                  },
                ),

                const SizedBox(height: 30),

                _sectionTitle("Catégories"),

                _switchTile(
                  icon: Icons.theater_comedy,
                  title: "Imitation",
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
                  title: "Défi",
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
                    title: "Défis Extrèmes",
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
                  title: "Question Fun",
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
                  title: "WTF",
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
                    title: "WTF+",
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
                  title: "Mini-jeux",
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

                _sectionTitle("Options"),

                _navTile(
                  icon: Icons.store,
                  title: "Boutique",
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
                    title: "Supprimer les pubs",
                    color: const Color(0xFF55E6C1),
                    onTap: () {
                      handleBuy(context, () async {
                        await PurchaseService.instance.buy(
                          PurchaseService.entRemoveAds,
                        );
                      });
                    },
                  ),

                _navTile(
                  icon: Icons.refresh,
                  title: "Restaurer les achats",
                  onTap: () async {
                    handleBuy(context, () async {
                      await PurchaseService.instance.restore();
                    });

                    setState(() {});
                  },
                ),

                const SizedBox(height: 30),

                _sectionTitle("Informations"),

                _infoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Politique de confidentialité",
                  onTap: () {
                    openUrl(
                      "https://clearforgestudio.com/rollit/privacy-policy",
                    );
                  },
                ),

                _infoTile(
                  icon: Icons.privacy_tip_outlined,
                  title: "Gérer vos choix publicitaires",
                  onTap: () => ConsentManager.instance.showPrivacyOptionsForm(),
                ),

                _infoTile(
                  icon: Icons.star_rate_rounded,
                  title: "Noter l’application",
                  onTap: () async {
                    ReviewService.openStore();
                  },
                ),

                _infoTile(
                  icon: Icons.info_outline,
                  title: "À propos",
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: "RollIt!",
                      applicationVersion: "1.0.0",
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
                          "RollIt! est un jeu simple et fun pour dynamiser vos soirées.\n\n"
                          "Lancez le dé, découvrez une catégorie, et réalisez une action amusante : "
                          "imitations, défis, questions fun, WTF ou mini-jeux.\n\n"
                          "Aucune inscription, aucune donnée collectée : vos préférences restent "
                          "localement sur votre appareil.\n\n"
                          "Merci d’utiliser RollIt! 🎲✨\nAmusez-vous bien !",
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                _infoTile(
                  icon: Icons.code,
                  title: "Version",
                  subtitle: "1.0.0",
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
          Switch(
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
