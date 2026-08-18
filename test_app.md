# Guide de Test Complet - XCongés

## Prérequis
1. Avoir Flutter installé et configuré
2. Avoir exécuté `flutter pub get`

## Tests à Effectuer

### 1. Test de l'écran de connexion
1. Lancer l'application : `flutter run`
2. Vérifier l'apparence de l'écran de login avec :
   - Logo "X" orange sur fond blanc
   - Titre "XCongés"
   - Sous-titre "Gestion des congés Xtensus"
   - Champs email et mot de passe
   - Liens "Mot de passe oublié" et "Créer un compte"
   - Bouton orange "Se connecter"

### 2. Test de création de compte
1. Cliquer sur "Créer un compte"
2. Vérifier le formulaire d'inscription avec :
   - Tous les champs requis (nom, prénom, email, matricule, département, mot de passe, confirmation)
   - Validation des champs
   - Bouton orange "Créer mon compte"
3. Créer un compte avec des données de test :
   - Nom : "Dupont"
   - Prénom : "Jean"
   - Email : "jean.dupont@xtensus.com"
   - Matricule : "1234"
   - Département : "IT"
   - Mot de passe : "password123"

### 3. Test de récupération de mot de passe
1. Retourner à l'écran de login
2. Cliquer sur "Mot de passe oublié ?"
3. Vérifier l'écran avec :
   - Icône de cadenas orange
   - Formulaire d'email
   - Bouton "Envoyer le lien"
4. Tester avec l'email créé précédemment

### 4. Test de connexion et navigation
1. Retourner à l'écran de login
2. Se connecter avec le compte créé :
   - Email : "jean.dupont@xtensus.com"
   - Mot de passe : "password123"
3. Vérifier la navigation vers l'écran principal avec onglets

### 5. Test du Dashboard (Onglet Accueil)
1. Vérifier l'affichage :
   - Header sombre avec salutation et initiales
   - Carte "Solde disponible" avec nombre de jours
   - Statistiques colorées : En attente (3), Approuvés (7), Refusés (1)
   - Notification de dernière activité
2. Tester la navigation entre onglets

### 6. Test de l'onglet "Nouvelle demande"
1. Aller sur l'onglet "Nouvelle"
2. Tester les fonctionnalités :
   - Sélection type : "Congé" ou "Autorisation d'absence"
   - Pour les congés :
     - Dropdown "Nature du congé" (Annuel, Exceptionnel, Maladie, Autre)
     - Sélection dates de début et fin
     - Calcul automatique des jours ouvrés
   - Pour les autorisations d'absence :
     - Sélection d'une date
     - Sélection heures de début et fin
   - Champ commentaire optionnel
   - Bouton "Envoyer la demande"
3. Soumettre une demande de test

### 7. Test de l'onglet "Historique"
1. Aller sur l'onglet "Historique"
2. Vérifier l'affichage des demandes :
   - Liste des demandes avec titre, dates et statut
   - Badges colorés pour les statuts (orange, vert, rouge)
   - Informations détaillées (nombre de jours, commentaires)
3. Après soumission d'une nouvelle demande, vérifier qu'elle apparaît dans l'historique

### 8. Test de l'onglet "Profil"
1. Aller sur l'onglet "Profil"
2. Vérifier l'affichage :
   - Avatar avec initiales sur fond orange
   - Nom et poste de l'utilisateur
   - Informations : Matricule, Département, Email (en orange)
   - Options : Mode sombre (switch), À propos, Déconnexion
3. Tester le bouton d'édition (icône crayon)

### 9. Test d'édition de profil
1. Cliquer sur l'icône d'édition dans le profil
2. Vérifier le formulaire complet :
   - Avatar avec bouton "Ajouter une photo"
   - Section "Informations personnelles" :
     - Prénom, Nom, Date de naissance, Téléphone, Adresse
   - Section "Informations professionnelles" :
     - Poste, Matricule (désactivé), Département, Email (désactivé)
   - Bouton "Supprimer le compte" (rouge)
3. Tester les interactions :
   - Modification des champs
   - Sélection de date de naissance
   - Bouton "Ajouter une photo" (modal avec options)
   - Bouton "Enregistrer" dans la AppBar
   - Dialogue de confirmation de sauvegarde
   - Bouton "Supprimer le compte" avec dialogue de confirmation

### 10. Test de déconnexion
1. Depuis le profil, cliquer sur "Déconnexion"
2. Confirmer dans le dialogue
3. Vérifier le retour à l'écran de login

### 11. Test des fonctionnalités avancées
1. **Calcul automatique des jours** :
   - Créer une demande de congé du lundi au vendredi
   - Vérifier que le calcul exclut les weekends
2. **Validation des formulaires** :
   - Tester la soumission avec champs vides
   - Vérifier les messages d'erreur
3. **États de chargement** :
   - Observer les indicateurs de progression lors des actions
4. **Navigation** :
   - Tester la navigation entre tous les écrans
   - Vérifier la cohérence de la navigation

## Points de Vérification Visuelle

### Conformité aux Maquettes
- ✅ Palette de couleurs orange/blanc/gris respectée
- ✅ Navigation par onglets en bas identique aux captures
- ✅ Layout et disposition des éléments conformes
- ✅ Typographie et tailles de police cohérentes
- ✅ Icônes et éléments d'interface conformes

### Responsive Design
- Tester sur différentes tailles d'écran
- Vérifier le comportement en mode portrait/paysage

## Problèmes Connus
- Les warnings d'analyse sont principalement des dépréciations Flutter (non bloquants)
- Le mode sombre n'est pas encore implémenté
- Les fonctionnalités photo nécessitent des plugins supplémentaires

## Prochaines Étapes
- Ajouter le vrai logo Xtensus
- Implémenter la persistance des données
- Intégrer avec un backend
- Ajouter les notifications push
- Implémenter les fonctionnalités administrateur