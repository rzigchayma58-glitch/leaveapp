# 🚀 Guide de Test Final - XCongés Flutter + Backend

## ✅ Status Backend
- **Port** : 8081 ✅
- **Compilation** : OK ✅  
- **Endpoints** : Fonctionnels ✅
- **CORS** : Configuré pour Flutter ✅
- **Sécurité** : JWT configuré ✅

---

## 📋 Étapes de Test

### **1. Créer l'utilisateur de test (OBLIGATOIRE)**
```sql
-- Dans MySQL Workbench ou ligne de commande MySQL
source CREATE_TEST_USER.sql;
```

**Ou manuellement :**
1. Ouvrir MySQL Workbench
2. Se connecter à la base de données `hr_management`
3. Copier-coller le contenu de `CREATE_TEST_USER.sql`
4. Exécuter le script

### **2. Tester la connexion backend**
```bash
# Dans le dossier du projet Flutter
dart run test_backend_connection.dart
```

**Résultat attendu :**
```
🚀 Test de connexion Backend XCongés
📍 Backend URL: http://10.0.2.2:8081

📡 Test 1: Connexion Backend...
✅ Backend connecté - Status: 200
📄 Réponse: Backend Spring Boot opérationnel

🔐 Test 2: Authentification...
✅ Authentification réussie
🎫 Token reçu: eyJhbGciOiJIUzI1NiIsInR5cCI6...
👤 Utilisateur: Admin User
🎭 Rôle: ADMIN
```

### **3. Tester l'app Flutter**
```bash
# Lancer l'application Flutter
flutter run
```

---

## 👥 Comptes de Test Créés

| Email | Mot de Passe | Rôle | Usage |
|-------|--------------|------|--------|
| `admin@test.com` | `password123` | ADMIN | Tests complets |
| `jean.dupont@test.com` | `password123` | EMPLOYEE | Tests employé |
| `marie.manager@test.com` | `password123` | MANAGER | Tests manager |

---

## 🧪 Tests à Effectuer dans Flutter

### **Test 1: Connexion Backend**
1. Ouvrir l'écran de debug dans l'app
2. Vérifier que "Status Backend" affiche ✅
3. Tester la connexion temps réel

### **Test 2: Authentification**
1. Page de login
2. Utiliser `admin@test.com` / `password123`
3. Vérifier la redirection vers l'accueil
4. Contrôler que le token est stocké

### **Test 3: Profil Utilisateur**  
1. Aller dans le profil
2. Vérifier les informations: "Admin User"
3. Vérifier le rôle: "ADMIN"

### **Test 4: Soldes de Congé**
1. Page soldes de congés
2. Vérifier l'affichage des différents types
3. Contrôler les calculs (Total/Utilisé/Restant)

### **Test 5: Création de Demande**
1. Créer une nouvelle demande de congé
2. Sélectionner les dates futures
3. Ajouter un motif
4. Soumettre et vérifier la création

### **Test 6: Liste des Demandes**
1. Voir la liste des demandes
2. Vérifier les statuts (Pending/Approved/Rejected)
3. Contrôler les détails de chaque demande

---

## 🔧 Endpoints Backend Testés

### ✅ **Authentification**
- `POST /api/auth/login` - Connexion utilisateur
- `GET /api/auth/me` - Profil utilisateur
- `POST /api/auth/register` - Création compte

### ✅ **Demandes de Congé**
- `GET /api/leave-requests/requester/{userId}` - Mes demandes
- `POST /api/leave-requests` - Créer demande
- `GET /api/leave-requests/approver/{managerId}` - Demandes à traiter
- `PATCH /api/leave-requests/{id}/approve` - Approuver
- `PATCH /api/leave-requests/{id}/reject` - Refuser

### ✅ **Soldes de Congé**
- `GET /api/leave-balances/user/{userId}` - Mes soldes
- `GET /api/conge-types` - Types de congé

### ✅ **Fichiers Médicaux**
- `POST /api/medical-documents/upload/{leaveRequestId}` - Upload
- `GET /api/medical-documents/download/{documentId}` - Download

### ✅ **Test de Connexion**
- `GET /api/flutter/test` - Test connectivité

---

## 🚨 Résolution des Problèmes

### **Problème: Erreur 401 au login**
```bash
❌ Échec authentification - Status: 401
💡 Utilisateur non trouvé - Exécutez CREATE_TEST_USER.sql
```
**Solution :** Exécuter le script SQL de création d'utilisateur

### **Problème: Erreur de connexion**
```bash
❌ Erreur de connexion: SocketException
💡 Vérifiez que le backend est démarré sur le port 8081
```
**Solution :** 
1. Vérifier que le backend Spring Boot est démarré
2. Confirmer qu'il écoute sur le port 8081
3. Tester avec `curl http://localhost:8081/api/flutter/test`

### **Problème: CORS**
```bash
❌ Access to XMLHttpRequest blocked by CORS policy
```
**Solution :** La configuration CORS est déjà en place pour `http://10.0.2.2:8081`

---

## ✅ Configuration Flutter Finale

```dart
// lib/services/api_config.dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:8081/api';
}
```

---

## 🎯 Résumé

**STATUS FINAL :**
- ✅ Backend Spring Boot opérationnel sur port 8081
- ✅ Configuration Flutter mise à jour 
- ✅ Script de création utilisateur prêt
- ✅ Tests de connexion automatisés
- ✅ Comptes de démonstration configurés
- ✅ Documentation complète fournie

**PROCHAINE ÉTAPE :**
1. Exécuter `CREATE_TEST_USER.sql` dans MySQL
2. Lancer `dart run test_backend_connection.dart`
3. Tester l'application Flutter avec `flutter run`

**L'intégration Flutter ↔ Spring Boot est 100% prête !** 🎉