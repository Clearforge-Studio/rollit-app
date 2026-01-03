import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rollit/models/dice_category.model.dart';
import 'package:rollit/providers/category.provider.dart';
import 'package:rollit/providers/party_mode.provider.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:rollit/services/ads.service.dart';
import 'package:rollit/widgets/add_players/avatar_utils.dart';
import 'package:rollit/widgets/app_background.widget.dart';

class PartyModeResultScreen extends ConsumerStatefulWidget {
  const PartyModeResultScreen({super.key});

  @override
  ConsumerState<PartyModeResultScreen> createState() =>
      _PartyModeResultScreenState();
}

class _PartyModeResultScreenState extends ConsumerState<PartyModeResultScreen> {
  final Random _random = Random();
  String? _highlightCategoryId;

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    if (hours > 0) {
      final hoursText = hours.toString().padLeft(2, '0');
      return '$hoursText:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  String _categoryTitleForId(String id) {
    switch (id) {
      case DiceCategory.imitationCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleImitation.tr();
      case DiceCategory.challengeCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleChallenge.tr();
      case DiceCategory.challengeExtremeCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleChallengeExtreme
            .tr();
      case DiceCategory.funCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleFun.tr();
      case DiceCategory.wtfCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleWtf.tr();
      case DiceCategory.wtfPlusCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleWtfPlus.tr();
      case DiceCategory.miniGameCategory:
        return I18nKeys.instance.partyModeResult.categoryTitleMiniGame.tr();
      default:
        return I18nKeys.instance.partyModeResult.noData.tr();
    }
  }

  String _categoryLabelForId(List<DiceCategory> categories, String id) {
    for (final category in categories) {
      if (category.id == id) {
        return category.label;
      }
    }
    return id;
  }

