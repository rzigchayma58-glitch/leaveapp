# 🕐 Guide des Validations de Délai de Préavis

## 📋 **Règles Implémentées**

- **Autorisation d'absence** : 
  - ⏰ minimum **48 heures** à l'avance
  - 🕒 maximum **2 heures** de durée
- **Demande de congé** : minimum **72 heures** à l'avance

## 🧪 **Tests à Effectuer**

### **1. Test d'Autorisation d'Absence - Durée (Nouvelle Validation)**

#### ✅ **Cas Valides**
1. **Courte durée** :
   - Date : dans 3 jours
   - Heure : 09:00 → 10:30 (1h30)
   - **Résultat** : ✅ "Délai respecté" + "Durée : 1h 30min"

2. **Durée limite** :
   - Date : dans 3 jours  
   - Heure : 14:00 → 16:00 (2h exactement)
   - **Résultat** : ✅ "Délai respecté" + "Durée : 2h"

#### ❌ **Cas Invalides**
1. **Durée trop longue** :
   - Date : dans 3 jours
   - Heure : 09:00 → 12:00 (3h)
   - **Résultat** : ⚠️ "Durée trop longue (3.0 h). Maximum autorisé : 2 heures"

2. **Heure incohérente** :
   - Date : dans 3 jours
   - Heure : 09:27 → 01:27 (heure de fin avant début)
   - **Résultat** : ⚠️ "L'heure de fin doit être après l'heure de début"

### **2. Test de Congé (72h minimum)**

#### ✅ **Cas Valide**
1. Sélectionner "Congé"
2. Choisir une date dans 4 jours ou plus
3. **Résultat attendu** :
   - ✅ Message vert : "Délai de préavis respecté (minimum 72h)"
   - Calcul des jours ouvrés affiché
   - Possibilité d'envoyer la demande

#### ❌ **Cas Invalide**
1. Sélectionner "Congé"
2. Choisir une date dans 2 jours (< 72h)
3. **Résultat attendu** :
   - ⚠️ Message rouge : "Les congés doivent être demandés au minimum 72 heures à l'avance"
   - "Il reste encore X heures avant le délai minimum"
   - Blocage de la soumission

## 🎯 **Fonctionnalités Visuelles**

### **Interface de Validation**
- **Zone verte** ✅ : Tout valide
  - Icône check_circle verte
  - Texte confirmant le délai + durée pour autorisations
  - Fond vert clair

- **Zone rouge** ⚠️ : Problème détecté
  - Icône warning/schedule rouge selon l'erreur
  - Messages séparés pour délai et durée
  - Fond rouge clair avec bordure

### **Calculs en Temps Réel**
- **Mise à jour automatique** lors de la sélection d'heure
- **Affichage de la durée** calculée automatiquement
- **Validation instantanée** des plages horaires

## 🔍 **Scénarios de Test Détaillés**

### **Test 1 : Autorisation - Durée OK, Délai OK**
```
Aujourd'hui : Lundi 10/08/2026 à 14:00
Date demandée : Jeudi 13/08/2026
Heures : 10:00 → 11:30 (1h30)
Résultats : 
- ✅ Délai : 68h > 48h → VALIDE
- ✅ Durée : 1h30 < 2h → VALIDE
- Affichage : "Délai respecté + Durée : 1h 30min"
```

### **Test 2 : Autorisation - Durée Limite**
```
Aujourd'hui : Lundi 10/08/2026 à 14:00  
Date demandée : Jeudi 13/08/2026
Heures : 14:00 → 16:00 (2h exactement)
Résultats :
- ✅ Délai : 68h > 48h → VALIDE  
- ✅ Durée : 2h = limite → VALIDE
- Affichage : "Délai respecté + Durée : 2h"
```

