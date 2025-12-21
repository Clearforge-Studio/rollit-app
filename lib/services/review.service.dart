import 'dart:developer';

import 'package:rollit/helpers/url.dart';
import 'package:rollit/services/preferences.service.dart';
import 'package:in_app_review/in_app_review.dart';

class ReviewService {
  static const int _minSessions = 3;
  static const int _minRollsForReview = 35;
  static const int _cooldownDays = 90;

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Call once per app launch
  static Future<void> registerSession() async {
    final sessions = PreferencesService.getSessionsCount();
    await PreferencesService.setSessionsCount(sessions + 1);
  }

  /// Call on each roll
  static Future<void> registerRoll() async {
    final rolls = PreferencesService.getRollsCount();
    await PreferencesService.setRollsCount(rolls + 1);
  }

  /// Check if we can ask for review
  static Future<bool> canAskForReview() async {
    final hasAsked = PreferencesService.getHasAskedForReview();
    if (hasAsked) return false;

    final sessions = PreferencesService.getSessionsCount();
    final rolls = PreferencesService.getRollsCount();

    log("ReviewService: sessions=$sessions, rolls=$rolls");

    if (sessions < _minSessions || rolls < _minRollsForReview) {
      return false;
    }

    final lastAskMillis = PreferencesService.getReviewLastAskMillis();
    if (lastAskMillis != null) {
      final lastAsk = DateTime.fromMillisecondsSinceEpoch(lastAskMillis);
      final diff = DateTime.now().difference(lastAsk).inDays;
      if (diff < _cooldownDays) return false;
    }

    return true;
  }

  static Future<void> requestReview() async {
    try {
      final isAvailable = await _inAppReview.isAvailable();

      if (isAvailable) {
        await _inAppReview.requestReview();
      } else {
        openStore();
      }
    } catch (_) {
      openStore();
    }
  }

  static void openStore() {
    openUrl(
      "https://play.google.com/store/apps/details?id=com.clearforge.rollit",
    );
  }

  /// Call when user clicks "Noter l’app"
  static Future<void> markAsAsked() async {
    await PreferencesService.setHasAskedForReview(true);
    await PreferencesService.setReviewLastAskMillis(
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Call when user clicks "Plus tard"
  static Future<void> markAsPostponed() async {
    await PreferencesService.setReviewLastAskMillis(
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