  void _ensureHighlightCategory(
    List<DiceCategory> categories,
    Map<String, int> categoryCounts,
  ) {
    if (_highlightCategoryId != null) {
      return;
    }
    final available = categoryCounts.keys.isNotEmpty
        ? categoryCounts.keys.toList()
        : categories.map((category) => category.id).toList();
    if (available.isEmpty) {
      return;
    }
    final chosen = available[_random.nextInt(available.length)];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_highlightCategoryId != null) return;
      setState(() {
        _highlightCategoryId = chosen;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final partyState = ref.watch(partyModeProvider);
    final categories = ref.watch(categoryProvider.notifier).getCategories();
    _ensureHighlightCategory(categories, partyState.categoryRollCounts);

    final players = partyState.players;
    final scores = partyState.scores;
    final noDataLabel = I18nKeys.instance.partyModeResult.noData.tr();

    String winnerValue = noDataLabel;
    final winnerPlayers = <PartyPlayer>[];
    if (players.isNotEmpty && scores.isNotEmpty) {
      final maxScore = scores.reduce(max);
      final winnerNames = <String>[];
      for (int i = 0; i < players.length; i++) {
        if (i < scores.length && scores[i] == maxScore) {
          winnerNames.add(players[i].name);
          winnerPlayers.add(players[i]);
        }
      }
      if (winnerNames.isNotEmpty) {
        winnerValue = I18nKeys.instance.partyModeResult.winnerText.tr(
          namedArgs: {
            'name': winnerNames.join(', '),
            'score': maxScore.toString(),
          },
        );
      }
    }

    String mostPickedValue = noDataLabel;
    if (partyState.categoryRollCounts.isNotEmpty) {
      String? topCategoryId;
      int topCount = 0;
      partyState.categoryRollCounts.forEach((id, count) {
        if (count > topCount) {
          topCount = count;
          topCategoryId = id;
        }
      });
      if (topCategoryId != null) {
        final label = _categoryLabelForId(categories, topCategoryId!);
        mostPickedValue = I18nKeys.instance.partyModeResult.mostPickedText.tr(
          namedArgs: {'category': label, 'count': topCount.toString()},
        );
      }
    }

    String durationValue = noDataLabel;
    final startedAt = partyState.startedAt;
    if (startedAt != null) {
      final finishedAt = partyState.finishedAt ?? DateTime.now();
      durationValue = I18nKeys.instance.partyModeResult.durationText.tr(
        namedArgs: {
          'duration': _formatDuration(finishedAt.difference(startedAt)),
        },
      );
    }

    final highlightCategoryId = _highlightCategoryId;
    String highlightTitle = noDataLabel;
    String highlightValue = noDataLabel;
    final highlightPlayers = <PartyPlayer>[];
    if (highlightCategoryId != null) {
      highlightTitle = _categoryTitleForId(highlightCategoryId);
      final categoryLabel = _categoryLabelForId(
        categories,
        highlightCategoryId,
      );
      final playerCounts = partyState.playerCategoryRollCounts;
      int topCount = 0;
      final topPlayers = <String>[];
      for (int i = 0; i < players.length; i++) {
        final count = playerCounts[i]?[highlightCategoryId] ?? 0;
        if (count > topCount) {
          topCount = count;
          topPlayers
            ..clear()
            ..add(players[i].name);
          highlightPlayers
            ..clear()
            ..add(players[i]);
        } else if (count == topCount && count > 0) {
          topPlayers.add(players[i].name);
          highlightPlayers.add(players[i]);
        }
      }
      if (topPlayers.isNotEmpty) {
        highlightValue = I18nKeys.instance.partyModeResult.highlightText.tr(
          namedArgs: {
            'name': topPlayers.join(', '),
            'count': topCount.toString(),
            'category': categoryLabel,
          },
        );
      }
    }

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
            child: _buildResultFrame(
              title: I18nKeys.instance.partyModeResult.title.tr(),
              child: Column(
                children: [
                  _buildWinnerCard(
                    title: I18nKeys.instance.partyModeResult.winnerTitle.tr(),
                    value: winnerValue,
                    winners: winnerPlayers,
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    title: I18nKeys.instance.partyModeResult.mostPickedTitle
                        .tr(),
                    value: mostPickedValue,
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    title: I18nKeys.instance.partyModeResult.durationTitle.tr(),
                    value: durationValue,
                  ),
                  const SizedBox(height: 14),
                  _buildInfoCard(
                    title: highlightTitle,
                    value: highlightValue,
                    avatars: highlightPlayers,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildOutlineButton(
                          label: I18nKeys.instance.partyModeResult.backHome
                              .tr(),
                          onTap: () async {
                            await AdsService.instance
                                .tryShowPartyInterstitial();
                            if (!context.mounted) return;
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/home',
                              (route) => false,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildGradientButton(
                          label: I18nKeys.instance.partyModeResult.replay.tr(),
                          onTap: () async {
                            await AdsService.instance
                                .tryShowPartyInterstitial();
                            if (!context.mounted) return;
                            ref.read(partyModeProvider.notifier).restartGame();
                            Navigator.pushReplacementNamed(
                              context,
                              '/party_mode',
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultFrame({required String title, required Widget child}) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        CustomPaint(
          foregroundPainter: _ResultFrameBorderPainter(),
          child: ClipPath(
            clipper: _ResultFrameClipper(),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 110, 18, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B2BB8).withValues(alpha: 0.82),
                    const Color(0xFF3A0F62).withValues(alpha: 0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2B0B49).withValues(alpha: 0.6),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      letterSpacing: 1.2,
                      color: const Color(0xFFFFE7A0),
                    ),
                  ),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: -6,
          child: Image.asset(
            'assets/images/rollit_trophy_laurels-v2.png',
            width: 132,
            height: 132,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}

Widget _buildWinnerCard({
  required String title,
  required String value,
  required List<PartyPlayer> winners,
}) {
  final hasWinners = winners.isNotEmpty;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF6023AD).withValues(alpha: 0.7),
          const Color(0xFF3D0F66).withValues(alpha: 0.7),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: const Color(0xFFFFD36E).withValues(alpha: 0.55),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFFFE7A0),
          ),
        ),
        if (hasWinners) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final winner in winners)
                _buildWinnerAvatar(winner.avatarIndex),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildWinnerAvatar(int avatarIndex) {
  const borderColor = Color(0xFFFFD36E);
  final avatarUrl = avatarAssetForIndex(avatarIndex);
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 2),
      boxShadow: [
        BoxShadow(
          color: borderColor.withValues(alpha: 0.45),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: ClipOval(
      child: Image.asset(avatarUrl, width: 48, height: 48, fit: BoxFit.cover),
    ),
  );
}

Widget _buildInfoCard({
  required String title,
  required String value,
  List<PartyPlayer> avatars = const [],
}) {
  final hasAvatars = avatars.isNotEmpty;
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        colors: [
          const Color(0xFF5A21A1).withValues(alpha: 0.6),
          const Color(0xFF2E0A4B).withValues(alpha: 0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.16),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (hasAvatars) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final player in avatars)
                _buildWinnerAvatar(player.avatarIndex),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget _buildGradientButton({
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
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
            color: const Color(0xFFFF3EDF).withValues(alpha: 0.35),
            blurRadius: 18,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
    ),
  );
}

Widget _buildOutlineButton({
  required String label,
  required VoidCallback onTap,
}) {
  return OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    child: Text(
      label,
      style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 16),
    ),
  );
}

class _ResultFrameClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const notchWidth = 200.0;
    const notchHeight = 72.0;
    const notchDepth = 72.0;
    const cornerRadius = 12.0;
    final centerX = size.width / 2;
    final left = centerX - notchWidth / 2;
    final right = centerX + notchWidth / 2;

    final path = Path()
      ..moveTo(cornerRadius, notchHeight)
      ..lineTo(left - 8, notchHeight)
      ..quadraticBezierTo(left + 8, notchHeight, left + 18, notchHeight - 10)
      ..cubicTo(
        left + 36,
        notchHeight - 30,
        centerX - notchDepth,
        6,
        centerX,
        0,
      )
      ..cubicTo(
        centerX + notchDepth,
        6,
        right - 36,
        notchHeight - 30,
        right - 18,
        notchHeight - 10,
      )
      ..quadraticBezierTo(right - 8, notchHeight, right + 8, notchHeight)
      ..lineTo(size.width - cornerRadius, notchHeight)
      ..quadraticBezierTo(
        size.width,
        notchHeight,
        size.width,
        notchHeight + cornerRadius,
      )
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, notchHeight + cornerRadius)
      ..quadraticBezierTo(0, notchHeight, cornerRadius, notchHeight)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ResultFrameBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = _ResultFrameClipper().getClip(size);
    const strokeWidth = 2.0;
    final paint = Paint()
      ..color = const Color(0xFFB47CFF).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final bounds = path.getBounds();
    if (bounds.width <= strokeWidth || bounds.height <= strokeWidth) {
      canvas.drawPath(path, paint);
      return;
    }

    final scaleX = (bounds.width - strokeWidth) / bounds.width;
    final scaleY = (bounds.height - strokeWidth) / bounds.height;
    final matrix = Matrix4.identity()
      ..translate(bounds.center.dx, bounds.center.dy)
      ..scale(scaleX, scaleY)
      ..translate(-bounds.center.dx, -bounds.center.dy);
    final insetPath = path.transform(matrix.storage);
    canvas.drawPath(insetPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
