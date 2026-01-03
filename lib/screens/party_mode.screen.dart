import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/models/dice_action.model.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/providers/action.provider.dart';
import 'package:rollit/providers/category.provider.dart';
import 'package:rollit/providers/party_mode.provider.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:rollit/widgets/add_players/avatar_utils.dart';
import 'package:rollit/widgets/app_background.widget.dart';
import 'package:rollit/widgets/dice.widget.dart';
import 'package:vibration/vibration.dart';

class PartyModeScreen extends ConsumerStatefulWidget {
  const PartyModeScreen({super.key});

  @override
  ConsumerState<PartyModeScreen> createState() => _PartyModeScreenState();
}

class _PartyModeScreenState extends ConsumerState<PartyModeScreen>
    with SingleTickerProviderStateMixin {
  DiceCategory? _rolledCategory;
  DiceActionItem? _rolledAction;
  List<ActionConstraint> _actionConstraints = [];
  int _actionPoints = 0;
  int? _timerDurationSeconds;
  int? _timerRemainingSeconds;
  Timer? _timer;
  final Random _random = Random();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _useSlideTransition = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  ActionConstraint? _getDurationConstraint(List<ActionConstraint> constraints) {
    for (final constraint in constraints) {
      if (constraint.type == 'duration') {
        return constraint;
      }
    }
    return null;
  }

  int _pointsForAction({
    required DiceCategory? category,
    required List<ActionConstraint> constraints,
  }) {
    if (category == null) {
      return 0;
    }

    int basePoints;
    switch (category.id) {
      case DiceCategory.challengeExtremeCategory:
        basePoints = 3;
        break;
      case DiceCategory.wtfPlusCategory:
        basePoints = 3;
        break;
      case DiceCategory.challengeCategory:
        basePoints = 2;
        break;
      case DiceCategory.miniGameCategory:
        basePoints = 2;
        break;
      case DiceCategory.wtfCategory:
        basePoints = 2;
        break;
      case DiceCategory.imitationCategory:
      case DiceCategory.funCategory:
      default:
        basePoints = 1;
    }

    int bonusPoints = 0;
    final durationConstraint = _getDurationConstraint(constraints);
    final duration = durationConstraint?.value ?? 0;
    if (duration >= 20) {
      bonusPoints = 2;
    } else if (duration >= 10) {
      bonusPoints = 1;
    }

    return basePoints + bonusPoints;
  }

  void _resetTimerForConstraints(List<ActionConstraint> constraints) {
    _timer?.cancel();
    _timer = null;

    final durationConstraint = _getDurationConstraint(constraints);
    setState(() {
      _timerDurationSeconds = durationConstraint?.value;
      _timerRemainingSeconds = null;
    });
  }

  void _startTimer() {
    final durationSeconds = _timerDurationSeconds;
    if (durationSeconds == null || durationSeconds <= 0) {
      return;
    }

    _timer?.cancel();
    _timer = null;

    setState(() {
      _timerRemainingSeconds = durationSeconds;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        final next = (_timerRemainingSeconds ?? 0) - 1;
        _timerRemainingSeconds = next.clamp(0, durationSeconds);
        if ((_timerRemainingSeconds ?? 0) <= 0) {
          timer.cancel();
          _triggerTimerHaptic();
        }
      });
    });
  }

  Future<void> _triggerTimerHaptic() async {
    if (!PreferencesService.getVibration()) return;
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 250, amplitude: 200);
    }
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _handlePass() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _useSlideTransition = false;
      _rolledCategory = null;
      _rolledAction = null;
      _actionConstraints = [];
      _actionPoints = 0;
      _timerDurationSeconds = null;
      _timerRemainingSeconds = null;
    });
    ref.read(partyModeProvider.notifier).nextPlayer();
    _maybeFinishGame();
  }

  void _handleDone() {
    _timer?.cancel();
    _timer = null;
    final points = _pointsForAction(
      category: _rolledCategory,
      constraints: _actionConstraints,
    );
    setState(() {
      _useSlideTransition = true;
      _rolledCategory = null;
      _rolledAction = null;
      _actionConstraints = [];
      _actionPoints = 0;
      _timerDurationSeconds = null;
      _timerRemainingSeconds = null;
    });
    ref.read(partyModeProvider.notifier).validateCurrentPlayer(delta: points);
    _maybeFinishGame();
  }

  void _maybeFinishGame() {
    final partyState = ref.read(partyModeProvider);
    if (partyState.roundsCompleted >= partyState.totalRounds) {
      ref.read(partyModeProvider.notifier).markGameFinished();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/party_mode_result');
    }
  }

  Widget _buildPlayerHeaderItem({
    required PartyPlayer player,
    required int score,
    required bool isCurrent,
  }) {
    final avatarUrl = avatarAssetForIndex(player.avatarIndex);
    final borderColor = isCurrent
        ? const Color(0xFFFFD36E).withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.15);
    final glowColor = isCurrent
        ? const Color(0xFFFFD36E).withValues(alpha: 0.45)
        : null;

    return AnimatedScale(
      scale: isCurrent ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 2),
                    boxShadow: glowColor != null
                        ? [
                            BoxShadow(
                              color: glowColor,
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatarUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0B1F).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      '$score',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(0xFFFFE7A0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 68,
              child: Text(
                player.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final hasResult = _rolledCategory != null;
    final actionText = _rolledAction?.text;
    final categoryTitle = _rolledCategory?.label ?? '';
    final label = hasResult
        ? (actionText != null && actionText.isNotEmpty
              ? actionText.tr()
              : (_rolledCategory?.label ?? ''))
        : "";
    final showCategoryTitle = hasResult && categoryTitle.isNotEmpty;
    final showStartButton =
        _timerDurationSeconds != null && _timerRemainingSeconds == null;
    final showCountdown = _timerRemainingSeconds != null;
    final isEndingSoon = showCountdown && (_timerRemainingSeconds ?? 0) <= 3;
    final timerColor = isEndingSoon ? const Color(0xFFFF6B6B) : Colors.white;
    final showPoints = hasResult && _actionPoints > 0;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        key: ValueKey(label),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(22),
        constraints: const BoxConstraints(minHeight: 140),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCategoryTitle)
              Text(
                categoryTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            if (showCategoryTitle) const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: hasResult ? FontWeight.w700 : FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            if (showPoints) const SizedBox(height: 8),
            if (showPoints)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  '+$_actionPoints pts',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: const Color(0xFFFFE7A0),
                  ),
                ),
              ),
            if (showStartButton) const SizedBox(height: 12),
            if (showStartButton)
              TextButton.icon(
                onPressed: _startTimer,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                label: Text(
                  I18nKeys.instance.partyMode.startTimer.tr(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            if (showCountdown) const SizedBox(height: 12),
            if (showCountdown)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, color: timerColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimer(_timerRemainingSeconds ?? 0),
                      style: GoogleFonts.poppins(
                        color: timerColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  DiceActionItem? _pickActionForCategory(
    DiceCategory category,
    List<DiceAction> actions,
  ) {
    if (actions.isEmpty) {
      return null;
    }
    final match = actions.where((action) => action.category == category.id);
    if (match.isEmpty) {
      return null;
    }
    final categoryActions = match.first.actions;
    if (categoryActions.isEmpty) {
      return null;
    }
    return categoryActions[_random.nextInt(categoryActions.length)];
  }

  Widget _buildPlayerContent({
    required PartyPlayer player,
    required List<DiceCategory> categories,
    required List<DiceAction> actions,
    required String initialFacePath,
    required bool diceEnabled,
    required bool showIntroText,
  }) {
    return Column(
      key: ValueKey(player.name),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOutCubic,
            opacity: showIntroText ? 1.0 : 0.0,
            child: showIntroText
                ? Column(
                    children: [
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Text(
                          I18nKeys.instance.partyMode.turnToPlay.tr(
                            namedArgs: {'name': player.name},
                          ),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Dice(
          categories: categories,
          onRollComplete: (category) {
            ref.read(partyModeProvider.notifier).startGameIfNeeded();
            ref.read(categoryProvider.notifier).setCurrentCategory(category);
            setState(() {
              _rolledCategory = category;
              final action = _pickActionForCategory(category, actions);
              _rolledAction = action;
              _actionConstraints = action?.constraints ?? [];
              _actionPoints = _pointsForAction(
                category: category,
                constraints: _actionConstraints,
              );
            });
            ref
                .read(partyModeProvider.notifier)
                .recordCategoryRoll(category.id);
            _resetTimerForConstraints(_actionConstraints);
          },
          onRollStart: () {
            _timer?.cancel();
            _timer = null;
            setState(() {
              _rolledCategory = null;
              _rolledAction = null;
              _actionConstraints = [];
              _actionPoints = 0;
              _timerDurationSeconds = null;
              _timerRemainingSeconds = null;
            });
          },
          initialFacePath: initialFacePath,
          diceText: I18nKeys.instance.partyMode.roll.tr(),
          showButton: false,
          isEnabled: diceEnabled,
        ),
        const SizedBox(height: 32),
        AnimatedSize(
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeInOutCubic,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeInOutCubic,
            opacity: showIntroText ? 1.0 : 0.0,
            child: showIntroText
                ? Column(
                    children: [
                      Text(
                        I18nKeys.instance.partyMode.tapToRoll.tr(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ),
        _buildResultCard(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final partyState = ref.watch(partyModeProvider);
    final players = partyState.players;
    final scores = partyState.scores;
    final categories = ref.watch(categoryProvider.notifier).getCategories();
    final actions = ref.watch(actionProvider).actions;
    final currentCategory = ref.watch(categoryProvider).currentCategory;

    if (categories.isEmpty) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (players.isEmpty) {
      return AppBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Center(
            child: Text(
              I18nKeys.instance.partyMode.addPlayersToStart.tr(),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 18),
            ),
          ),
        ),
      );
    }

    final safeIndex = partyState.currentPlayerIndex.clamp(
      0,
      players.length - 1,
    );
    final currentPlayer = players[safeIndex];
    final initialFacePath =
        currentCategory?.imagePath ?? categories.first.imagePath;
    final hasActiveTimer = _timerDurationSeconds != null;
    final timerRemainingSeconds =
        _timerRemainingSeconds ?? _timerDurationSeconds ?? 0;
    final isTimerComplete = !hasActiveTimer || timerRemainingSeconds <= 0;
    final hasRolled = _rolledCategory != null;
    final isDoneEnabled = hasRolled && isTimerComplete;
    final diceEnabled = _rolledCategory == null;
    final showIntroText = _rolledCategory == null;

    final topSpacing = (MediaQuery.of(context).size.height * 0.035).clamp(
      16.0,
      32.0,
    );

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (int i = 0; i < players.length; i++)
                    _buildPlayerHeaderItem(
                      player: players[i],
                      score: i < scores.length ? scores[i] : 0,
                      isCurrent: i == safeIndex,
                    ),
                ],
              ),
            ),
            SizedBox(height: topSpacing),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, animation) {
                  if (_useSlideTransition) {
                    final offsetAnimation =
                        Tween<Offset>(
                          begin: const Offset(0.15, 0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        );
                    return SlideTransition(
                      position: offsetAnimation,
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  }
                  return FadeTransition(opacity: animation, child: child);
                },
                child: SingleChildScrollView(
                  key: ValueKey(currentPlayer.name),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildPlayerContent(
                    player: currentPlayer,
                    categories: categories,
                    actions: actions,
                    initialFacePath: initialFacePath,
                    diceEnabled: diceEnabled,
                    showIntroText: showIntroText,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _handlePass,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        I18nKeys.instance.partyMode.pass.tr(),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: isDoneEnabled ? _handleDone : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isDoneEnabled ? 1.0 : 0.5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFF5EDF), // rose neon
                                Color(0xFF6A5DFF), // violet RollIt!
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(999),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFFF3EDF,
                                ).withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              I18nKeys.instance.partyMode.done.tr(),
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
