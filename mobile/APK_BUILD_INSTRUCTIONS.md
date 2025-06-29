# Cinemer APK Build Instructions

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and available in your PATH
2. **Android SDK** - Install the Android SDK (either through Android Studio or command-line tools)
3. **Java Development Kit (JDK)** - Version 11 or newer is recommended

## Step 1: Set up Android SDK

If you haven't installed Android Studio:

1. Download Android command-line tools from: https://developer.android.com/studio#command-tools
2. Extract the downloaded ZIP to a location on your computer
3. Set up environment variables:
   ```bash
   export ANDROID_HOME=/path/to/android/sdk
   export PATH=$PATH:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools
   ```
4. Install required SDK components:
   ```bash
   sdkmanager --install "platforms;android-33" "build-tools;33.0.2" "platform-tools"
   ```
5. Accept all licenses:
   ```bash
   sdkmanager --licenses
   ```

If you have Android Studio installed, you can skip these steps as it manages the SDK for you.

## Step 2: Update Dependencies

In the `mobile` directory, run:
```bash
flutter pub get
```

## Step 3: Build the APK

### Option 1: Using the provided script

Run the build script:
```bash
./build_apk.sh
```

### Option 2: Manual build

Run the following command in the `mobile` directory:
```bash
flutter build apk --release
```

## Step 4: Locate the APK

After a successful build, your APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

- If you get errors about missing Android SDK, make sure your environment variables are set correctly.
- If you get build errors, try running `flutter clean` and then rebuild.
- For signing issues, you'll need to set up a keystore. See the [Flutter documentation](https://docs.flutter.dev/deployment/android#signing-the-app).

## Additional Resources

- [Flutter Documentation: Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Android SDK Setup Guide](https://developer.android.com/studio)
