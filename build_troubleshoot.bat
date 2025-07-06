@echo off
echo Steps Counter App - Build Troubleshooting Script
echo ================================================

echo.
echo 1. Testing Flutter Installation...
flutter --version
if errorlevel 1 (
    echo ERROR: Flutter not found in PATH
    pause
    exit /b 1
)

echo.
echo 2. Testing Network Connectivity...
echo Testing Google Maven...
curl -I -s --connect-timeout 10 https://dl.google.com/dl/android/maven2/ > nul
if errorlevel 1 (
    echo WARNING: Cannot reach Google Maven repository
) else (
    echo OK: Google Maven repository accessible
)

echo Testing Maven Central...
curl -I -s --connect-timeout 10 https://repo.maven.apache.org/maven2/ > nul
if errorlevel 1 (
    echo WARNING: Cannot reach Maven Central repository
) else (
    echo OK: Maven Central repository accessible
)

echo Testing Aliyun Mirror...
curl -I -s --connect-timeout 10 https://maven.aliyun.com/repository/google > nul
if errorlevel 1 (
    echo WARNING: Cannot reach Aliyun mirror
) else (
    echo OK: Aliyun mirror accessible
)

echo.
echo 3. Cleaning Project...
flutter clean
if exist android\.gradle (
    echo Removing Android Gradle cache...
    rmdir /s /q android\.gradle
)

echo.
echo 4. Getting Dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

echo.
echo 5. Attempting Different Build Targets...
echo.
echo Trying Web build...
flutter build web --release
if not errorlevel 1 (
    echo SUCCESS: Web build completed
    echo You can test the app at: build\web\index.html
    goto :success
)

echo.
echo Trying Windows build...
flutter build windows --release
if not errorlevel 1 (
    echo SUCCESS: Windows build completed
    echo You can run the app at: build\windows\runner\Release\steps_conter_app.exe
    goto :success
)

echo.
echo Trying Android build with offline mode...
flutter build apk --debug --offline
if not errorlevel 1 (
    echo SUCCESS: Android offline build completed
    goto :success
)

echo.
echo Trying Android build with normal mode...
flutter build apk --debug
if not errorlevel 1 (
    echo SUCCESS: Android build completed
    goto :success
)

echo.
echo ERROR: All build attempts failed
echo Please check the NETWORK_TROUBLESHOOTING.md file for more solutions
pause
exit /b 1

:success
echo.
echo ================================================
echo Build completed successfully!
echo ================================================
pause
