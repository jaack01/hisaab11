# APK Build Guide - Hisaab

## Overview

This guide explains how to build an APK file for Hisaab that you can install on Android devices for testing.

**Important:** APK files are for testing only. For Google Play Store submission, use the app bundle (`.aab`) format via `./scripts/build_production.sh`.

---

## Prerequisites

Before building the APK, ensure you have:

- ✅ Flutter SDK installed (version 3.24+)
- ✅ Android SDK installed
- ✅ Flutter configured and working
- ✅ Project dependencies installed

### Verify Flutter Installation

```bash
flutter doctor
```

Expected output should show:
```
✓ Flutter (Channel stable, 3.24.x)
✓ Android toolchain - develop for Android devices
✓ Android Studio (or VS Code with Flutter plugin)
```

---

## Method 1: Using Build Script (Recommended)

### Step 1: Run Build Script

From the project root directory:

```bash
cd /path/to/hisaab
./scripts/build_apk.sh
```

The script will:
1. Clean previous builds
2. Get dependencies
3. Run code generation
4. Build release APK (split per ABI)
5. Show build information

### Step 2: Locate APK Files

APKs will be created in:
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk  (32-bit ARM, ~20MB)
├── app-arm64-v8a-release.apk    (64-bit ARM, ~25MB) ← Most common
└── app-x86_64-release.apk       (64-bit x86, ~25MB)
```

**Which APK to use?**
- **Most devices:** `app-arm64-v8a-release.apk` (64-bit ARM)
- **Older devices:** `app-armeabi-v7a-release.apk` (32-bit ARM)
- **Emulator:** `app-x86_64-release.apk` (x86 64-bit)

---

## Method 2: Manual Build (Command Line)

If the script doesn't work, build manually:

### Step 1: Clean Project

```bash
flutter clean
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

### Step 3: Build APK

**Option A: Build split APKs (smaller files, recommended):**
```bash
flutter build apk --release --split-per-abi
```

This creates separate APKs for each CPU architecture (~20-25MB each).

**Option B: Build universal APK (single file, larger):**
```bash
flutter build apk --release
```

This creates one APK that works on all devices (~40MB).

### Step 4: Locate APK

**For split APKs:**
```
build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
```

**For universal APK:**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Installing the APK

### Method 1: Install via ADB (USB Cable)

#### Prerequisites:
- USB cable
- USB debugging enabled on phone
- ADB installed

#### Steps:

1. **Enable USB Debugging on Phone:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect Phone to Computer:**
   - Plug in USB cable
   - Allow USB debugging when prompted on phone

3. **Install APK:**
   ```bash
   # Navigate to APK directory
   cd build/app/outputs/flutter-apk/

   # Install (replace with correct APK filename)
   adb install app-arm64-v8a-release.apk
   ```

4. **Launch App:**
   - Find "Hisaab" in app drawer
   - Tap to open

### Method 2: Install via File Transfer

#### Steps:

1. **Transfer APK to Phone:**
   - Connect phone via USB (MTP mode)
   - Copy APK file to phone's Downloads folder
   - OR send APK via email/messaging app

2. **Install APK on Phone:**
   - Open Files app on phone
   - Navigate to Downloads folder
   - Tap the APK file
   - Tap "Install"

3. **Allow Installation from Unknown Sources:**
   - If prompted, go to Settings → Security
   - Enable "Unknown Sources" or "Install Unknown Apps"
   - Allow installation from Files app
   - Go back and tap Install again

4. **Open App:**
   - Tap "Open" after installation
   - Or find "Hisaab" in app drawer

### Method 3: Share via Google Drive / Dropbox

1. Upload APK to cloud storage
2. Share link with testers
3. Download on phone
4. Install as described in Method 2

---

## Build Variants

### Debug Build (for development)

```bash
flutter build apk --debug
```

**Features:**
- Hot reload support
- Debug logging enabled
- Larger file size
- Not optimized

**Use for:** Active development only

### Profile Build (for testing performance)

```bash
flutter build apk --profile
```

**Features:**
- Performance profiling enabled
- Observatory/DevTools support
- Slightly optimized

**Use for:** Performance testing

### Release Build (for production testing)

```bash
flutter build apk --release
```

**Features:**
- Fully optimized
- No debug code
- Smallest file size
- Production-ready

**Use for:** Final testing before Play Store submission

---

## Troubleshooting

### Issue 1: "flutter: command not found"

**Solution:**
```bash
# Add Flutter to PATH (Linux/Mac)
export PATH="$PATH:/path/to/flutter/bin"

# Verify
flutter --version
```

### Issue 2: Build fails with dependency errors

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter pub upgrade
flutter build apk --release
```

### Issue 3: "Android licenses not accepted"

**Solution:**
```bash
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

### Issue 4: Out of memory during build

**Solution:**
```bash
# Increase Gradle memory
export GRADLE_OPTS="-Xmx4096m -XX:MaxPermSize=512m"
flutter build apk --release
```

### Issue 5: APK won't install on phone

**Possible causes:**
- Phone doesn't allow unknown sources
- Architecture mismatch (use arm64-v8a for modern phones)
- Insufficient storage space
- Previous version installed (uninstall first)

**Solutions:**
```bash
# Uninstall previous version first
adb uninstall com.hisaab.app

# Then install new version
adb install app-arm64-v8a-release.apk
```

### Issue 6: App crashes immediately after opening

**Causes:**
- Missing native libraries
- Firebase not configured (google-services.json)

**Solution for Firebase:**
If you see Firebase errors, you have two options:

