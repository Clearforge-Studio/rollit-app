# Cahier des Charges – Rollit (Etat reel pre-release)

## 1. Objet du document

Ce CDC decrit l'etat actuel de l'application Rollit (pre-release), en remplacement de l'ancien CDC V1 qui n'etait plus aligne avec le produit.

---

## 2. Vision produit

Rollit est un jeu mobile de soiree avec deux experiences:

- Mode classique (solo/groupe libre): tirage d'une categorie + action.
- Mode party (multijoueur local): gestion de joueurs, tours, points, manches et ecran de fin de partie.

Objectif principal: proposer des parties rapides, fun, monétisables sans bloquer la progression de base.

---

## 3. Plateformes et stack

- Framework: Flutter (Dart)
- Plateformes cibles: Android (prioritaire), iOS (supporte), Web non cible
- Etat UI systeme: edge-to-edge active
- Donnees de jeu: JSON local (pas de backend)

Dependances clefs:

- State management: Riverpod
- I18n: easy_localization
- Ads: Google Mobile Ads (interstitial + rewarded)
- IAP: RevenueCat (`purchases_flutter`)
- Update Android: `in_app_update` (mode flexible non bloquant)

---

## 4. Parcours utilisateur

### 4.1 Home

- Affichage logo/titre.
- De principal pour lancer le mode classique.
- Bouton secondaire vers le mode party.
- Acces Settings.

### 4.2 Mode classique

- Ecran resultat affichant categorie + action.
- Relance via de.
- Gestion des contraintes d'action (ex: duree).
- Bouton "Demarrer le chrono" quand une contrainte `duration` existe.
- Traduction des noms de categories et des textes d'action.

### 4.3 Mode party - Lobby joueurs

- Min 2 joueurs pour commencer, max 8.
- Ajout joueur via carte brouillon (nom + avatar).
- Creation automatique d'une 2e carte apres validation du 1er joueur (fluidifier l'ajout minimum).
- Bouton "+" grise et desactive si une carte d'ajout est deja en cours.
- Choix du nombre de manches: 3, 5, 10, ou personnalise (1 a 99).

### 4.4 Mode party - Partie

- Un joueur actif a la fois, avec avatars/scores en header.
- Progression manches affichee en `x/x`.
- Actions possibles:
  - `Passe`: 0 point.
  - `Termine`: validation et attribution de points.
- Chrono optionnel selon contrainte `duration`.

### 4.5 Mode party - Reroll

- Regle: 1 seul reroll autorise par tour.
- Non premium Android: reroll via rewarded ad.
- Premium: reroll direct sans pub.
- Comportement: tap reroll -> pub -> retour pub -> relance automatique du de.

### 4.6 Fin de partie party

Carte de resultat affichant:

- Gagnant (nom + score + avatar(s) en cas d'egalite).
- Categorie la plus tiree.
- Duree de partie.
- Carte highlight categorie avec joueur ayant le plus tire cette categorie (avatar inclus).

Actions:

- Retour accueil.
- Rejouer.

Les deux actions peuvent declencher l'interstitiel party (selon cadence, voir section Ads).

---

## 5. Regles de score party

Le score n'est plus binaire (0/1). Les points dependent de la difficulte:

- Base par categorie:
  - `imitation`, `fun`: 1 point
  - `challenge`, `wtf`, `mini_game`: 2 points
  - `challenge_extreme`, `wtf_plus`: 3 points
- Bonus duree (`duration`):
  - >= 10s: +1
  - >= 20s: +2

Le nombre de points accordes est affiche sur la carte action party (`+X pts`).

---

## 6. Monétisation (IAP)

Entitlements RevenueCat:

- `wtf_plus`
- `challenge_extreme`
- `remove_ads`

Regle importante:

- `adsRemoved = true` si `remove_ads` est actif **ou** si un pack premium (`wtf_plus` ou `challenge_extreme`) est possede.

Ecrans/tuiles:

- Store dedie.
- Paywall global (packs + remove ads).
- Etat "achete" visible sur les produits deja possedes.

Affichage paywall global:

- Declenche apres seuil de rolls (49), une seule fois, et uniquement s'il reste des packs a acheter.

---

## 7. Publicites

### 7.1 Interstitiel standard

- Cadence: 1 interstitiel toutes les 10 actions (rolls).
- Desactive si ads retirees/premium.

### 7.2 Interstitiel party de fin de partie

- Declenche apres fin de game party:
  - 1re partie terminee: affiche
  - puis toutes les 3 parties (1, 4, 7, ...)
- Verifie au tap "Retour" ou "Rejouer" sur l'ecran resultat party.

### 7.3 Rewarded (reroll party)

- Android uniquement.
- Utilise pour reroll non premium.
- 1 seule utilisation par tour.

---

## 8. Settings (reorganises)

Sections distinctes:

- Preferences: son, vibration, langue.
- Categories: activation/desactivation par categorie (au moins 1 active).
- Store: boutique, retirer pubs, restaurer achats.
- Support: contacter support, suggerer fonctionnalite, partager l'app.
- Communaute: noter l'app, autres applications du studio.
- Legal: politique de confidentialite, preferences pub/consentement.
- A propos: dialogue a propos, version `build` incluse.

Liens support/communaute:

- Support: `support@clearforgestudio.com`
- Partage Android: URL Play Store de l'app
- Autres applications Android: page developpeur Play Store Clearforge Studio

---

## 9. Mises a jour in-app

- Verification auto au lancement + bouton manuel en Settings.
- Android: in-app update flexible (non bloquante).
- Si MAJ dispo et autorisee: telechargement puis completion de l'update.

---

## 10. Internationalisation

- Langues supportees: francais, anglais.
- Choix de langue via dialogue dedie (drapeau + nom natif).
- Clefs i18n presentes pour:
  - categories
  - actions
  - party mode / resultat
  - settings / store / paywalls
  - messages d'erreur achat

---

## 11. UX / Navigation

- Transitions slide entre:
  - Home -> Lobby (add players)
  - Lobby -> Party mode
  - Party mode -> Resultat fin de partie
- Ecrans principaux proteges par `SafeArea` pour l'edge-to-edge.

---

## 12. Hors perimetre actuel

- Backend distant (stats cloud, synchro).
- Mode couple dedie.
- Contenu dynamique serveur.

---

## 13. Ecart corrige vs ancien CDC

Points majeurs corriges dans ce document:

- Le jeu ne repose pas sur "deux des virtuels"; le flux actuel est base sur un de/categorie + action.
- Le menu hamburger n'est pas le pattern principal (settings via icone, ecrans dedies).
- Le mode party (lobby, tours, scores, fin de partie) est maintenant une fonctionnalite centrale.
- La logique ads/paywall est precisee selon implementation reelle (cadences + exclusions premium).
- Le systeme de points est detaille par difficulte et contraintes.
