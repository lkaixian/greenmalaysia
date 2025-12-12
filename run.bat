@echo off
echo ==========================================
echo      GREENMALAYSIA BUILD SCRIPT
echo ==========================================

:: 0. VALIDATION CHECK
if not exist "android\app\src\main\AndroidManifest_clean.xml" (
    color 4F
    echo.
    echo [CRITICAL ERROR]
    echo File "android\app\src\main\AndroidManifest_clean.xml" was NOT found.
    echo.
    echo Please go to "android\app\src\main", make a copy of your working 
    echo AndroidManifest.xml, and rename it to AndroidManifest_clean.xml
    echo.
    pause
    exit /b
)

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
echo    - Restoring Clean Manifest...
copy "android\app\src\main\AndroidManifest_clean.xml" "android\app\src\main\AndroidManifest.xml" /Y
if %errorlevel% neq 0 goto :error

echo    - Generating User Icons...
call dart run flutter_launcher_icons:main -f flutter_launcher_icons-user.yaml

echo    - Building APK...
call flutter build apk --release -t lib/main.dart
if %errorlevel% neq 0 goto :error

echo    - Saving APK...
copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs_final\GreenMalaysia-User.apk" /Y

:: ---------------------------------------------------------
:: BUILD 2: ADMIN APP
:: ---------------------------------------------------------
echo.
echo [3/4] Building ADMIN App (Teal)...
echo    - Restoring Clean Manifest...
copy "android\app\src\main\AndroidManifest_clean.xml" "android\app\src\main\AndroidManifest.xml" /Y

echo    - Generating Admin Icons...
call dart run flutter_launcher_icons:main -f flutter_launcher_icons-admin.yaml

echo    - Building APK...
call flutter build apk --release -t lib/main_admin.dart
if %errorlevel% neq 0 goto :error

echo    - Saving APK...
copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs_final\GreenMalaysia-Admin.apk" /Y

:: ---------------------------------------------------------
:: BUILD 3: DRIVER APP
:: ---------------------------------------------------------
echo.
echo [4/4] Building DRIVER App (Blue)...
echo    - Restoring Clean Manifest...
copy "android\app\src\main\AndroidManifest_clean.xml" "android\app\src\main\AndroidManifest.xml" /Y

echo    - Generating Driver Icons...
call dart run flutter_launcher_icons:main -f flutter_launcher_icons-collector.yaml

echo    - Building APK...
call flutter build apk --release -t lib/main_collector.dart
if %errorlevel% neq 0 goto :error

echo    - Saving APK...
copy "build\app\outputs\flutter-apk\app-release.apk" "build\outputs_final\GreenMalaysia-Driver.apk" /Y

:: ---------------------------------------------------------
:: CLEANUP (Restore Manifest one last time)
:: ---------------------------------------------------------
copy "android\app\src\main\AndroidManifest_clean.xml" "android\app\src\main\AndroidManifest.xml" /Y

echo.
echo ==========================================
echo        ALL BUILDS COMPLETED!
echo ==========================================
echo You can find your 3 APKs in the "build\outputs_final" folder.
pause
exit /b

:error
color 4F
echo.
echo ==========================================
echo          BUILD FAILED!
echo ==========================================
echo Something went wrong. Please check the logs above.
pause