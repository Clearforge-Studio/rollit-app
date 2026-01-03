import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rollit/services/i18n.service.dart';

String purchaseErrorFromPlatformError(PlatformException e) {
  final code = PurchasesErrorHelper.getErrorCode(e);

  switch (code) {
    case PurchasesErrorCode.purchaseNotAllowedError:
      return I18nKeys.instance.purchaseErrors.notAllowed.tr();
    case PurchasesErrorCode.storeProblemError:
      return I18nKeys.instance.purchaseErrors.storeProblem.tr();
    case PurchasesErrorCode.purchaseCancelledError:
      return I18nKeys.instance.purchaseErrors.cancelled.tr();
    default:
      return I18nKeys.instance.purchaseErrors.generic.tr();
  }
}

String purchaseErrorFromPurchases(PurchasesError error) {
  final code = error.code;

  switch (code) {
    case PurchasesErrorCode.purchaseNotAllowedError:
      return I18nKeys.instance.purchaseErrors.notAllowed.tr();
    case PurchasesErrorCode.storeProblemError:
      return I18nKeys.instance.purchaseErrors.storeProblem.tr();
    case PurchasesErrorCode.purchaseCancelledError:
      return I18nKeys.instance.purchaseErrors.cancelled.tr();
    case PurchasesErrorCode.paymentPendingError:
      return I18nKeys.instance.purchaseErrors.paymentPending.tr();
    case PurchasesErrorCode.productNotAvailableForPurchaseError:
      return I18nKeys.instance.purchaseErrors.productUnavailable.tr();
    case PurchasesErrorCode.invalidCredentialsError:
      return I18nKeys.instance.purchaseErrors.invalidCredentials.tr();
    case PurchasesErrorCode.networkError:
      return I18nKeys.instance.purchaseErrors.network.tr();
    case PurchasesErrorCode.invalidReceiptError:
      return I18nKeys.instance.purchaseErrors.invalidReceipt.tr();
    case PurchasesErrorCode.unknownBackendError:
      return I18nKeys.instance.purchaseErrors.unknownBackend.tr();
    case PurchasesErrorCode.invalidAppUserIdError:
      return I18nKeys.instance.purchaseErrors.invalidUser.tr();
    case PurchasesErrorCode.operationAlreadyInProgressError:
      return I18nKeys.instance.purchaseErrors.operationInProgress.tr();
    case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
      return I18nKeys.instance.purchaseErrors.receiptInUse.tr();
    case PurchasesErrorCode.missingReceiptFileError:
      return I18nKeys.instance.purchaseErrors.missingReceipt.tr();
    case PurchasesErrorCode.productAlreadyPurchasedError:
      return I18nKeys.instance.purchaseErrors.alreadyPurchased.tr();
    default:
      return I18nKeys.instance.purchaseErrors.generic.tr();
  }
}
