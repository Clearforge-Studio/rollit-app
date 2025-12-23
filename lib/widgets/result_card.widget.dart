import 'package:flutter/material.dart';
import 'package:rollit/models/dice_action.model.dart';

class ResultCard extends StatelessWidget {
  final String? title;
  final Widget? icon;
  final String? actionText;
  final List<ActionConstraint> constraints;
  final int? timerDurationSeconds;
  final int? timerRemainingSeconds;
  final VoidCallback onStartTimer;

  const ResultCard({
    super.key,
    required this.title,
    required this.icon,
    required this.actionText,
    required this.constraints,
    required this.timerDurationSeconds,
    required this.timerRemainingSeconds,
    required this.onStartTimer,
  });

  String _formatConstraint(ActionConstraint constraint, {bool lite = false}) {
    final value = lite ? constraint.valueLite : constraint.value;
    if (value == null) {
      return '';
    }
    switch (constraint.type) {
      case 'duration':
        return '${value}s';
      case 'word_count':
        return '$value mots';
      default:
        return '$value ${constraint.type}';
    }
  }

  String _formatTimer(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final badgeWidgets = <Widget>[];
    for (final constraint in constraints) {
      if (constraint.type == 'duration') {
        continue;
      }
      final label = _formatConstraint(constraint);
      if (label.isNotEmpty) {
        badgeWidgets.add(_ConstraintBadge(label: label));
      }
      if (constraint.valueLite != null &&
          constraint.valueLite != constraint.value) {
        final liteLabel = _formatConstraint(constraint, lite: true);
        if (liteLabel.isNotEmpty) {
          badgeWidgets.add(
            _ConstraintBadge(label: 'Lite $liteLabel', isLite: true),
          );
        }
      }
    }

    final showStartButton =
        timerDurationSeconds != null && timerRemainingSeconds == null;
    final showCountdown = timerRemainingSeconds != null;
    final isEndingSoon = showCountdown && (timerRemainingSeconds ?? 0) <= 3;
    final timerColor =
        isEndingSoon ? const Color(0xFFFF6B6B) : Colors.white;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 28),
      padding: const EdgeInsets.all(26),
      constraints: BoxConstraints(
        maxWidth: 650.0,
        minHeight: MediaQuery.of(context).size.height * 0.425,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF3F147C), // violet intense
            Color(0xFF2A0D56),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),

        // glow externe
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7B2CFF).withValues(alpha: 0.55),
            blurRadius: 35,
            spreadRadius: 2,
          ),
        ],

        // contour néon
        border: Border.all(color: const Color(0xFF7F3DFF), width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 28,
          children: [
            // --- TITRE ---
            Text(
              title?.toUpperCase() ?? '',
              style: const TextStyle(
                height: 1.3,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Color(0xFFFFE148), // jaune pastel
                letterSpacing: 1.1,
              ),
            ),

            // --- ICON EMBOSSED ---
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B2FE5), Color(0xFF3C167D)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (rect) {
                  return const LinearGradient(
                    colors: [Color(0xFFB9A7FF), Color(0xFF7D52E0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(rect);
                },
                blendMode: BlendMode.srcATop,
                child: icon,
              ),
            ),

            // --- TEXTE D’ACTION ---
            Text(
              actionText ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
            if (showStartButton)
              TextButton.icon(
                onPressed: onStartTimer,
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
                label: const Text(
                  'Démarrer le chrono',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            if (showCountdown)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    Icon(
                      Icons.timer_outlined,
                      color: timerColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimer(timerRemainingSeconds ?? 0),
                      style: TextStyle(
                        color: timerColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            if (badgeWidgets.isNotEmpty)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: badgeWidgets,
              ),
          ],
        ),
      ),
    );
  }
}

class _ConstraintBadge extends StatelessWidget {
  final String label;
  final bool isLite;

  const _ConstraintBadge({required this.label, this.isLite = false});

  @override
  Widget build(BuildContext context) {
    final baseColor = isLite ? const Color(0xFF7C4DFF) : Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withValues(alpha: isLite ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: baseColor.withValues(alpha: 0.6), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
