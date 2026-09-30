# 🚀 **Tests Immédiats - Backend Port 8082**

## ✅ **Configuration Mise à Jour**

L'application Flutter XCongés est maintenant configurée pour le **port 8082** où votre backend Spring Boot redémarre.

---

## 🔧 **Fichiers Modifiés**

### **Configuration API**
- ✅ `lib/services/api_config.dart` → Port 8082 configuré
- ✅ URLs mises à jour : `http://10.0.2.2:8082/api`
- ✅ Headers optimisés pour développement local

### **Tests Intégrés**
- ✅ `test_integration.dart` → Script de test port 8082
- ✅ `lib/widgets/connection_test_widget.dart` → Widget de test temps réel
- ✅ `lib/views/debug/debug_screen.dart` → Interface de debug complète

---

## 🧪 **Comment Tester Maintenant**

### **1. Test Script Automatique**
```bash
cd c:\Users\msi\leaveapp
dart test_integration.dart
```

**Résultats attendus :**
- ✅ Backend accessible sur port 8082
- ✅ Endpoint `/api/flutter/test` répond
- ✅ Endpoint `/api/auth/me` retourne 401 (sécurisé)
- ✅ Endpoint `/api/leave-requests` retourne 401 (sécurisé)

### **2. Test dans l'Application Flutter**

**Lancer l'app :**
```bash
flutter run
```

**Accéder au mode debug :**
1. Connectez-vous (ou pas)
2. Allez à l'écran principal (dashboard)
3. **Cliquez sur l'icône 🐛 (bug) en haut à droite**
4. Vous arrivez sur l'écran de debug

**Dans l'écran debug :**
- **Test Flutter** → Test endpoint spécial
- **Test Auth** → Test authentification
- **Actualiser Données** → Test APIs congés
- **Test Complet** → Simulation complète

### **3. Tests Spécifiques Backend**

**Test endpoint Flutter personnalisé :**
```bash
curl http://localhost:8082/api/flutter/test
```

**Test authentification :**
```bash
curl -X POST http://localhost:8082/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail": "test@example.com", "password": "password123"}'
```

**Test protection endpoints :**
```bash
curl http://localhost:8082/api/leave-requests/requester/1
# Doit retourner 401 Unauthorized
```

---

## 📱 **Interface de Test Temps Réel**

### **Widget de Test Intégré**
L'application inclut maintenant un widget de test visible dans l'écran debug qui permet de :

- **Tester la connexion** au backend en temps réel
- **Voir les réponses** exactes du serveur  
- **Diagnostiquer les erreurs** de connexion
- **Valider les headers** et formats de requête

### **Codes de Couleur**
- 🟢 **Vert** : Connexion réussie, backend répond correctement
- 🟠 **Orange** : Backend répond mais format/code inattendu  
- 🔴 **Rouge** : Erreur de connexion, backend inaccessible

---

## 🔍 **Diagnostic des Problèmes**

### **Backend inaccessible (Rouge)**
```
❌ Erreur connexion: Connection refused
```
**Solutions :**
1. Vérifier que Spring Boot tourne sur port 8082
2. Attendre 30 secondes que le backend redémarre complètement
3. Tester avec `curl http://localhost:8082/api/flutter/test`

### **Backend répond mais erreur 404 (Orange)**  
```
⚠️ Backend répond (404)
```
**Solutions :**
1. L'endpoint `/api/flutter/test` n'existe pas encore
2. Tester avec `/api/auth/me` qui devrait retourner 401
3. Vérifier les logs du backend Spring Boot

### **Authentification échoue (Orange/Rouge)**
```
⚠️ Login failed (401) - normal si utilisateur test n'existe pas
```
**Solutions :**
1. Créer un utilisateur de test dans la base
2. Modifier les identifiants de test dans le code
3. Vérifier la configuration JWT du backend

---

## ✅ **Checklist de Validation**

### **Configuration** 
- [ ] Backend Spring Boot démarre sur port 8082
- [ ] Logs Spring Boot ne montrent pas d'erreurs
- [ ] Application Flutter compile sans erreur
- [ ] Script `dart test_integration.dart` fonctionne

### **Connexion**
- [ ] Test Flutter endpoint retourne une réponse
- [ ] Test auth endpoint retourne 401 (sécurisé)
- [ ] Pas d'erreurs CORS dans les logs
- [ ] Headers de requête correctement formatés

### **Interface**
- [ ] Écran debug accessible (icône 🐛)
- [ ] Widget de test change de couleur selon résultat
- [ ] Boutons de test répondent sans crash
- [ ] Messages d'erreur sont informatifs

---

## 🎯 **Prochaines Étapes**

### **Si Tests Passent (Vert)** ✅
1. **Créer un utilisateur de test** dans le backend
2. **Tester l'authentification complète** avec vrais identifiants
3. **Implémenter les endpoints manquants** si nécessaire
4. **Passer aux tests de création de demandes**

### **Si Tests Échouent (Rouge)** ❌
1. **Vérifier les logs Spring Boot** pour erreurs
2. **Confirmer le port 8082** dans la configuration backend
3. **Tester manuellement avec curl** les endpoints
4. **Vérifier la configuration CORS** pour accepter les requêtes Flutter

---

## 🔧 **Configuration CORS Backend**

Si vous avez des erreurs CORS, ajoutez ceci dans votre configuration Spring Boot :

```java
@Configuration
@EnableWebMvc
public class WebConfig implements WebMvcConfigurer {
    
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")
                .allowedOrigins("*")  // En dev seulement
                .allowedMethods("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(false);  // Important pour "*" origins
    }
}
```

---

## 📞 **Support**

En cas de problème :

1. **Vérifier les logs** Spring Boot et Flutter  
2. **Exécuter le script de test** `dart test_integration.dart`
3. **Utiliser l'écran debug** dans l'app Flutter
4. **Tester manuellement** avec curl/Postman

**L'intégration est maintenant prête pour les tests sur le port 8082 !** 🚀