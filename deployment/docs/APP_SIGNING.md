# App Signing Configuration Guide - Hisaab

## Overview

This guide explains how to set up app signing for the Hisaab application for Google Play Store deployment.

## Prerequisites

- Java JDK installed
- Android Studio or command-line tools
- Access to secure key storage

## Step 1: Generate Upload Keystore

### Using Command Line

```bash
keytool -genkey -v -keystore ~/hisaab-upload-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias hisaab-key
```

### Information to Provide

When prompted, provide the following information:

```
Enter keystore password: [CREATE_STRONG_PASSWORD]
Re-enter new password: [CONFIRM_PASSWORD]
What is your first and last name? [Your Name or Company Name]
What is the name of your organizational unit? [Development Team]
What is the name of your organization? [Company Name]
What is the name of your City or Locality? [City]
What is the name of your State or Province? [State]
What is the two-letter country code for this unit? [IN]
Is CN=..., OU=..., O=..., L=..., ST=..., C=... correct? [yes]

Enter key password for <hisaab-key>
  (RETURN if same as keystore password): [PRESS ENTER or CREATE DIFFERENT PASSWORD]
```

### Security Best Practices

⚠️ **IMPORTANT**: Store these credentials securely!

1. **Keystore Password**: Strong password (minimum 12 characters)
2. **Key Password**: Can be same as keystore password
3. **Backup**: Store keystore file in multiple secure locations
4. **Never commit**: Add `*.jks` to `.gitignore`

## Step 2: Configure Android Build

### Create key.properties File

Create `android/key.properties` file (this file should NOT be committed to git):

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=hisaab-key
storeFile=/path/to/hisaab-upload-key.jks
```

⚠️ Add to `.gitignore`:
```
android/key.properties
*.jks
```

### Update android/app/build.gradle

Add before `android {` block:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

Add inside `android {` block:

```gradle
android {
    ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release

            // Enable ProGuard
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

## Step 3: Build Signed Release APK

### Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build APK (Alternative)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

## Step 4: Verify Signature

### Verify App Bundle

```bash
jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab
```

### Check Certificate

```bash
keytool -list -v -keystore ~/hisaab-upload-key.jks -alias hisaab-key
```

## Build Flavors Configuration

### Define Flavors in android/app/build.gradle

```gradle
android {
    ...

    flavorDimensions "environment"

    productFlavors {
        dev {
            dimension "environment"
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue "string", "app_name", "Hisaab Dev"
        }

        staging {
            dimension "environment"
            applicationIdSuffix ".staging"
            versionNameSuffix "-staging"
            resValue "string", "app_name", "Hisaab Staging"
        }

        prod {
            dimension "environment"
            resValue "string", "app_name", "Hisaab"
        }
    }
}
```

### Build Specific Flavor

```bash
# Development
flutter build apk --release --flavor dev

# Staging
flutter build apk --release --flavor staging

# Production
flutter build appbundle --release --flavor prod
```

## Google Play App Signing

### Enable Play App Signing

1. Upload your first release
2. Google Play Console → Release → Setup → App signing
3. Enroll in Play App Signing
4. Upload upload certificate (from your keystore)

### Benefits

- Google manages and secures your app signing key
- Use upload key for all future releases
- Google re-signs with app signing key
- Lost key recovery possible

## Keystore Management

### Backup Keystore

```bash
# Create encrypted backup
gpg -c ~/hisaab-upload-key.jks

# Store in multiple locations:
# 1. Secure cloud storage (encrypted)
# 2. External hard drive (encrypted)
# 3. Company vault/password manager
```

### Password Management

Store passwords in a secure password manager:
- LastPass
- 1Password
- Bitwarden
- Company enterprise solution

### Team Access

If working in a team:
1. Store keystore in secure shared storage
2. Use encrypted password sharing
3. Document access procedures
4. Maintain access log

## Troubleshooting

### Issue: "Keystore was tampered with"

```bash
# Verify keystore integrity
keytool -list -keystore ~/hisaab-upload-key.jks
```

### Issue: "Wrong password"

- Double-check key.properties values
- Ensure no extra spaces in passwords
- Verify keystore file path is correct

### Issue: "Certificate fingerprint mismatch"

- You're using wrong keystore
- Verify you're using the upload keystore
- Check Google Play Console for correct fingerprint

## Security Checklist

- [ ] Strong keystore password (12+ characters)
- [ ] Keystore file backed up in 3+ locations
- [ ] key.properties added to .gitignore
- [ ] Passwords stored in secure password manager
- [ ] ProGuard rules configured
- [ ] Test release build before submission
- [ ] Certificate fingerprints documented
- [ ] Team members trained on signing process

## Version Management

### Update Version Numbers

In `pubspec.yaml`:

```yaml
version: 1.0.0+1
# Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

For each release:
```yaml
version: 1.0.1+2  # Bug fix
version: 1.1.0+3  # New features
version: 2.0.0+4  # Breaking changes
```

## References

- [Android App Signing Documentation](https://developer.android.com/studio/publish/app-signing)
- [Flutter Build and Release](https://docs.flutter.dev/deployment/android)
- [Google Play App Signing](https://support.google.com/googleplay/android-developer/answer/9842756)
