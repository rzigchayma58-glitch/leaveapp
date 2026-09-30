# 🚀 **Guide VS Code - XCongés Flutter**

## ✨ **Configuration Automatique Créée !**

VS Code est maintenant configuré pour lancer automatiquement votre app Flutter XCongés avec le port forwarding.

---

## 🎯 **Comment Utiliser**

### **1. Préparation**
- ✅ Branchez votre téléphone/tablette en USB
- ✅ Activez le débogage USB sur l'appareil
- ✅ Vérifiez avec `adb devices` dans le terminal VS Code

### **2. Lancement Automatique**
1. **Ouvrez l'onglet "Run and Debug"** (icône ▶️🐛 à gauche)
2. **Sélectionnez une configuration** dans le menu déroulant :
   - **"Flutter XCongés (localhost:8080)"** ← Recommandé
   - **"Flutter XCongés (localhost:8082)"** ← Si backend sur port 8082
   - **"Flutter XCongés (Sans adb)"** ← Pour émulateur uniquement
3. **Appuyez sur F5** ou cliquez sur ▶️

### **3. Automatisation Magique** ✨
VS Code exécute automatiquement dans l'ordre :
1. `adb reverse tcp:8080 tcp:8080`
2. `flutter run`

**Plus jamais besoin de se rappeler des commandes !**

---

## 📱 **Configurations Disponibles**

### **🎯 localhost:8080 (Recommandé)**
```json
"Flutter XCongés (localhost:8080)"
```
- ✅ Port standard Spring Boot
- ✅ Execute `adb reverse tcp:8080 tcp:8080` automatiquement
- ✅ Lance Flutter avec backend sur port 8080

### **🔧 localhost:8082 (Alternative)**
```json
"Flutter XCongés (localhost:8082)" 
```
- ⚡ Pour backend sur port 8082
- ✅ Execute `adb reverse tcp:8082 tcp:8082` automatiquement

### **📱 Sans ADB (Émulateur)**
```json
"Flutter XCongés (Sans adb)"
```
- 🖥️ Pour émulateur Android uniquement
- ✅ Pas de port forwarding (utilise 10.0.2.2)

---

## 🔧 **Fichiers de Configuration**

### **.vscode/launch.json**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter XCongés (localhost:8080)",
      "request": "launch",
      "type": "dart", 
      "preLaunchTask": "adb reverse"
    }
  ]
}
```

### **.vscode/tasks.json**
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "adb reverse",
      "command": "adb reverse tcp:8080 tcp:8080"
    }
  ]
}
```

---

## 🧪 **Debug et Tests**

### **Console de Debug**
- ✅ **Debug Console** : Messages Flutter/Dart
- ✅ **Terminal** : Commandes adb et logs
- ✅ **Problems** : Erreurs de compilation

### **Breakpoints**
- ✅ Cliquez à gauche des numéros de ligne
- ✅ Debug step-by-step avec F10/F11
- ✅ Variables inspection en hover

### **Hot Reload**
- ✅ **Ctrl+S** : Sauvegarde + Hot Reload automatique
- ✅ **Ctrl+Shift+F5** : Hot Restart complet

---

## 🚨 **Résolution de Problèmes**

### **"adb command not found"**
```bash
# Ajoutez Android SDK platform-tools au PATH
# Ou vérifiez l'installation Flutter Doctor
flutter doctor
```

### **"No devices found"**
```bash
# Vérifiez la connexion USB
adb devices

# Résultat attendu:
# List of devices attached
# ABC123XYZ    device
```

### **"Connection refused"**
- ✅ Vérifiez que le backend Spring Boot tourne
- ✅ Testez `curl http://localhost:8080/api/auth/me`
- ✅ Changez de configuration si backend sur autre port

### **Changer de Port Backend**
1. Modifiez `lib/services/api_config.dart`
2. Créez une nouvelle task dans `.vscode/tasks.json` si nécessaire
3. Sélectionnez la bonne configuration dans "Run and Debug"

---

## 🎉 **Workflow Optimal**

### **Développement Quotidien**
1. **Ouvrez VS Code** dans le dossier du projet
2. **Branchez appareil** ou lancez émulateur
3. **F5** → Tout se lance automatiquement ! ✨
4. **Développez** avec Hot Reload (Ctrl+S)
5. **Debug** avec breakpoints au besoin

### **Test Backend**
- **Terminal** → `dart test_simple.dart`
- **Ou utilisez l'écran Debug dans l'app** (icône 🐛)

### **Build Release**
- **Terminal** → `flutter build apk --release`

---

## 🏆 **Résultat Final**

**Développement Flutter maintenant ultra-fluide :**

- ✅ **Un clic F5** → Tout se lance
- ✅ **Port forwarding automatique** 
- ✅ **Hot Reload** temps réel
- ✅ **Debug intégré** VS Code
- ✅ **Multi-configurations** selon vos besoins

**Votre environnement de développement Flutter est maintenant parfaitement optimisé !** 🚀