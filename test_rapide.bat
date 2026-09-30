@echo off
echo 🚀 Test Rapide XCongés Backend
echo.

echo 📱 Compilation Flutter optimisée...
flutter clean
flutter pub get

echo 📡 Test connexion backend...
curl -f http://10.0.2.2:8081/api/flutter/test 2>NUL
if %errorlevel%==0 (
    echo ✅ Backend accessible sur port 8081
) else (
    echo ❌ Backend non accessible - vérifiez qu'il tourne sur port 8081
    pause
    exit /b 1
)

echo 🔐 Test création utilisateur...
curl -X POST http://10.0.2.2:8081/api/auth/create-test-user 2>NUL
if %errorlevel%==0 (
    echo ✅ Utilisateur de test créé
) else (
    echo ⚠️ Utilisateur de test déjà existant
)

echo 🏃 Lancement Flutter en mode test...
flutter run --release
pause