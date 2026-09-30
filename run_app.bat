@echo off
echo 🚀 Lancement automatique XCongés Flutter
echo.

echo 📱 Configuration port forwarding...
adb reverse tcp:8080 tcp:8080

if %errorlevel% equ 0 (
    echo ✅ Port forwarding configuré avec succès
    echo.
    echo 🎯 Lancement Flutter...
    flutter run
) else (
    echo ❌ Erreur port forwarding - Vérifiez qu'un appareil est connecté
    echo 💡 Lancez manuellement: adb reverse tcp:8080 tcp:8080
    echo.
    pause
)