@echo off
setlocal enabledelayedexpansion

set VERSION_FILE=lib\core\global\app_version.dart

echo [1/6] Reading current version...
for /f "tokens=*" %%a in ('findstr /r "appVersion = " "%VERSION_FILE%"') do set LINE=%%a

for /f "tokens=2 delims='" %%v in ("!LINE!") do set CURRENT=%%v

for /f "tokens=1,2,3 delims=." %%a in ("!CURRENT!") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

echo [2/6] Bumping version...
set /a PATCH=PATCH+1
set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!
echo       !CURRENT! -^> !NEW_VERSION!

(
echo // Auto-updated by build.bat -- do not edit manually
echo const String appVersion = '!NEW_VERSION!';
) > "%VERSION_FILE%"
echo       Version file updated.

echo [3/6] Running flutter clean...
call flutter clean
if errorlevel 1 ( echo ERROR: flutter clean failed & exit /b 1 )

echo [4/6] Running flutter build web --release...
call flutter build web --release
if errorlevel 1 ( echo ERROR: flutter build web failed & exit /b 1 )

echo [5/6] Deploying to Firebase Hosting...
call firebase deploy --only hosting
if errorlevel 1 ( echo ERROR: firebase deploy failed & exit /b 1 )

echo.
echo [6/6] Done. Version: !NEW_VERSION!
echo       Finished at: %TIME%
endlocal
