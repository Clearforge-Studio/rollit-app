import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:rollit/helpers/error.dart';
import 'package:rollit/services/purchase.service.dart';

Future<void> handleBuy(
  BuildContext context,
  Future<BuyResult> Function() callback,
) async {
  try {
    final buyResult = await callback();

    if (!context.mounted) return;

    if (buyResult.status == BuyStatus.success) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Achat réussi ! Merci pour votre soutien."),
          duration: Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    if (buyResult.status == BuyStatus.cancelled) {
      return;
    }

    if (buyResult.status == BuyStatus.restored) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Achats restauré avec succès !"),
          duration: Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("L'achat n'a pas pu être complété."),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  } on PlatformException catch (e) {
    log('PlatformException: ${e.message}');
    if (!context.mounted) return;

    final errorMsg = purchaseErrorFromPlatformError(e);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  } on PurchasesError catch (e) {
    log('PurchasesError: ${e.message}');
    if (!context.mounted) return;
    final errorMsg = purchaseErrorFromPurchases(e);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  } catch (e) {
    log('Unexpected error: ${e.toString()}');
    if (!context.mounted) return;

    log(e.toString());

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Une erreur inattendue est survenue."),
        duration: Duration(seconds: 2),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  return;
}
