# 🔥 Configuration Firebase pour les Notifications Push

## Vue d'ensemble
Ce guide explique comment configurer Firebase pour activer les notifications push dans l'application Leave Management.

## Étapes de Configuration

### 1. Configuration Firebase Console

#### Créer un projet Firebase
1. Allez sur https://console.firebase.google.com/
2. Cliquez sur "Ajouter un projet"
3. Nommez votre projet : `leave-management-app`
4. Activez Google Analytics (optionnel)
5. Créez le projet

#### Configurer Firestore Database
1. Dans le menu latéral, cliquez sur "Firestore Database"
2. Cliquez sur "Créer une base de données"
3. Choisissez "Commencer en mode test" (pour le développement)
4. Sélectionnez votre région

#### Configurer Authentication (Optionnel)
1. Dans le menu latéral, cliquez sur "Authentication"
2. Onglet "Sign-in method"
3. Activez les méthodes souhaitées (Email/Password recommandé)

### 2. Configuration Android

#### Ajouter une application Android
1. Dans la console Firebase, cliquez sur l'icône Android
2. **Nom du package Android :** `com.example.leaveapp`
3. **Nom de l'app (optionnel) :** Leave Management
4. **Certificat de signature SHA-1 :** Laisser vide pour le développement
5. Cliquez sur "Enregistrer l'app"

#### Télécharger google-services.json
1. Téléchargez le fichier `google-services.json`
2. Placez-le dans : `android/app/google-services.json`

#### Modifier android/build.gradle (projet)
```gradle
buildscript {
    ext.kotlin_version = '1.7.10'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### Modifier android/app/build.gradle
```gradle
plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'dev.flutter.flutter-gradle-plugin'
    id 'com.google.gms.google-services'
}

android {
    namespace "com.example.leaveapp"
    compileSdkVersion flutter.compileSdkVersion
    ndkVersion flutter.ndkVersion

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = '1.8'
    }

    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }

    defaultConfig {
        applicationId "com.example.leaveapp"
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}

dependencies {
    implementation 'com.google.firebase:firebase-messaging:23.2.1'
    implementation 'com.google.firebase:firebase-analytics:21.3.0'
}
```

#### Modifier android/app/src/main/AndroidManifest.xml
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.VIBRATE" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.WAKE_LOCK" />

    <application
        android:label="Leave Management"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        
        <!-- Activity principale -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <!-- Service Firebase Messaging -->
        <service
            android:name="io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService"
            android:exported="false">
            <intent-filter>
                <action android:name="com.google.firebase.MESSAGING_EVENT" />
            </intent-filter>
        </service>

        <!-- Métadonnées Firebase -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@drawable/ic_notification" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/notification_color" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="leave_app_notifications" />

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

### 3. Configuration iOS

#### Ajouter une application iOS
1. Dans la console Firebase, cliquez sur l'icône iOS
2. **Bundle ID :** `com.example.leaveapp`
3. **Nom de l'app :** Leave Management
4. **App Store ID :** Laisser vide
5. Cliquez sur "Enregistrer l'app"

#### Télécharger GoogleService-Info.plist
1. Téléchargez le fichier `GoogleService-Info.plist`
2. Dans Xcode, ouvrez `ios/Runner.xcworkspace`
3. Glissez-déposez le fichier dans `Runner/Runner`
4. Cochez "Copy items if needed"
5. Sélectionnez "Runner" comme target

#### Configurer les capacités iOS
1. Dans Xcode, sélectionnez le projet Runner
2. Onglet "Signing & Capabilities"
3. Cliquez sur "+ Capability"
4. Ajoutez "Push Notifications"
5. Ajoutez "Background Modes" et activez "Background fetch" et "Remote notifications"

### 4. Mise à jour pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Dépendances existantes...
  cupertino_icons: ^1.0.8
  provider: ^6.1.2
  file_picker: ^8.0.0+1
  image_picker: ^1.0.7
  path_provider: ^2.1.2
  shared_preferences: ^2.2.2
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10
  cloud_firestore: ^4.13.6
  flutter_local_notifications: ^17.0.0
```

### 5. Mise à jour du code Flutter

#### Remplacer LocalNotificationService par NotificationService
Dans `lib/main.dart`, `lib/viewmodels/leave_viewmodel.dart`, et autres fichiers, remplacez :
- `LocalNotificationService` → `NotificationService`
- Import : `'../services/local_notification_service.dart'` → `'../services/notification_service.dart'`

#### Configuration main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Firebase
  await Firebase.initializeApp();
  
  // Initialiser le service de notifications
  await NotificationService().initialize();
  
  runApp(const MyApp());
}
```

### 6. Test des Notifications

#### Test en local
1. Compilez et lancez l'app sur un appareil physique
2. Utilisez le bouton "Tester les Notifications" dans le dashboard
3. Vérifiez que les notifications apparaissent dans l'écran des notifications

#### Test des notifications push
1. Dans la console Firebase, allez dans "Cloud Messaging"
2. Cliquez sur "Envoyer votre premier message"
3. Titre : "Test de notification"
4. Texte : "Ceci est un test de notification push"
5. Sélectionnez votre application
6. Envoyez le message

### 7. Règles de sécurité Firestore

Dans la console Firebase > Firestore Database > Règles :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles pour les notifications
    match /notifications/{notificationId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
    
    // Règles pour les demandes de congé
    match /leave_requests/{requestId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
      allow create: if request.auth != null;
    }
  }
}
```

### 8. Déploiement

#### Variables d'environnement
Créez des configurations séparées pour :
- Développement : `firebase-config-dev.json`
- Production : `firebase-config-prod.json`

#### CI/CD
Configurez votre pipeline pour :
1. Installer les dépendances Firebase
2. Copier les bons fichiers de configuration
3. Construire l'application
4. Déployer sur les stores

## Fonctionnalités Disponibles

### Notifications Automatiques
- ✅ Demande soumise
- ✅ Demande approuvée
- ✅ Demande refusée
- ✅ Nouvelles décisions/politiques
- ✅ Rappels importants

### Interface Utilisateur
- ✅ Badge de notifications non lues
- ✅ Écran de gestion des notifications
- ✅ Suppression et lecture des notifications
- ✅ Filtrage par type
- ✅ Navigation contextuelle

### Administration
- ✅ Envoi de notifications push depuis la console
- ✅ Gestion des tokens FCM
- ✅ Analytics des notifications
- ✅ Stockage sécurisé dans Firestore

## Dépannage

### Erreurs communes
1. **Firebase non initialisé :** Vérifiez que `Firebase.initializeApp()` est appelé
2. **Permissions manquantes :** Vérifiez AndroidManifest.xml et capabilities iOS
3. **Token FCM null :** Testez sur un appareil physique, pas sur émulateur
4. **Notifications non reçues :** Vérifiez les règles Firestore et l'état de l'app

### Logs utiles
```bash
flutter logs | grep -i firebase
flutter logs | grep -i notification
```

### Test sur émulateur
Les notifications push ne fonctionnent pas sur les émulateurs. Utilisez un appareil physique pour tester.

## Migration depuis LocalNotificationService

Pour migrer de la version locale vers Firebase :

1. Remplacez tous les imports `LocalNotificationService`
2. Mettez à jour les configurations Android/iOS
3. Déployez les règles Firestore
4. Testez sur appareil physique
5. Configurez les notifications push dans la console

La migration préservera toutes les fonctionnalités existantes tout en ajoutant les notifications push.