#!/bin/bash

# This script builds the APK for Cinemer

# Check if Android SDK is available
if [ -z "$ANDROID_SDK_ROOT" ] && [ -z "$ANDROID_HOME" ]; then
  echo "Error: Android SDK not found. Please set ANDROID_SDK_ROOT or ANDROID_HOME environment variable."
  exit 1
fi

# Navigate to the mobile directory
cd "$(dirname "$0")"

# Ensure Flutter dependencies are up to date
flutter pub get

# Build the APK
echo "Building APK..."
flutter build apk --release

if [ $? -eq 0 ]; then
  APK_PATH="$(pwd)/build/app/outputs/flutter-apk/app-release.apk"
  echo "APK built successfully at: $APK_PATH"
  echo "Size: $(ls -lh $APK_PATH | awk '{print $5}')"
else
  echo "APK build failed."
  exit 1
fi
