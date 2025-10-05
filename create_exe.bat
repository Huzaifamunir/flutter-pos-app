@echo off
echo Creating POS App .exe file...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev/docs/get-started/install/windows
    pause
    exit /b 1
)

echo Flutter found. Getting dependencies...
flutter pub get

echo.
echo Building Windows release...
flutter build windows --release

if errorlevel 1 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Build successful! The .exe file is located at:
echo build\windows\runner\Release\pos_app.exe
echo.

REM Copy the .exe and required files to a portable folder
echo Creating portable version...
if exist pos_app_portable rmdir /s /q pos_app_portable
mkdir pos_app_portable

copy "build\windows\runner\Release\pos_app.exe" "pos_app_portable\"
copy "build\windows\runner\Release\*.dll" "pos_app_portable\"
xcopy "build\windows\runner\Release\data" "pos_app_portable\data\" /E /I /Y

echo.
echo Portable version created in 'pos_app_portable' folder
echo You can run pos_app.exe directly from this folder
echo.
echo Files included:
dir pos_app_portable /b
echo.
pause
