import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rollit/helpers/buy.dart';
import 'package:rollit/providers/purchase.provider.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:rollit/services/purchase.service.dart';
import "package:easy_localization/easy_localization.dart";

class PaywallSheet extends ConsumerWidget {
  const PaywallSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final purchaseController = ref.read(purchaseControllerProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Color(0xFF200A3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 42,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                const _Badge(),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    I18nKeys.instance.paywallSheet.title.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const _Perks(),

            const SizedBox(height: 14),

            _ProductTile(
              title: I18nKeys.instance.paywallSheet.wtfPlusProductTitle.tr(),
              subtitle: I18nKeys.instance.paywallSheet.wtfPlusProductDescription
                  .tr(),
              price: purchaseState.wtfPlusPrice,
              owned: purchaseState.wtfPlusOwned,
              icon: Icons.sentiment_very_satisfied_rounded,
              onTap: purchaseState.loading
                  ? null
                  : () async {
                      await handleBuy(context, () async {
                        return await purchaseController.buy(
                          PurchaseService.entWtfPlus,
                        );
                      });

                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
            ),
            const SizedBox(height: 10),
            _ProductTile(
              title: I18nKeys.instance.paywallSheet.challengeExtremeProductTitle
                  .tr(),
              subtitle: I18nKeys
                  .instance
                  .paywallSheet
                  .challengeExtremeProductDescription
                  .tr(),
              price: purchaseState.challengeExtremePrice,
              owned: purchaseState.challengeExtremeOwned,
              icon: Icons.local_fire_department_rounded,
              onTap: purchaseState.loading
                  ? null
                  : () async {
                      await handleBuy(context, () async {
                        return await purchaseController.buy(
                          PurchaseService.entChallengeExtreme,
                        );
                      });
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
            ),
            const SizedBox(height: 10),
            _ProductTile(
              title: I18nKeys.instance.paywallSheet.removeAdsProductTitle.tr(),
              subtitle: I18nKeys
                  .instance
                  .paywallSheet
                  .removeAdsProductDescription
                  .tr(),
              price: purchaseState.removeAdsPrice,
              owned: purchaseState.adsRemoved,
              icon: Icons.block_rounded,
              onTap: purchaseState.loading
                  ? null
                  : () async {
                      await handleBuy(context, () async {
                        return await purchaseController.buy(
                          PurchaseService.entRemoveAds,
                        );
                      });
                      if (context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: purchaseState.loading
                        ? null
                        : () => purchaseController.restore(),
                    child: Text(
                      I18nKeys.instance.paywallSheet.restore.tr(),
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            if (purchaseState.loading)
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: LinearProgressIndicator(minHeight: 3),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF4FD8), Color(0xFF7C4DFF)],
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        I18nKeys.instance.paywallSheet.premium.tr(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _Perks extends StatelessWidget {
  const _Perks();

  @override
  Widget build(BuildContext context) {
    Widget perk(IconData icon, String text) => Row(
      children: [
        Icon(icon, size: 18, color: Colors.white70),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70)),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          perk(
            Icons.lock_open_rounded,
            I18nKeys.instance.paywallSheet.perkUnlockPacks.tr(),
          ),
          const SizedBox(height: 8),
          perk(
            Icons.offline_bolt_rounded,
            I18nKeys.instance.paywallSheet.perkOneTimePurchase.tr(),
          ),
          const SizedBox(height: 8),
          perk(
            Icons.privacy_tip_rounded,
            I18nKeys.instance.paywallSheet.perkNoPersonalData.tr(),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? price;
  final bool owned;
  final IconData icon;
  final VoidCallback? onTap;

  const _ProductTile({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.owned,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayPrice = price ?? "…";

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: owned ? null : onTap,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (owned)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  I18nKeys.instance.paywallSheet.bought.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF4FD8), Color(0xFF7C4DFF)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  displayPrice,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
