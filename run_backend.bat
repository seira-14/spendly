@echo off
echo Starting Spendly Laravel Backend...
cd /d "%~dp0backend"

:: Try system php first, fallback to XAMPP PHP
where php >nul 2>nul
if %ERRORLEVEL% equ 0 (
    php artisan serve --host=0.0.0.0 --port=8000
) else if exist "C:\xampp\php\php.exe" (
    "C:\xampp\php\php.exe" artisan serve --host=0.0.0.0 --port=8000
) else (
    echo Error: PHP not found. Please install PHP or XAMPP.
    pause
)
