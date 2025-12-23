import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rollit/helpers/buy.dart';
import 'package:rollit/providers/purchase.provider.dart';
import 'package:rollit/services/purchase.service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key});

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    final removeAdsOwned = PurchaseService.instance.adsRemoved;
    final wtfPlusOwned = PurchaseService.instance.wtfPlusOwned;
    final challengeExtremeOwned =
        PurchaseService.instance.challengeExtremeOwned;
    final purchaseNotifier = ref.read(purchaseControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FF),
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
          "Boutique",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 26, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 650.0),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle("Packs Premium"),

              const SizedBox(height: 16),

              _storeCard(
                title: "WTF+",
                subtitle: "20 actions WTF encore plus folles et absurdes.",
                entName: PurchaseService.entWtfPlus,
                color: const Color(0xFF9A5DF5),
                icon: "🤪",
                owned: wtfPlusOwned,
                onTap: () async {
                  debugPrint("__________________________");
                  debugPrint(wtfPlusOwned.toString());
                  if (wtfPlusOwned) return;

                  await handleBuy(context, () async {
                    return await purchaseNotifier.buy(
                      PurchaseService.entWtfPlus,
                    );
                  });
                  setState(() {});
                },
              ),

              const SizedBox(height: 22),

              _storeCard(
                title: "Défis Extrêmes",
                subtitle:
                    "20 Défis physiques et mentaux pour passer au niveau supérieur.",
                entName: PurchaseService.entChallengeExtreme,
                color: const Color(0xFFFF8F5A),
                icon: "🔥",
                owned: challengeExtremeOwned,
                onTap: () async {
                  if (challengeExtremeOwned) return;

                  await handleBuy(context, () async {
                    return await purchaseNotifier.buy(
                      PurchaseService.entChallengeExtreme,
                    );
                  });

                  setState(() {});
                },
              ),

              const SizedBox(height: 22),

              _sectionTitle("Autres options"),

              const SizedBox(height: 16),

              _storeCard(
                title: "Supprimer les pubs",
                subtitle: "Plus aucune interruption",
                entName: PurchaseService.entRemoveAds,
                color: const Color(0xFF55E6C1),
                icon: "🚫",
                owned: removeAdsOwned,
                onTap: () async {
                  if (removeAdsOwned) return;

                  await handleBuy(context, () async {
                    return await purchaseNotifier.buy(
                      PurchaseService.entRemoveAds,
                    );
                  });
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF4C7DF0),
      ),
    );
  }

  Widget _storeCard({
    required String title,
    required String subtitle,
    required String entName,
    required String icon,
    required Color color,
    bool owned = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: owned ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: owned ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icone du pack
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 32)),
              ),
            ),

            const SizedBox(width: 18),

            // Texte + sous-titre
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: owned
                          ? Colors.grey.shade500
                          : Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10.0),
            // Prix
            FutureBuilder<StoreProduct?>(
              future: PurchaseService.instance.getProduct(entName),
              builder: (context, snapshot) {
                final price = owned
                    ? "Acheté"
                    : (snapshot.data?.priceString ?? "");

                return Text(
                  price,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: owned ? Colors.grey.shade400 : Colors.grey.shade800,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
