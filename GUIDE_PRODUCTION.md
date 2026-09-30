# 🚀 **Guide de Mise en Production - XCongés Flutter**

## 🎯 **Vue d'ensemble**

Ce guide détaille les étapes pour déployer l'application Flutter XCongés intégrée avec le backend Spring Boot en production.

---

## 📋 **Pré-requis**

### **Backend Spring Boot**
- ✅ API Spring Boot déployée et accessible
- ✅ Base de données configurée et migrée
- ✅ HTTPS configuré avec certificat valide
- ✅ CORS configuré pour le domaine mobile

### **Environnement de Build**
- ✅ Flutter SDK 3.11+ installé
- ✅ Android SDK et Android Studio (pour Android)
- ✅ Xcode 15+ (pour iOS)
- ✅ Certificats de signature configurés

---

## 🔧 **Configuration Production**

### **1. Configuration API**

Mettre à jour `lib/services/api_config.dart` :

```dart
class ApiConfig {
  static const String devUrlAndroid = 'http://10.0.2.2:8080/api';
  static const String devUrlIOS = 'http://127.0.0.1:8080/api';
  static const String prodUrl = 'https://api.xconges.votre-domaine.com/api'; // ⚠️ MODIFIER

  static String get baseUrl {
    if (kDebugMode) {
      return Platform.isAndroid ? devUrlAndroid : devUrlIOS;
    }
    return prodUrl; // Production URL
  }
}
```

### **2. Sécurité Réseau**

Ajouter dans `android/app/src/main/res/xml/network_security_config.xml` :

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">api.xconges.votre-domaine.com</domain>
    </domain-config>
    <!-- Dev only -->
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">127.0.0.1</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
```

### **3. Configuration App Info**

Mettre à jour `pubspec.yaml` :

```yaml
name: xconges_app
description: "Application de gestion des congés XCongés"
publish_to: 'none'

version: 1.0.0+1 # ⚠️ Incrémenter pour chaque release

environment:
  sdk: ^3.11.0
