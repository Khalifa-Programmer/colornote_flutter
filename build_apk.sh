#!/usr/bin/env bash
set -e
echo "Building ColorNote x Simple Notepad Release APK..."
flutter create --platforms=android --org com.colornote.merged .
flutter pub get
flutter build apk --release
echo "Done! Your installable APK is at: build/app/outputs/flutter-apk/app-release.apk"
