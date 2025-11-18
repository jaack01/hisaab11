# Firebase Setup Guide - Hisaab

## Overview

This guide explains how to set up Firebase for Hisaab, including Analytics, Crashlytics, and Performance Monitoring.

## Prerequisites

- Google account
- Access to [Firebase Console](https://console.firebase.google.com/)
- Android app already created (package: `com.hisaab.app`)
- Upload keystore generated (for SHA-1 certificate)

---

## Step 1: Create Firebase Project

### 1.1 Create New Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or **"Create a project"**
3. Enter project details:
   - **Project name:** `Hisaab` (or your preferred name)
   - **Project ID:** Auto-generated (e.g., `hisaab-12345`)
4. Click **Continue**

### 1.2 Enable Google Analytics

1. Toggle **"Enable Google Analytics for this project"** to ON
2. Click **Continue**
3. Select or create Analytics account:
   - **Account name:** `Hisaab Analytics`
   - **Location:** India (or your location)
   - Accept terms and conditions
4. Click **Create project**

Wait for project creation (takes 30-60 seconds).

---

## Step 2: Add Android App to Firebase

### 2.1 Register App

1. In Firebase Console, click **"Add app"** → **Android**
2. Fill in app details:

```
Android package name: com.hisaab.app
App nickname (optional): Hisaab
Debug signing certificate SHA-1: [See step 2.2]
```

### 2.2 Get SHA-1 Certificate

For **upload keystore:**

```bash
keytool -list -v -keystore ~/hisaab-upload-key.jks -alias hisaab-key
```

Look for:
```
SHA1: AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12
```

Copy this SHA-1 and paste in Firebase console.

**Why SHA-1 is needed:**
- Google Sign-In (future)
- Dynamic Links (future)
- Cloud Messaging
- App integrity verification

### 2.3 Register App

Click **"Register app"**

---

## Step 3: Download Configuration File

### 3.1 Download google-services.json

1. Firebase will show download button
2. Click **"Download google-services.json"**
3. Save the file

### 3.2 Add to Project

**Location:** Place file in:
```
hisaab/
└── android/
    └── app/
        └── google-services.json  ← HERE
```

**Command:**
```bash
# From project root
mv ~/Downloads/google-services.json android/app/
```

### 3.3 Verify File Content

Open `android/app/google-services.json` and verify:

```json
{
  "project_info": {
    "project_number": "123456789",
    "project_id": "hisaab-12345",
    "storage_bucket": "hisaab-12345.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:123456789:android:abcdef123456",
        "android_client_info": {
          "package_name": "com.hisaab.app"
        }
      }
    }
  ]
}
```

**Important:** Add to `.gitignore` if it contains sensitive data:
```bash
echo "android/app/google-services.json" >> .gitignore
```

---

## Step 4: Configure Android Project

### 4.1 Update Project-Level build.gradle

**File:** `android/build.gradle`

Add Google Services classpath:

```gradle
buildscript {
    dependencies {
        // ... existing dependencies
        classpath 'com.google.gms:google-services:4.4.1'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:3.0.2'
        classpath 'com.google.firebase:perf-plugin:1.4.2'
    }
}
```

### 4.2 Update App-Level build.gradle

**File:** `android/app/build.gradle`

Add plugins at the TOP (after existing plugins):

```gradle
plugins {
    // ... existing plugins
}

apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
apply plugin: 'com.google.firebase.firebase-perf'
```

**IMPORTANT:** Apply plugins AFTER the `android` block.

**Full structure:**
```gradle
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    // ... android configuration
}

dependencies {
    // ... dependencies
}

// Apply Firebase plugins AFTER android block
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
apply plugin: 'com.google.firebase.firebase-perf'
```

### 4.3 Verify Gradle Files

Run:
```bash
cd android
./gradlew --version
./gradlew tasks
cd ..
```

If no errors, configuration is correct!

---

## Step 5: Initialize Firebase in Flutter App

### 5.1 Update main.dart

**File:** `lib/main.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// Import services
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/performance_service.dart';
import 'core/services/review_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize services
  final analyticsService = AnalyticsService();
  final crashlyticsService = CrashlyticsService();
  final performanceService = PerformanceService();
  final reviewService = ReviewService();

  // Initialize Crashlytics error handling
  await crashlyticsService.initialize();

  // Initialize performance monitoring
  await performanceService.initialize();

  // Initialize review service
  await reviewService.initialize();

  // Start app initialization trace
  final appInitTrace = await performanceService.startAppInitTrace();

  // Run app
  runApp(MyApp(
    analyticsService: analyticsService,
    crashlyticsService: crashlyticsService,
    performanceService: performanceService,
    reviewService: reviewService,
  ));

  // Stop app initialization trace
  await performanceService.stopAppInitTrace();
}

class MyApp extends StatelessWidget {
  final AnalyticsService analyticsService;
  final CrashlyticsService crashlyticsService;
  final PerformanceService performanceService;
  final ReviewService reviewService;

  const MyApp({
    super.key,
    required this.analyticsService,
    required this.crashlyticsService,
    required this.performanceService,
    required this.reviewService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hisaab',

      // Add Firebase Analytics observer for screen tracking
      navigatorObservers: [
        analyticsService.getAnalyticsObserver(),
      ],

      // Your existing app configuration
      home: HomePage(),
    );
  }
}
```

### 5.2 Test Firebase Integration

Run the app:
```bash
flutter run --release
```

Check logs for:
```
✓ Firebase initialized successfully
✓ Crashlytics initialized successfully
✓ Performance monitoring initialized
```

---

## Step 6: Enable Firebase Services

### 6.1 Enable Analytics

1. In Firebase Console, go to **Analytics** → **Dashboard**
2. Analytics is enabled by default
3. Verify data collection is ON
4. Check **DebugView** for real-time events (in debug mode)

**Test Analytics:**
```dart
// In your code
await analyticsService.logCustomerAdded();
```

Check Firebase Console → Analytics → DebugView (within 10 minutes).

### 6.2 Enable Crashlytics

1. In Firebase Console, go to **Crashlytics**
2. Click **"Enable Crashlytics"**
3. Wait for first crash report (or force a test crash)

**Test Crashlytics:**
```dart
// Test crash (DEBUG MODE ONLY)
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  await crashlyticsService.forceCrash();
}
```

Check Firebase Console → Crashlytics (crashes appear within 5 minutes).

### 6.3 Enable Performance Monitoring

1. In Firebase Console, go to **Performance**
2. Performance is enabled by default
3. Wait for first data (may take 12-24 hours)

**Test Performance:**
```dart
// Trace a database operation
final trace = await performanceService.startDatabaseQueryTrace(
  operation: 'SELECT',
  table: 'customers',
);
// ... perform database operation
await performanceService.stopDatabaseQueryTrace(
  operation: 'SELECT',
  table: 'customers',
  rowCount: 10,
);
```

Check Firebase Console → Performance (data appears within 12 hours).

---

## Step 7: Configure Crashlytics for Production

### 7.1 NDK Crash Reporting (Optional)

For native crash reporting, add to `android/app/build.gradle`:

```gradle
android {
    buildTypes {
        release {
            // ... existing config

            // Enable NDK crash reporting
            ndk {
                debugSymbolLevel 'FULL'
            }
        }
    }
}
```

### 7.2 ProGuard Mapping Files

Ensure Crashlytics uploads ProGuard mapping files for deobfuscation.

In `android/app/build.gradle`:

```gradle
buildTypes {
    release {
        // ... existing config
        minifyEnabled true
        shrinkResources true

        // Crashlytics will automatically upload mapping files
        firebaseCrashlytics {
            mappingFileUploadEnabled true
        }
    }
}
```

---

## Step 8: Verify Setup

### 8.1 Build and Test

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build release
flutter build appbundle --release
```

### 8.2 Check for Errors

Look for these in build output:
```
✓ Firebase services configured
✓ google-services.json found
✓ Crashlytics plugin applied
✓ Performance plugin applied
```

### 8.3 Test on Device

Install release build on device:
```bash
flutter install --release
```

Use the app for 5-10 minutes, then check Firebase Console:
- **Analytics:** Should show events
- **Crashlytics:** Should show zero crashes (good!)
- **Performance:** Should show traces (after 12 hours)

---

## Step 9: Configure Analytics Events

### 9.1 Important Events to Track

In your app code, add analytics calls:

**Customer operations:**
```dart
await analyticsService.logCustomerAdded();
await analyticsService.logCustomerViewed();
await analyticsService.logCustomerUpdated();
```

**Transaction operations:**
```dart
await analyticsService.logTransactionAdded(
  transactionType: 'CREDIT',
  amount: 1000.0,
);
```

**Invoice operations:**
```dart
await analyticsService.logInvoiceCreated(
  itemCount: 5,
  totalAmount: 5000.0,
  paymentStatus: 'PAID',
);
```

**Report generation:**
```dart
await analyticsService.logReportGenerated(reportType: 'LEDGER');
await analyticsService.logReportExported(
  reportType: 'LEDGER',
  format: 'PDF',
);
```

### 9.2 Screen View Tracking

Automatically tracked by Firebase Analytics observer in MaterialApp.

Manual tracking (if needed):
```dart
await analyticsService.logScreenView(
  screenName: 'CustomerListScreen',
  screenClass: 'CustomerListScreen',
);
```

---

## Step 10: Configure Performance Traces

### 10.1 Automatic Traces

Firebase automatically tracks:
- App start time
- Screen rendering
- Network requests (when added)

### 10.2 Custom Traces

Add custom traces for critical operations:

**Database operations:**
```dart
final trace = await performanceService.startDatabaseQueryTrace(
  operation: 'INSERT',
  table: 'transactions',
);

// Perform database operation
await transactionDao.insertTransaction(transaction);

await performanceService.stopDatabaseQueryTrace(
  operation: 'INSERT',
  table: 'transactions',
  rowCount: 1,
);
```

**Report generation:**
```dart
await performanceService.startReportTrace('LEDGER');
// Generate report
await performanceService.stopReportTrace('LEDGER', dataSize: 100);
```

**PDF generation:**
```dart
await performanceService.startPdfGenerationTrace('INVOICE');
// Generate PDF
await performanceService.stopPdfGenerationTrace(
  'INVOICE',
  pageCount: 2,
  fileSizeKb: 150,
);
```

---

## Troubleshooting

### Issue 1: "google-services.json not found"

**Solution:**
1. Verify file location: `android/app/google-services.json`
2. Check file is not in `.gitignore` (if it should be tracked)
3. Run `flutter clean` and `flutter pub get`

### Issue 2: "Default Firebase app not initialized"

**Solution:**
1. Ensure `Firebase.initializeApp()` is called in `main()`
2. Ensure `WidgetsFlutterBinding.ensureInitialized()` is called first
3. Check `google-services.json` is valid

### Issue 3: Crashlytics not showing crashes

**Solution:**
1. Wait 5-10 minutes after crash
2. Ensure app is in release mode
3. Check Crashlytics is enabled in Firebase Console
4. Verify `com.google.firebase.crashlytics` plugin is applied

### Issue 4: Analytics events not appearing

**Solution:**
1. Use DebugView for real-time testing (debug mode only)
2. Wait up to 24 hours for production data
3. Verify Analytics is enabled in Firebase Console
4. Check events are being logged correctly

### Issue 5: Performance data not showing

**Solution:**
1. Wait 12-24 hours after first app usage
2. Ensure app has sufficient usage (> 10 sessions)
3. Verify Performance plugin is applied
4. Check custom traces are started and stopped correctly

---

## Production Checklist

Before launching to production:

- [ ] Firebase project created
- [ ] Android app registered with correct package name
- [ ] SHA-1 certificate added
- [ ] google-services.json downloaded and placed correctly
- [ ] Gradle plugins configured
- [ ] Firebase initialized in main.dart
- [ ] Analytics events implemented
- [ ] Crashlytics error handling set up
- [ ] Performance traces added for critical operations
- [ ] Test build successful
- [ ] Test on device successful
- [ ] Events appearing in Firebase Console (test mode)
- [ ] Team has access to Firebase Console
- [ ] Email alerts configured
- [ ] ProGuard mapping file upload enabled

---

## Firebase Console Quick Links

After setup, bookmark these:

- **Firebase Console:** https://console.firebase.google.com/
- **Analytics Dashboard:** https://console.firebase.google.com/project/[PROJECT_ID]/analytics
- **Crashlytics:** https://console.firebase.google.com/project/[PROJECT_ID]/crashlytics
- **Performance:** https://console.firebase.google.com/project/[PROJECT_ID]/performance

Replace `[PROJECT_ID]` with your actual Firebase project ID.

---

## Next Steps

After Firebase is set up:

1. **Test thoroughly** - Use the app for a few days and monitor Firebase
2. **Configure alerts** - Set up email alerts for crashes
3. **Review analytics** - Understand user behavior
4. **Optimize performance** - Use Performance data to optimize
5. **Read monitoring guide** - See `POST_LAUNCH_MONITORING.md`

---

## Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Analytics](https://firebase.google.com/docs/analytics)
- [Firebase Crashlytics](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance](https://firebase.google.com/docs/perf-mon)

---

**Need Help?** Check the [Firebase Support](https://firebase.google.com/support) page or Stack Overflow with tag `firebase`.
