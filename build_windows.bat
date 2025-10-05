@echo off
echo Building POS App for Windows...
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
echo Build successful! Creating installer package...

REM Create installer directory
if exist installer rmdir /s /q installer
mkdir installer

REM Copy build files
xcopy "build\windows\runner\Release\*" "installer\" /E /I /Y

REM Create installation script
echo @echo off > installer\install.bat
echo echo Installing POS App... >> installer\install.bat
echo echo. >> installer\install.bat
echo echo Copying files to Program Files... >> installer\install.bat
echo mkdir "C:\Program Files\POS App" 2^>nul >> installer\install.bat
echo xcopy "pos_app.exe" "C:\Program Files\POS App\" /Y >> installer\install.bat
echo xcopy "data" "C:\Program Files\POS App\data\" /E /I /Y >> installer\install.bat
echo xcopy "flutter_windows.dll" "C:\Program Files\POS App\" /Y >> installer\install.bat
echo xcopy "*.dll" "C:\Program Files\POS App\" /Y >> installer\install.bat
echo echo. >> installer\install.bat
echo echo Creating desktop shortcut... >> installer\install.bat
echo powershell -Command "$WshShell = New-Object -comObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%%USERPROFILE%%\Desktop\POS App.lnk'); $Shortcut.TargetPath = 'C:\Program Files\POS App\pos_app.exe'; $Shortcut.Save()" >> installer\install.bat
echo echo. >> installer\install.bat
echo echo Installation complete! >> installer\install.bat
echo echo You can now run the app from the desktop shortcut. >> installer\install.bat
echo pause >> installer\install.bat

REM Create README
echo # POS App - Windows Installation > installer\README.txt
echo. >> installer\README.txt
echo ## Quick Installation: >> installer\README.txt
echo 1. Right-click on install.bat and select "Run as administrator" >> installer\README.txt
echo 2. Follow the prompts to install the app >> installer\README.txt
echo 3. A desktop shortcut will be created automatically >> installer\README.txt
echo. >> installer\README.txt
echo ## Manual Installation: >> installer\README.txt
echo 1. Copy all files to a folder (e.g., C:\POS App\) >> installer\README.txt
echo 2. Run pos_app.exe to start the application >> installer\README.txt
echo. >> installer\README.txt
echo ## System Requirements: >> installer\README.txt
echo - Windows 10 or later >> installer\README.txt
echo - 64-bit processor >> installer\README.txt
echo - 100 MB free disk space >> installer\README.txt

echo.
echo Windows build complete!
echo.
echo The installer package is in the 'installer' folder.
echo To install on Windows:
echo 1. Copy the 'installer' folder to your Windows machine
echo 2. Right-click on install.bat and select "Run as administrator"
echo.
pause