```

### **4. Configuration Android**

Mettre à jour `android/app/build.gradle` :

```gradle
android {
    compileSdkVersion 34
    ndkVersion flutter.ndkVersion

    defaultConfig {
        applicationId "com.votre-entreprise.xconges" // ⚠️ MODIFIER
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1      // ⚠️ Incrémenter pour chaque release
        versionName "1.0.0" // ⚠️ Synchroniser avec pubspec.yaml
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### **5. Configuration iOS**

Mettre à jour `ios/Runner/Info.plist` :

```xml
<key>CFBundleDisplayName</key>
<string>XCongés</string>
<key>CFBundleIdentifier</key>
<string>com.votre-entreprise.xconges</string> <!-- ⚠️ MODIFIER -->
<key>CFBundleVersion</key>
<string>1.0.0</string>
```

---

## 🔑 **Sécurité et Certificats**

### **1. Signature Android**

Créer le keystore de production :

```bash
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload -storepass [STORE_PASSWORD] -keypass [KEY_PASSWORD]
```

Créer `android/key.properties` :

```properties
storePassword=[STORE_PASSWORD]
keyPassword=[KEY_PASSWORD]
keyAlias=upload
storeFile=upload-keystore.jks
```

### **2. Certificates iOS**

- ✅ Certificat de distribution iOS configuré
- ✅ Provisioning Profile de production
- ✅ App Store Connect configuré

---

## 🏗️ **Build Production**

### **Android APK/AAB**

```bash
# Clean
flutter clean
flutter pub get

# Build APK
flutter build apk --release --target-platform android-arm,android-arm64

# Build AAB (recommandé pour Play Store)
flutter build appbundle --release
```

**Fichiers générés :**
- `build/app/outputs/apk/release/app-release.apk`
- `build/app/outputs/bundle/release/app-release.aab`

### **iOS**

```bash
# Clean
flutter clean
flutter pub get

# Build iOS
flutter build ios --release

# Archive avec Xcode
open ios/Runner.xcworkspace
# Product → Archive
```

---

## 🧪 **Tests Pré-Production**

### **1. Tests Fonctionnels**

```bash
# Exécuter le script de test
dart test_integration.dart
```

**Checklist manuelle :**
- [ ] Authentification login/logout
- [ ] Création demande de congé
- [ ] Approbation/refus (Manager)
- [ ] Upload certificat médical
- [ ] Affichage soldes
- [ ] Navigation complète

### **2. Tests de Performance**

```bash
# Profile mode pour tests performance
flutter run --profile
```

**Métriques à vérifier :**
- [ ] Temps de démarrage < 3s
- [ ] Navigation fluide (60 FPS)
- [ ] Consommation mémoire < 100MB
- [ ] Taille APK < 50MB

### **3. Tests Réseau**

- [ ] Connexion 4G/WiFi
- [ ] Mode avion → reconnexion
- [ ] Timeout réseau
- [ ] Gestion erreurs 500/503

---

## 📱 **Déploiement**

### **Google Play Store**

1. **Préparer le listing :**
   - Screenshots (1080x1920 minimum)
   - Description française
   - Icône haute résolution (512x512)

2. **Upload :**
   - Connecter à Play Console
   - Créer nouvelle release
   - Upload `app-release.aab`
   - Tests internes → Production

3. **Configuration :**
   - Prix et disponibilité
   - Classification du contenu
   - Politique de confidentialité

### **Apple App Store**

1. **Préparer le listing :**
   - Screenshots par taille d'écran
   - Description française
   - Mots-clés App Store

2. **Upload :**
   - Archive depuis Xcode
   - Upload vers App Store Connect
   - TestFlight → App Store Review

3. **Review :**
   - Durée : 1-7 jours
   - Répondre aux éventuelles remarques

---

## 🔍 **Monitoring Production**

### **1. Analytics**

Ajouter Firebase Analytics :

```yaml
dependencies:
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.8
```

### **2. Logs d'Erreur**

Configuration Crashlytics :

```dart
// main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  runApp(const MyApp());
}
```

### **3. Métriques Backend**

Surveiller côté API :
- [ ] Temps de réponse < 500ms
- [ ] Taux d'erreur < 1%
- [ ] Disponibilité > 99.9%
- [ ] Charge CPU/RAM

---

## 🔄 **Mise à Jour**

### **Process de Release**

1. **Développement :**
   ```bash
   git checkout -b feature/nouvelle-fonctionnalite
   # Développement + tests
   git push origin feature/nouvelle-fonctionnalite
   ```

2. **Intégration :**
   ```bash
   git checkout main
   git merge feature/nouvelle-fonctionnalite
   git tag v1.1.0
   git push origin main --tags
   ```

3. **Build et Deploy :**
   ```bash
   # Incrémenter version dans pubspec.yaml
   flutter build appbundle --release
   # Upload sur stores
   ```

### **Gestion des Versions**

| Type | Version | Code |
|------|---------|------|
| Patch | 1.0.1 | 2 |
| Minor | 1.1.0 | 3 |
| Major | 2.0.0 | 4 |

---

## 🚨 **Troubleshooting**

### **Erreurs Communes**

**Build Android Failed :**
```bash
flutter clean
flutter pub get
flutter doctor
./gradlew clean # dans android/
```

**iOS Code Signing :**
- Vérifier certificats dans Keychain
- Regénérer Provisioning Profile
- Clean Derived Data

**API Connection Issues :**
- Vérifier CORS backend
- Contrôler certificats HTTPS
- Tester avec Postman

### **Performance Issues**

- Utiliser `flutter run --profile`
- Profiler avec DevTools
- Optimiser images (WebP)
- Lazy loading des listes

---

## 📋 **Checklist Finale**

### **Pré-Déploiement**
- [ ] Tests d'intégration passés
- [ ] Build release sans warnings
- [ ] Configuration production validée
- [ ] Certificats de signature OK
- [ ] Backend production accessible

### **Post-Déploiement**
- [ ] Tests utilisateurs finaux
- [ ] Monitoring actif
- [ ] Alertes configurées
- [ ] Plan de rollback préparé
- [ ] Documentation utilisateur

---

## 🎯 **Métriques de Succès**

### **Techniques**
- Temps de démarrage < 3s
- Taux de crash < 0.1%
- Note App Store > 4.0
- Temps de réponse API < 500ms

### **Business**
- Adoption utilisateurs > 80%
- Satisfaction > 4.0/5
- Réduction temps de traitement > 50%

---

**🚀 Votre application XCongés est prête pour la production !**

*Guide généré automatiquement - Adapté pour votre infrastructure*