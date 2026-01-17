import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';

enum UpdateCheckResult { updateStarted, noUpdate, notSupported, failed }

class UpdateService {
  static bool _didCheck = false;

  static Future<UpdateCheckResult> checkForUpdates({
    bool force = false,
  }) async {
    if (_didCheck && !force) return UpdateCheckResult.noUpdate;
    _didCheck = true;

    if (kIsWeb || !Platform.isAndroid) {
      return UpdateCheckResult.notSupported;
    }

    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability ==
          UpdateAvailability.developerTriggeredUpdateInProgress) {
        await InAppUpdate.completeFlexibleUpdate();
        return UpdateCheckResult.updateStarted;
      }

      if (info.updateAvailability == UpdateAvailability.updateAvailable &&
          info.flexibleUpdateAllowed) {
        final result = await InAppUpdate.startFlexibleUpdate();
        if (result != AppUpdateResult.success) {
          return UpdateCheckResult.failed;
        }
        await InAppUpdate.completeFlexibleUpdate();
        return UpdateCheckResult.updateStarted;
      }
      return UpdateCheckResult.noUpdate;
    } catch (e) {
      log('Update check failed: $e');
      return UpdateCheckResult.failed;
    }
  }
}
