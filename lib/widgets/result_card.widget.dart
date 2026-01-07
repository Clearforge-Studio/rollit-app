import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rollit/services/i18n.service.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final localizedActionText = (actionText ?? '').tr();
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
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(22),
      constraints: const BoxConstraints(
        maxWidth: 650.0,
        minHeight: 140.0,
      ),
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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if ((title ?? '').isNotEmpty)
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            if ((title ?? '').isNotEmpty) const SizedBox(height: 8),
            Text(
              localizedActionText,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                label: Text(
                  I18nKeys.instance.result.startTimer.tr(),
                  style: GoogleFonts.poppins(
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
        style: GoogleFonts.poppins(
          color: baseColor,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
    );
  }
}
