#!/bin/bash
set -e  # Exit on any error

echo "Building Flutter APK..."

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build APK (Release)
echo "Building release APK..."
flutter build apk --release

echo ""
echo "✅ APK build complete!"
echo "📦 APK location: build/app/outputs/flutter-apk/app-release.apk"
echo ""
echo "To build a split APK (smaller size, for specific architectures):"
echo "  flutter build apk --split-per-abi"
echo ""
echo "To build an App Bundle (for Google Play Store):"
echo "  flutter build appbundle --release"

