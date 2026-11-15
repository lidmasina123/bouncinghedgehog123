@echo off
setlocal EnableExtensions
set "PROJECT=%~dp0"
set "GODOT="
if defined BOUNCE_RUN_GODOT if exist "%BOUNCE_RUN_GODOT%" set "GODOT=%BOUNCE_RUN_GODOT%"
if not defined GODOT if exist "%PROJECT%godot.exe" set "GODOT=%PROJECT%godot.exe"
if not defined GODOT set "GODOT=%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
if not exist "%GODOT%" (
    echo Godot 4 was not found. Put a Godot 4 executable next to this launcher and name it godot.exe.
    pause
    exit /b 1
)
if not exist "%PROJECT%project.godot" (
    echo Extract the whole Bounce Run ZIP before opening this launcher.
    pause
    exit /b 1
)
pushd "%PROJECT%" || exit /b 1
echo Loading Bounce Run in Godot...
start "" /wait "%GODOT%" --headless --import
if errorlevel 1 goto failed
if /i "%~1"=="--check" (
    start "" /wait "%GODOT%" --headless --quit-after 10
    if errorlevel 1 goto failed
) else (
    start "" /wait "%GODOT%"
    if errorlevel 1 goto failed
)
popd
exit /b 0

:failed
echo Godot could not open Bounce Run. See the error above.
popd
if /i not "%~1"=="--check" pause
exit /b 1
