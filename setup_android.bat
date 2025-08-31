@echo off
echo ========================================
echo    TrainSight Android Setup Script
echo ========================================
echo.

echo [1/4] Checking Flutter installation...
flutter --version
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    pause
    exit /b 1
)

echo.
echo [2/4] Checking Flutter doctor...
flutter doctor
if %errorlevel% neq 0 (
    echo ERROR: Flutter doctor failed
    pause
    exit /b 1
)

echo.
echo [3/4] Cleaning project...
flutter clean
if %errorlevel% neq 0 (
    echo WARNING: Flutter clean failed
)

echo.
echo [4/4] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo ========================================
echo    Setup Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Install Android Studio from: https://developer.android.com/studio
echo 2. Enable Developer Mode in Windows Settings
echo 3. Create an Android Virtual Device (AVD)
echo 4. Run: flutter emulators --launch ^<emulator_name^>
echo 5. Run: flutter run
echo.
echo For detailed instructions, see: ANDROID_SETUP_GUIDE.md
echo.
pause
