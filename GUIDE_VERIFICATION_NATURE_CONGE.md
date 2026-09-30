# 🔍 GUIDE VÉRIFICATION - Nature du Congé

## 🚨 **PROBLÈME OBSERVÉ**
D'après ton image : "Aucun type de congé disponible" avec icône ℹ️ quand tu cliques sur "Congé".

## 🛠️ **OUTILS DE DEBUG AJOUTÉS**

### **1. Écran Debug Dédié** 🔧
J'ai ajouté un bouton rouge (🐛) dans l'AppBar de "Nouvelle demande" → Accès direct à l'écran de debug.

### **2. Tests Automatisés** ⚡
L'écran debug permet de tester :
- **Test Connexion** : Vérifier si le backend Spring Boot répond
- **Test Types** : Tester l'endpoint `/api/leave-types` avec logs détaillés

## 📋 **PROCÉDURE DE VÉRIFICATION**

### **ÉTAPE 1 : Accéder au Debug** 🐛
1. **Installer l'app mise à jour** : `flutter install`
2. **Ouvrir "Nouvelle demande"** 
3. **Cliquer le bouton rouge 🐛** dans l'AppBar
4. **Écran Debug s'ouvre**

### **ÉTAPE 2 : Tester la Connexion** 🌐
1. **Cliquer "Test Connexion"**
2. **Vérifier le résultat** :
   - ✅ `Backend accessible` → Ton Spring Boot fonctionne
   - ❌ `Backend inaccessible` → Problème serveur/réseau

### **ÉTAPE 3 : Tester les Types** 📋
1. **Cliquer "Test Types"**
2. **Analyser les logs** :

**Si SUCCESS :**
```
✅ SUCCESS: 2 types récupérés
📋 Type 1: "Conge" (actif: true)
📋 Type 2: "Autorisation d'absence" (actif: true)
```

**Si ERREUR :**
```
❌ ERREUR: 401 Non authentifié
❌ ERREUR: 404 Endpoint not found
❌ ERREUR: Timeout après 3s
```

## 🎯 **CAUSES POSSIBLES ET SOLUTIONS**

### **1. Problème Authentification** 🔑
**Symptôme** : `❌ ERREUR: 401 Non authentifié`  
**Solution** : 
- Se déconnecter/reconnecter avec `aa.bb@xtensus.com` / `123456`
- Vérifier que le token est valide

### **2. Endpoint Incorrect** 🔗
**Symptôme** : `❌ ERREUR: 404 Endpoint not found`  
**Solution** : 
- Vérifier que ton Spring Boot expose `/api/leave-types`
- Tester manuellement : `GET http://10.186.31.19:3000/api/leave-types`

### **3. Serveur Inaccessible** 🌐
**Symptôme** : `❌ Backend inaccessible` ou `Timeout`  
**Solution** :
- Vérifier que Spring Boot tourne sur port 3000
- Vérifier que ton IP `10.186.31.19` est accessible depuis le téléphone
- Tester dans le navigateur : `http://10.186.31.19:3000/api/flutter/test`

### **4. Base MySQL Vide** 🗄️
**Symptôme** : `✅ SUCCESS: 0 types récupérés`  
**Solution** : 
- Exécuter le script SQL : `SELECT * FROM leave_types WHERE is_active = TRUE;`
- Si vide, réinsérer les types avec le script fourni

### **5. Format JSON Incorrect** 📄
**Symptôme** : `❌ ERREUR: Format JSON invalide`  
**Solution** :
- Vérifier que ton endpoint retourne le bon format :
```json
[
  {"id": 1, "name": "Conge", "is_active": true},
  {"id": 2, "name": "Autorisation d'absence", "is_active": true}
]
```

## 🔄 **TESTS MANUELS COMPLÉMENTAIRES**

### **Test 1 : Backend Direct** 🌐
```bash
curl http://10.186.31.19:3000/api/flutter/test
# Doit retourner: 200 OK
```

### **Test 2 : Endpoint Types** 📋
```bash
curl -H "Authorization: Bearer TON_TOKEN" \
     http://10.186.31.19:3000/api/leave-types
# Doit retourner: [{"id":1,"name":"Conge"...}]
```

### **Test 3 : Base MySQL** 🗄️
```sql
SELECT * FROM leave_types WHERE is_active = TRUE;
-- Doit retourner au moins 1 ligne
```

## 🎉 **RÉSULTAT ATTENDU**

Après correction, tu devrais voir :
```
✅ SUCCESS: 2 types récupérés
📋 Type 1: "Conge" (actif: true)  
📋 Type 2: "Autorisation d'absence" (actif: true)
```

Et dans l'interface : **Dropdown fonctionnel** au lieu de "Aucun type de congé disponible".

## 🚀 **PROCHAINES ACTIONS**

1. **Installer l'app** avec bouton debug
2. **Tester connexion** + types via debug
3. **M'envoyer les logs** pour diagnostiquer le problème exact
4. **Corriger** selon les résultats

---

**🎯 Le debug va nous dire exactement pourquoi les types ne se chargent pas !**