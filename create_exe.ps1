# PowerShell script to create POS App .exe file
Write-Host "Creating POS App .exe file..." -ForegroundColor Green
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter found. Getting dependencies..." -ForegroundColor Yellow
    flutter pub get
    
    Write-Host ""
    Write-Host "Building Windows release..." -ForegroundColor Yellow
    flutter build windows --release
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Build successful! The .exe file is located at:" -ForegroundColor Green
        Write-Host "build\windows\runner\Release\pos_app.exe" -ForegroundColor Cyan
        
        # Create portable version
        Write-Host ""
        Write-Host "Creating portable version..." -ForegroundColor Yellow
        
        if (Test-Path "pos_app_portable") {
            Remove-Item "pos_app_portable" -Recurse -Force
        }
        New-Item -ItemType Directory -Name "pos_app_portable" | Out-Null
        
        Copy-Item "build\windows\runner\Release\pos_app.exe" "pos_app_portable\"
        Copy-Item "build\windows\runner\Release\*.dll" "pos_app_portable\"
        Copy-Item "build\windows\runner\Release\data" "pos_app_portable\data\" -Recurse
        
        Write-Host ""
        Write-Host "Portable version created in 'pos_app_portable' folder" -ForegroundColor Green
        Write-Host "You can run pos_app.exe directly from this folder" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Files included:" -ForegroundColor Yellow
        Get-ChildItem "pos_app_portable" | ForEach-Object { Write-Host "  $($_.Name)" }
        
    } else {
        Write-Host "Build failed!" -ForegroundColor Red
    }
} catch {
    Write-Host "Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install/windows" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Press Enter to continue"
