#!/bin/bash
set -e  # Exit on any error

# Install Flutter SDK
echo "Installing Flutter SDK..."
if [ ! -d "flutter" ]; then
git clone https://github.com/flutter/flutter.git -b stable --depth 1
fi
export PATH="$PATH:$PWD/flutter/bin"

# Verify Flutter installation
echo "Verifying Flutter installation..."
flutter --version

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web release
echo "Building Flutter web release..."
flutter build web --release

echo "Build complete!"