### **Test 3 : Autorisation - Durée Dépassée**
```
Aujourd'hui : Lundi 10/08/2026 à 14:00
Date demandée : Jeudi 13/08/2026  
Heures : 09:00 → 12:30 (3h30)
Résultats :
- ✅ Délai : 68h > 48h → VALIDE
- ❌ Durée : 3h30 > 2h → INVALIDE
- Erreur : "Durée trop longue (3.5 h). Maximum : 2 heures"
```

### **Test 4 : Autorisation - Heures Incohérentes**
```
Aujourd'hui : Lundi 10/08/2026 à 14:00
Date demandée : Jeudi 13/08/2026
Heures : 15:30 → 12:00 (fin avant début)
Résultats :
- ✅ Délai : 68h > 48h → VALIDE  
- ❌ Heures : Fin < Début → INVALIDE
- Erreur : "L'heure de fin doit être après l'heure de début"
```

### **Test 5 : Double Erreur**
```
Aujourd'hui : Lundi 10/08/2026 à 14:00
Date demandée : Mardi 11/08/2026 (24h)
Heures : 08:00 → 12:00 (4h)
Résultats :
- ❌ Délai : 24h < 48h → INVALIDE
- ❌ Durée : 4h > 2h → INVALIDE  
- Affichage : Les deux erreurs dans la même zone rouge
```

## ⚙️ **Architecture Technique**

### **Nouvelles Méthodes**
```dart
// Validation de durée
bool isValidAbsenceDuration(TimeOfDay start, TimeOfDay end)

// Calcul de durée en minutes  
int calculateAbsenceDurationMinutes(TimeOfDay start, TimeOfDay end)

// Validation de plage horaire
bool isValidTimeRange(TimeOfDay start, TimeOfDay end)

// Message d'erreur de durée
String? getAbsenceDurationError(TimeOfDay? start, TimeOfDay? end)
```

### **Logique de Calcul**
```dart
// Exemple : 09:30 → 11:45
startMinutes = 9 * 60 + 30 = 570 min
endMinutes = 11 * 60 + 45 = 705 min  
duration = 705 - 570 = 135 min = 2h15min
isValid = 135 <= 120 ? false (> 2h)
```

## 🚀 **Lancement des Tests**

```bash
flutter run
```

1. **Créer un compte** et se connecter
2. **Aller sur "Nouvelle demande"**
3. **Sélectionner "Autorisation d'absence"**
4. **Tester tous les scénarios** ci-dessus
5. **Observer les messages** en temps réel
6. **Essayer de soumettre** les demandes invalides

## 🎨 **Retour Visuel Attendu**

### **Validation Réussie (Autorisation)**
```
✅ [icône check verte] Délai de préavis respecté (minimum 48h)
   [icône horloge verte] Durée : 1h 30min
```

### **Erreur de Durée**  
```
⚠️ [icône horloge rouge] Durée trop longue (3.0 h). Maximum autorisé : 2 heures
```

### **Erreur d'Heures**
```
⚠️ [icône horloge rouge] L'heure de fin doit être après l'heure de début
```

### **Double Erreur**
```
⚠️ [icône warning rouge] Les autorisations d'absence doivent être demandées...
   Il reste encore 24 heures avant le délai minimum.
   [icône horloge rouge] Durée trop longue (4.0 h). Maximum autorisé : 2 heures
```

## 💡 **Cas Particuliers Gérés**

1. **Traversée de minuit** : Évitée (heure fin doit être après heure début le même jour)
2. **Durée zéro** : Invalide (durée > 0 requise)
3. **Calcul précis** : En minutes pour éviter les erreurs d'arrondi
4. **Affichage intelligent** : Format "2h 30min" ou "2h" selon le cas

## 🔧 **Points d'Amélioration Futurs**

1. **Plages autorisées** : Définir les heures de travail (ex: 8h-18h)
2. **Pauses déjeuner** : Exclure 12h-13h du calcul
3. **Demi-heures** : Forcer les créneaux de 30 minutes
4. **Validation métier** : Adapter selon le type de poste/département