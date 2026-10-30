@echo off
echo Building ColorNote x Simple Notepad Release APK...
call flutter create --platforms=android --org com.colornote.merged .
call flutter pub get
call flutter build apk --release
echo.
echo Done! Your installable APK is at:
echo build\app\outputs\flutter-apk\app-release.apk
pause
