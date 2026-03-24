@echo off
setlocal enabledelayedexpansion

set VERSION_FILE=lib\core\global\app_version.dart

:: Read current version from the dart file
for /f "tokens=*" %%a in ('findstr /r "appVersion = " "%VERSION_FILE%"') do set LINE=%%a

:: Extract version string e.g. '1.0.1'
for /f "tokens=2 delims='" %%v in ("!LINE!") do set CURRENT=%%v

:: Split into major.minor.patch
for /f "tokens=1,2,3 delims=." %%a in ("!CURRENT!") do (
    set MAJOR=%%a
    set MINOR=%%b
    set PATCH=%%c
)

:: Bump patch
set /a PATCH=PATCH+1
set NEW_VERSION=!MAJOR!.!MINOR!.!PATCH!

echo Bumping version: !CURRENT! -^> !NEW_VERSION!

:: Write new version file
(
echo // Auto-updated by build.bat -- do not edit manually
echo const String appVersion = '!NEW_VERSION!';
) > "%VERSION_FILE%"

echo Version file updated.

:: Clean and build
echo Running flutter clean...
call flutter clean

echo Running flutter build web...
call flutter build web --release

echo.
echo Done. Version: !NEW_VERSION!
endlocal
