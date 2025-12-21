# Cahier des Charges – Rollit (V1)

## 1. Résumé du projet

Rollit est une application mobile destinée à animer les soirées entre amis.
Le principe : l’utilisateur lance deux dés virtuels qui génèrent une combinaison _Catégorie + Action_, affichée sous forme de carte.
La V1 se veut simple, rapide à développer, et servira de base à une évolution premium (mode Couple).

---

## 2. Objectifs

### 2.1 Objectifs fonctionnels

-   Permettre à l'utilisateur de lancer deux dés virtuels.
-   Animer le lancer avec une animation légère.
-   Générer une action basée sur la catégorie tirée.
-   Afficher une carte résultat avec : icône, catégorie, action, bouton relancer.
-   Proposer un menu avec :
    -   Packs premium
    -   Suppression de la publicité
    -   Paramètres (langue, vibration, sons)
    -   À propos
-   Intégrer de la publicité (AdMob).
-   Intégrer les achats intégrés (packs + retrait pub).
-   Utiliser un stockage local (JSON) pour les données du jeu.

### 2.2 Objectifs business

-   Monétiser via :
    -   Packs premium (WTF+, Défis Extrêmes…)
    -   Suppression des publicités
    -   Packs futurs liés au mode Couple
-   Lancer une V1 minimaliste afin de valider la traction rapidement.
-   Préparer une base évolutive permettant d’ajouter facilement de nouveaux contenus.

---

## 3. Public cible

-   Adultes 18–35 ans
-   Groupes d’amis en soirée
-   Étudiants
-   Familles (selon packs)
-   Couples (pour la version 2)

---

## 4. Plateformes visées

-   Android (prioritaire)
-   iOS (optionnel en V2)

Technologie : Flutter (cross-platform).

---

## 5. Fonctionnalités de la V1

### 5.1 Écran d’accueil

-   Affichage du logo Rollit.
-   Gros bouton “Lancer les dés”.
-   Accès au menu via icône hamburguer.

### 5.2 Lancer de dés

-   Animation légère de deux dés stylisés.
-   Résultat : Catégorie + Action.

### 5.3 Écran résultat

-   Icône de la catégorie.
-   Nom de la catégorie.
-   Texte de l’action.
-   Bouton “Relancer”.
-   Option de partage (optionnel).

### 5.4 Menu (navigation)

-   Packs Premium
-   Retirer les pubs
-   Langue
-   Sons / Vibration
-   À propos

### 5.5 Boutique (IAP)

-   Pack “WTF+”
-   Suppression des pubs
-   Packs “à venir” affichés pour teasing
-   Intégration Google Play Billing

### 5.6 Publicités

-   AdMob interstitiel toutes les 3 à 5 cartes.
-   Possibilité de désactiver via achat.

### 5.7 Gestion des données

-   Stockage local JSON :
    -   Liste des catégories
    -   Actions par catégorie
-   Aucune inscription nécessaire.
-   Pas de backend pour la V1.

---

## 6. Contenu du jeu

### 6.1 Catégories initiales

-   Imitation
-   Défi
-   Question Fun
-   WTF
-   Mini-jeux

### 6.2 Volume de contenu

-   15 à 20 actions par catégorie
-   Total cible : 80 à 100 actions

---

## 7. Design & UX

### 7.1 Style visuel

-   Style “fun premium”
-   Couleurs pastel / bleus / violets / menthe
-   Dés stylisés, arrondis, avec ombres douces
-   Interfaces légères, modernes, lisibles

### 7.2 UX

-   Navigation minimaliste
-   Temps d’accès à une action < 2 secondes
-   Animations légères (rebond, fade-in/out)
-   Large bouton principal

---

## 8. Architecture technique

### 8.1 Stack

-   Flutter (Dart)
-   JSON local pour le contenu
-   Google AdMob
-   Google Billing (IAP)

### 8.2 Organisation des fichiers

```
assets/
  images/
lib/
  main.dart
  models/
      category.dart
      action.dart
  screens/
      home_screen.dart
      result_screen.dart
      settings_screen.dart
      store_screen.dart
  widgets/
      dice_widget.dart
      action_card.dart
  services/
      ads_service.dart
      purchase_service.dart
      random_service.dart
      data_service.dart
  data/
      categories.json
      actions.json
```

---

## 9. Roadmap de développement (7 à 10 jours)

### Jour 1

-   Setup du projet Flutter
-   Architecture initiale
-   Création des JSON

### Jour 2

-   Écran Home
-   Style + bouton principal

### Jour 3

-   Animation des dés
-   Logique de randomisation

### Jour 4

-   Écran résultat
-   UI + carte

### Jour 5

-   Intégration AdMob

### Jour 6

-   Achats intégrés (IAP)

### Jour 7

-   Boutique + gestion des packs

### Jours 8–9

-   Tests, optimisations, polish

### Jour 10

-   Build Android (.aab)
-   Préparation fiche Google Play (ASO)

---

## 10. Évolutions prévues

### Version 1.5

-   Nouveaux packs premium
-   Packs saisonniers
-   Nouveaux effets visuels
-   Sons / vibrations supplémentaires

### Version 2 – Mode Couple

-   Catégories dédiées aux couples
-   Packs Romantique / Intimité+
-   Interface dédiée (plus premium)
-   Actions adaptées

### Version 3

-   Mode multijoueur simple (optionnel)

### Version 4

-   Backend pour packs dynamiques
-   Statistiques utilisateur
-   Synchronisation cloud

---

## 11. Branding

-   Nom : Rollit
-   Style : Fun + premium
-   Logo : Dé stylisé avec flèche vers le haut
-   Typographie arrondie, lisible, moderne

---

## 12. Contraintes & risques

-   Trop de publicité peut réduire la rétention
-   Contenu limité = mise à jour fréquente nécessaire
-   Contenu adulte strictement interdit en V1 pour conformité Play Store
-   App doit rester simple visuellement (une action principale)

---
