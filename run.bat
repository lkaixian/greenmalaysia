@echo off
echo ==========================================
echo      GREENMALAYSIA BUILD SCRIPT
echo ==========================================

:: 1. Setup Output Directory
if not exist "build\outputs_final" mkdir "build\outputs_final"

echo.
echo [1/4] Cleaning Project...
call flutter clean
call flutter pub get

:: ---------------------------------------------------------
:: BUILD 1: USER APP
:: ---------------------------------------------------------
echo.
echo [2/4] Building USER App (Green)...
echo    - Generating User Icons...
call dart run flutter_launcher_icons:main -f flutter_launcher_icons-user.yaml
echo    - Building APK (lib/main.dart)...
call flutter build apk --release -t lib/main.dart
echo    - Saving APK...
copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs_final\GreenMalaysia-User.apk" /Y

:: ---------------------------------------------------------
:: BUILD 2: ADMIN APP
:: ---------------------------------------------------------
echo.
echo [3/4] Building ADMIN App (Teal)...
echo    - Generating Admin Icons...
call dart run flutter_launcher_icons:main -f flutter_launcher_icons-admin.yaml
echo    - Building APK (lib/main_admin.dart)...
call flutter build apk --release -t lib/main_admin.dart
echo    - Saving APK...
copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs_final\GreenMalaysia-Admin.apk" /Y

:: ---------------------------------------------------------
:: BUILD 3: DRIVER APP
:: ---------------------------------------------------------
echo.
echo [4/4] Building DRIVER App (Blue)...
echo    - Generating Driver Icons...
call dart run flutter_launcher_icons:main -f flutter_launcher_icons-collector.yaml
echo    - Building APK (lib/main_collector.dart)...
call flutter build apk --release -t lib/main_collector.dart
echo    - Saving APK...
copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs_final\GreenMalaysia-Driver.apk" /Y

echo.
echo ==========================================
echo        ALL BUILDS COMPLETED!
echo ==========================================
echo You can find your 3 APKs in the "build\outputs_final" folder.
pause