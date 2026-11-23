import 'package:flutter/foundation.dart';

// Clés SDK RevenueCat (publiques par conception : elles sont embarquées dans l'appli).
// Une seule source de vérité, quelle que soit la façon dont on construit l'appli (run, APK, AAB) :
//   - build debug   -> clé de TEST  (Test Store, commence par test_) ;
//   - build release -> clé de PRODUCTION (Google Play, commence par goog_).
// Si l'une des deux est vide (ou si les deux sont identiques), la COMPILATION échoue, même en
// release : impossible d'envoyer un build sans la bonne clé.

const String _revenueCatTestKey = 'test_zqxbvPnOFTQMUbUCkVNthkflryO';
const String _revenueCatProdKey = 'goog_szpCTGDwZVBQAILjcecbxflKsaS';

class _RequireRevenueCatKeys {
  const _RequireRevenueCatKeys(String test, String prod)
    : assert(test != '', 'Clé RevenueCat de TEST manquante (lib/config.dart)'),
      assert(
        prod != '',
        'Clé RevenueCat de PRODUCTION manquante (lib/config.dart)',
      ),
      assert(
        test != prod,
        'Les clés RevenueCat de test et de production sont identiques (lib/config.dart)',
      );
}

// Évalué à la compilation : échoue si une clé manque.
// ignore: unused_element
const _revenueCatKeysCheck = _RequireRevenueCatKeys(
  _revenueCatTestKey,
  _revenueCatProdKey,
);

/// Clé RevenueCat à utiliser : test en debug, production sinon.
const String revenueCatApiKey = kDebugMode
    ? _revenueCatTestKey
    : _revenueCatProdKey;
