@echo off
setlocal enabledelayedexpansion

set VERSION_FILE=lib\core\global\app_version.dart

echo [1/7] Reading current version...
for /f "tokens=*" %%a in ('findstr /r "appVersion = " "%VERSION_FILE%"') do set LINE=%%a

for /f "tokens=2 delims='" %%v in ("!LINE!") do set CURRENT=%%v

REM Extract major and build numbers from pattern like "1.144"
for /f "tokens=1,2 delims=." %%a in ("!CURRENT!") do (
    set MAJOR=%%a
    set BUILD=%%b
)

echo [2/7] Bumping version...
set /a BUILD=BUILD+1
set NEW_VERSION=!MAJOR!.!BUILD!
echo       !CURRENT! -^> !NEW_VERSION!

(
echo // Auto-updated by build.bat -- do not edit manually
echo const String appVersion = '!NEW_VERSION!';
) > "%VERSION_FILE%"
echo       Version file updated.

echo [3/7] Running flutter clean...
call flutter clean
if errorlevel 1 ( echo ERROR: flutter clean failed & exit /b 1 )

echo [4/7] Running flutter build web --release...
call flutter build web --release
if errorlevel 1 ( echo ERROR: flutter build web failed & exit /b 1 )

echo [5/7] Deploying to Firebase Hosting...
call firebase deploy --only hosting
if errorlevel 1 ( echo ERROR: firebase deploy failed & exit /b 1 )

echo [6/7] Updating Firestore project_version...
REM Create a temporary Node.js script to update Firestore
(
echo const admin = require('firebase-admin');
echo const serviceAccount = require('./firebase-key.json');
echo.
echo admin.initializeApp({
echo   credential: admin.credential.cert(serviceAccount)
echo });
echo.
echo const db = admin.firestore();
echo.
echo async function updateVersion() {
echo   try {
echo     await db.collection('project_version').doc('current').set({
echo       version: '!NEW_VERSION!'
echo     }, { merge: true });
echo     console.log('✅ Firestore project_version updated to !NEW_VERSION!');
echo     process.exit(0);
echo   } catch (error) {
echo     console.error('❌ Error updating Firestore:', error);
echo     process.exit(1);
echo   }
echo }
echo.
echo updateVersion();
) > update_firestore_version.js

REM Run the Node.js script
node update_firestore_version.js
if errorlevel 1 ( echo WARNING: Firestore update failed, but deployment completed )

REM Clean up the temporary script
del update_firestore_version.js

echo.
echo [7/7] Done. Version: !NEW_VERSION!
echo       Finished at: %TIME%
endlocal
