# 📱 Building APK for Voice Notes Plus

## Prerequisites

To build an APK, you need to install **Android SDK**. Here's how:

### Step 1: Install Android Studio

1. **Download Android Studio:**
   - Visit: https://developer.android.com/studio
   - Download and install Android Studio

2. **During Installation:**
   - Make sure to install:
     - Android SDK
     - Android SDK Platform-Tools
     - Android SDK Build-Tools
     - Android Emulator (optional, for testing)

3. **After Installation:**
   - Open Android Studio
   - Go to **Tools → SDK Manager**
   - Install:
     - Android SDK Platform (API 33 or latest)
     - Android SDK Build-Tools
     - Android SDK Command-line Tools

### Step 2: Set Environment Variables (Optional but Recommended)

1. **Find your Android SDK location:**
   - Usually: `C:\Users\YourUsername\AppData\Local\Android\Sdk`
   - Or check in Android Studio: **Tools → SDK Manager → Android SDK Location**

2. **Set ANDROID_HOME:**
   - Open **System Properties → Environment Variables**
   - Add new variable:
     - **Variable name:** `ANDROID_HOME`
     - **Variable value:** `C:\Users\YourUsername\AppData\Local\Android\Sdk`
   - Add to PATH: `%ANDROID_HOME%\platform-tools` and `%ANDROID_HOME%\tools`

3. **Restart your terminal/IDE** after setting environment variables

### Step 3: Verify Setup

Run this command to check:
```bash
flutter doctor
```

You should see:
```
[√] Android toolchain - develop for Android devices
```

---

## Building the APK

### Option 1: Using the Build Script (Easiest)

```bash
bash build_apk.sh
```

### Option 2: Manual Build Commands

#### Build Release APK (Single file for all architectures):
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/app-release.apk`

#### Build Split APK (Smaller size, separate files per architecture):
```bash
flutter build apk --split-per-abi --release
```

**Output:** 
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit)
- `build/app/outputs/flutter-apk/app-x86_64-release.apk` (x86_64)

#### Build App Bundle (For Google Play Store):
```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

---

## APK File Locations

After building, your APK will be in:
- **Single APK:** `build/app/outputs/flutter-apk/app-release.apk`
- **Split APKs:** `build/app/outputs/flutter-apk/` (multiple files)
- **App Bundle:** `build/app/outputs/bundle/release/app-release.aab`

---

## Installing the APK

### On Android Device:

1. **Enable Developer Options:**
   - Go to **Settings → About Phone**
   - Tap **Build Number** 7 times
   - Go back to **Settings → Developer Options**
   - Enable **USB Debugging**

2. **Transfer APK to Phone:**
   - Connect phone via USB, OR
   - Transfer APK file via email/cloud storage

3. **Install:**
   - Open the APK file on your phone
   - Allow installation from unknown sources if prompted
   - Tap **Install**

### Using ADB (Command Line):

```bash
# Connect your phone via USB
# Then run:
flutter install
# Or manually:
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Troubleshooting

### ❌ "No Android SDK found"

**Solution:**
1. Install Android Studio
2. Set ANDROID_HOME environment variable
3. Run `flutter doctor --android-licenses` and accept all licenses

### ❌ "Gradle build failed"

**Solution:**
1. Check internet connection (Gradle downloads dependencies)
2. Try: `cd android && ./gradlew clean && cd ..`
3. Then: `flutter clean && flutter pub get`

### ❌ "SDK location not found"

**Solution:**
1. Create `android/local.properties` file
2. Add: `sdk.dir=C:\\Users\\YourUsername\\AppData\\Local\\Android\\Sdk`
3. Use double backslashes `\\` in Windows paths

---

## Quick Commands Reference

```bash
# Check Flutter setup
flutter doctor

# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Build split APK (smaller)
flutter build apk --split-per-abi --release

# Build App Bundle (for Play Store)
flutter build appbundle --release

# Install on connected device
flutter install
```

---

## Next Steps

After building your APK:
1. ✅ Test it on a real Android device
2. ✅ Check all features work correctly
3. ✅ For Play Store: Build App Bundle instead of APK
4. ✅ Sign your app with a release key (for production)

---

**Need help?** Check Flutter's official guide: https://docs.flutter.dev/deployment/android



