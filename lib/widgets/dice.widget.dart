import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/helpers/rate.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/providers/dice.provider.dart';
import 'package:rollit/providers/purchase.provider.dart';
import 'package:rollit/services/ads.service.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:rollit/services/review.service.dart';
import 'package:rollit/services/sound.service.dart';
import 'package:rollit/widgets/paywall_sheet.dart';
import 'package:rollit/widgets/remove_ads_paywall.dart';
import 'package:vibration/vibration.dart';

class Dice extends ConsumerStatefulWidget {
  final List<DiceCategory> categories;
  final double size;
  final ValueChanged<DiceCategory> onRollComplete;
  final Function? onRollStart;
  final bool hideDiceOnComplete;
  final bool hideDiceInitially;
  final String diceText;
  final bool showButton;
  final bool isEnabled;

  /// Face par défaut (avant le premier roll)
  final String initialFacePath;

  const Dice({
    super.key,
    required this.categories,
    required this.onRollComplete,
    this.onRollStart,
    required this.initialFacePath,
    this.hideDiceOnComplete = false,
    this.hideDiceInitially = false,
    this.diceText = "Roll!",
    this.showButton = true,
    this.size = 150,
    this.isEnabled = true,
  });

  @override
  ConsumerState<Dice> createState() => _DiceState();
}

class _DiceState extends ConsumerState<Dice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _spin;
  bool _isRolling = false;
  bool _hideDice = false;

  int _currentLogicalIndex = -1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _spin = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    if (widget.hideDiceInitially) {
      _hideDice = true;
    }
  }

  @override
  void didUpdateWidget(covariant Dice oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_currentLogicalIndex >= widget.categories.length) {
      setState(() => _currentLogicalIndex = -1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void roll(BuildContext context) async {
    if (_isRolling) return;
    if (widget.categories.isEmpty) return;

    _isRolling = true;

    await triggerDiceRollSound();
    triggerHaptic();

    Future.microtask(() {
      if (widget.onRollStart != null) {
        widget.onRollStart!();
      }
    });

    final total = widget.categories.length;
    final newIndex = Random().nextInt(total);
    final selected = widget.categories[newIndex];

    if (!mounted) return;
    setState(() => _currentLogicalIndex = newIndex);

    _controller.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    if (widget.hideDiceOnComplete) {
      setState(() => _hideDice = true);
    }

    _isRolling = false;

    final updatedRollsCount = PreferencesService.getRollsCount() + 1;
    PreferencesService.setRollsCount(updatedRollsCount);

    final showed = await AdsService.instance.tryShowInterstitial();
    final wtfPlusOwned = ref.read(purchaseControllerProvider).wtfPlusOwned;
    final challengeExtremeOwned = ref
        .read(purchaseControllerProvider)
        .challengeExtremeOwned;

    if (showed &&
        !PreferencesService.hasShownRemoveAdsPaywall() &&
        !wtfPlusOwned &&
        !challengeExtremeOwned) {
      if (mounted) {
        PreferencesService.setHasShownRemoveAdsPaywall(true);
        if (context.mounted) {
          await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            useSafeArea: false,
            builder: (_) => const RemoveAdsPaywall(),
          );
        }
      }
    }

    final ownsAllPacks = wtfPlusOwned && challengeExtremeOwned;
    final diceState = ref.read(diceProvider);

    if (updatedRollsCount >= diceState.maxRollsBeforePaywall &&
        mounted &&
        !PreferencesService.hasShownPaywall() &&
        !ownsAllPacks) {
      PreferencesService.setHasShownPaywall(true);
      if (context.mounted) {
        await showModalBottomSheet<bool>(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const PaywallSheet(),
        );
      }
    }

    widget.onRollComplete(selected);
  }

  Future<void> triggerHaptic() async {
    if (!PreferencesService.getVibration()) return;

    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 200, amplitude: 255);
    }
  }

  Future<void> triggerDiceRollSound() async {
    if (!PreferencesService.getSound()) return;

    await SoundService.play("dice-roll.mp3");
  }

  @override
  Widget build(BuildContext context) {
    final hasValidIndex =
        _currentLogicalIndex >= 0 &&
        _currentLogicalIndex < widget.categories.length;

    final fallbackImage =
        widget.categories.isNotEmpty ? widget.categories[0].imagePath : '';
    final displayedImage = hasValidIndex
        ? widget.categories[_currentLogicalIndex].imagePath
        : (widget.initialFacePath.isNotEmpty
            ? widget.initialFacePath
            : fallbackImage);

    return GestureDetector(
      onTap: widget.isEnabled
          ? () async {
              final canAsk = await ReviewService.canAskForReview();
              if (!context.mounted) return;
              if (canAsk) {
                return await showRateAppDialog(context);
              }

              setState(() {
                _hideDice = false;
              });
              roll(context);
            }
          : null,
      child: Opacity(
        opacity: widget.isEnabled ? 1.0 : 0.55,
        child: AnimatedBuilder(
          animation: _spin,
          builder: (_, child) {
            final angle = _spin.value * pi * 2;
            final scale = 1.0 + sin(_spin.value * pi) * 0.15;

            return Column(
              children: [
                if (!_hideDice)
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..rotateZ(angle)
                      ..scale(scale),
                    child: Container(
                      width: widget.size,
                      height: widget.size,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(20),
                      child: FittedBox(child: Image.asset(displayedImage)),
                    ),
                  ),

                if (!_hideDice && widget.showButton) const SizedBox(height: 40),
                if (widget.showButton)
                  GestureDetector(
                    onTap:
                        widget.isEnabled
                            ? () async {
                                final canAsk =
                                    await ReviewService.canAskForReview();
                                if (!context.mounted) return;
                                if (canAsk) {
                                  return await showRateAppDialog(context);
                                }

                                setState(() {
                                  _hideDice = false;
                                });

                                roll(context);
                              }
                            : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 64,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF5EDF), // rose neon
                            Color(0xFF6A5DFF), // violet RollIt!
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(64),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF3EDF).withValues(
                              alpha: 0.4,
                            ),
                            blurRadius: 22,
                            spreadRadius: 1,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.diceText,
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