1. **Set up Firebase** (recommended for production):
   - Follow `deployment/docs/FIREBASE_SETUP.md`
   - Add `google-services.json` to `android/app/`
   - Rebuild APK

2. **Disable Firebase** (temporary workaround):
   - Comment out Firebase initialization in `lib/main.dart`
   - Rebuild APK

---

## Build Configuration

### Build Flavors (Future Enhancement)

You can create build flavors for different environments:

**android/app/build.gradle:**
```gradle
android {
    flavorDimensions "environment"
    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
        }
        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
        }
        prod {
            dimension "environment"
        }
    }
}
```

**Build flavor APK:**
```bash
flutter build apk --release --flavor dev
flutter build apk --release --flavor staging
flutter build apk --release --flavor prod
```

---

## APK vs AAB (App Bundle)

### APK (Android Package)

**Pros:**
- ✅ Direct installation on devices
- ✅ No Play Store required
- ✅ Can share with testers easily
- ✅ Works offline

**Cons:**
- ❌ Larger file size
- ❌ Not optimized per device
- ❌ Required for Play Store submission

**Use for:** Testing, internal distribution, beta testing

### AAB (Android App Bundle)

**Pros:**
- ✅ Smaller downloads for users
- ✅ Optimized per device
- ✅ Required by Play Store
- ✅ Supports dynamic delivery

**Cons:**
- ❌ Cannot install directly
- ❌ Must upload to Play Store
- ❌ Requires Play Store infrastructure

**Use for:** Production Play Store releases

**Build AAB:**
```bash
./scripts/build_production.sh
# or
flutter build appbundle --release
```

---

## APK Signing

### Debug Signing (Automatic)

APKs built without signing configuration are automatically signed with debug key.

**Location:** `~/.android/debug.keystore`

**Use for:** Development and testing only

### Release Signing (Required for Production)

For production APKs, configure signing:

**Step 1: Create keystore** (if not already created)
```bash
keytool -genkey -v -keystore ~/hisaab-upload-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias hisaab-key
```

**Step 2: Create key.properties**
```bash
# android/key.properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=hisaab-key
storeFile=/path/to/hisaab-upload-key.jks
```

**Step 3: Update build.gradle**

See `deployment/docs/APP_SIGNING.md` for complete instructions.

**Step 4: Build signed APK**
```bash
flutter build apk --release
```

---

## Testing the APK

### Recommended Testing Checklist

Before distributing APK to testers:

- [ ] App launches successfully
- [ ] All core features work:
  - [ ] Add customer
  - [ ] Add transaction
  - [ ] Create invoice
  - [ ] Generate reports
  - [ ] Create backup
  - [ ] Restore backup
- [ ] No crashes or ANRs
- [ ] Performance is acceptable
- [ ] UI renders correctly on different screen sizes
- [ ] Language switching works (English ↔ Hindi)
- [ ] Data persists after app restart
- [ ] Export/share features work

### Testing on Multiple Devices

**Minimum test devices:**
- One phone (Android 6.0+)
- One tablet (optional)
- Different screen sizes
- Different Android versions

**Common test devices:**
- Samsung Galaxy (One UI)
- Google Pixel (Stock Android)
- Xiaomi/Redmi (MIUI)
- OnePlus (OxygenOS)

---

## Distribution to Testers

### Option 1: Direct APK Sharing

**Pros:** Simple, fast
**Cons:** Manual updates

1. Build APK
2. Share via email, Drive, Dropbox
3. Testers install manually

### Option 2: Firebase App Distribution

**Pros:** Automatic updates, analytics
**Cons:** Requires Firebase setup

1. Set up Firebase project
2. Install Firebase CLI
3. Upload APK:
   ```bash
   firebase appdistribution:distribute \
     build/app/outputs/flutter-apk/app-release.apk \
     --app YOUR_APP_ID \
     --groups testers
   ```

### Option 3: Google Play Internal Testing

**Pros:** Play Store infrastructure, easy updates
**Cons:** Requires Play Console

1. Upload APK to Play Console
2. Create internal testing track
3. Add testers by email
4. Testers download from Play Store

---

## Quick Reference Commands

```bash
# Clean build
flutter clean && flutter pub get

# Build split APKs (recommended)
flutter build apk --release --split-per-abi

# Build universal APK
flutter build apk --release

# Build debug APK
flutter build apk --debug

# Install via ADB
adb install build/app/outputs/flutter-apk/app-arm64-v8a-release.apk

# Uninstall from device
adb uninstall com.hisaab.app

# List connected devices
adb devices

# View app logs
adb logcat | grep flutter
```

---

## File Locations Reference

```
hisaab/
├── scripts/
│   └── build_apk.sh              # Automated build script
├── build/
│   ├── app/outputs/flutter-apk/  # APK output directory
│   │   ├── app-armeabi-v7a-release.apk
│   │   ├── app-arm64-v8a-release.apk
│   │   └── app-x86_64-release.apk
│   └── apk_build_info.txt        # Build information
└── BUILD_APK_GUIDE.md            # This guide
```

---

## Next Steps

After building and testing APK:

1. **Test thoroughly** on real devices
2. **Gather feedback** from testers
3. **Fix bugs** if any found
4. **Optimize performance** if needed
5. **Prepare for Play Store** using `./scripts/build_production.sh`

---

## Resources

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Android Debug Bridge (ADB)](https://developer.android.com/studio/command-line/adb)
- [APK Signing](https://developer.android.com/studio/publish/app-signing)
- [Play Store Requirements](https://support.google.com/googleplay/android-developer/answer/9859152)

---

**Happy Testing!** 🚀

For production deployment, see `deployment/DEPLOYMENT_CHECKLIST.md`.
