# Phase 10: Production Launch - Implementation Guide

## Overview

Phase 10 implements production monitoring, analytics, crash reporting, and post-launch infrastructure for Hisaab.

## What's Included

### 1. Firebase Integration

**Services Implemented:**
- ✅ **Firebase Analytics** - User behavior tracking
- ✅ **Firebase Crashlytics** - Crash reporting and error monitoring
- ✅ **Firebase Performance** - Performance monitoring and optimization
- ✅ **In-App Review** - App Store review prompts

**Files Created:**
```
lib/core/services/
├── analytics_service.dart      # Analytics wrapper with 30+ custom events
├── crashlytics_service.dart    # Crash reporting and error logging
├── performance_service.dart    # Performance traces and monitoring
├── feedback_service.dart       # User feedback collection
└── review_service.dart         # In-app review prompt logic
```

### 2. Production Build Scripts

**Scripts:**
```
scripts/
├── build_production.sh   # Automated production build script
└── bump_version.sh       # Version management script
```

**Features:**
- Automated build process with validation
- Version bump automation
- Signature verification
- Build info generation
- Error handling and rollback

### 3. Comprehensive Documentation

**Guides:**
```
deployment/docs/
├── FIREBASE_SETUP.md           # Complete Firebase integration guide
└── POST_LAUNCH_MONITORING.md   # Post-launch monitoring and KPIs
```

**Content:**
- Step-by-step Firebase setup
- Monitoring dashboard configuration
- KPI tracking guidelines
- Incident response procedures
- First week launch checklist

### 4. Dependencies Added

**pubspec.yaml additions:**
```yaml
# Firebase
firebase_core: ^3.6.0
firebase_analytics: ^11.3.3
firebase_crashlytics: ^4.1.3
firebase_performance: ^0.10.0+8

# In-App Review
in_app_review: ^2.0.9
```

---

## Quick Start Guide

### Step 1: Firebase Setup

1. Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com/)
2. Add Android app with package: `com.hisaab.app`
3. Download `google-services.json`
4. Place file in `android/app/google-services.json`
5. Follow complete instructions in `deployment/docs/FIREBASE_SETUP.md`

### Step 2: Update Android Configuration

**Add to `android/build.gradle`:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.1'
        classpath 'com.google.firebase:firebase-crashlytics-gradle:3.0.2'
        classpath 'com.google.firebase:perf-plugin:1.4.2'
    }
}
```

**Add to `android/app/build.gradle` (after android block):**
```gradle
apply plugin: 'com.google.gms.google-services'
apply plugin: 'com.google.firebase.crashlytics'
apply plugin: 'com.google.firebase.firebase-perf'
```

### Step 3: Initialize Firebase in App

Update `lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'core/services/analytics_service.dart';
import 'core/services/crashlytics_service.dart';
import 'core/services/performance_service.dart';
import 'core/services/review_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize services
  final analyticsService = AnalyticsService();
  final crashlyticsService = CrashlyticsService();
  final performanceService = PerformanceService();
  final reviewService = ReviewService();

  await crashlyticsService.initialize();
  await performanceService.initialize();
  await reviewService.initialize();

  runApp(MyApp(
    analyticsService: analyticsService,
    crashlyticsService: crashlyticsService,
    performanceService: performanceService,
    reviewService: reviewService,
  ));
}
```

### Step 4: Install Dependencies

```bash
flutter pub get
```

### Step 5: Build Production Release

```bash
# Make script executable (first time only)
chmod +x scripts/build_production.sh

# Run production build
./scripts/build_production.sh
```

---

## Analytics Implementation

### Key Events Tracked

**Customer Operations:**
- `customer_added`
- `customer_updated`
- `customer_deleted`
- `customer_viewed`

**Transaction Operations:**
- `transaction_added` (with type and amount)
- `transaction_updated`
- `transaction_deleted`

**Invoice Operations:**
- `invoice_created` (with item count, amount, payment status)
- `invoice_shared` (with share method)
- `invoice_payment_updated`

**Report Operations:**
- `report_generated` (with report type)
- `report_exported` (with format)
- `report_shared`

**Expense & Reminder Operations:**
- `expense_added` (with category and amount)
- `reminder_set` (with type and days ahead)
- `reminder_sent`

**Settings & Backup:**
- `backup_created` (with backup type)
- `backup_restored`
- `data_exported` (with data type and format)
- `language_changed`
- `theme_changed`

**User Feedback:**
- `feedback_submitted`
- `app_rated`
- `review_prompted`

### Usage Example

```dart
// In your customer repository
class CustomerRepositoryImpl {
  final AnalyticsService _analyticsService;

  Future<Either<Failure, int>> addCustomer(Customer customer) async {
    try {
      final id = await dao.insertCustomer(customer);

      // Track analytics event
      await _analyticsService.logCustomerAdded();

      return Right(id);
    } catch (e) {
      // Log error to Crashlytics
      await _crashlyticsService.logCustomerError(
        operation: 'add',
        error: e,
      );
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
```

---

## Crashlytics Implementation

### Automatic Error Handling

Crashlytics automatically captures:
- Uncaught Flutter exceptions
- Uncaught async errors
- Native Android crashes

### Manual Error Logging

```dart
// Log non-fatal error
await crashlyticsService.logError(
  error: exception,
  stackTrace: stackTrace,
  reason: 'Description of what happened',
  fatal: false,
);

// Log with context
await crashlyticsService.logException(
  exception: exception,
  stackTrace: stackTrace,
  context: {
    'user_action': 'adding_customer',
    'customer_id': '123',
  },
);
```

### Custom Keys for Debugging

```dart
// Set custom keys to help debug crashes
await crashlyticsService.setCustomKeys({
  'last_screen': 'CustomerListScreen',
  'database_version': '1',
  'customer_count': '50',
});
```

### Breadcrumb Logging

```dart
// Log breadcrumbs for debugging
await crashlyticsService.logUserAction('add_customer');
await crashlyticsService.logScreenView('CustomerDetailScreen');
await crashlyticsService.logDatabaseOperation(
  operation: 'INSERT',
  table: 'customers',
  success: true,
);
```

---

## Performance Monitoring

### Automatic Traces

Firebase automatically tracks:
- App start time
- Screen rendering performance
- HTTP requests (when implemented)

### Custom Performance Traces

**Database Operations:**
```dart
// Track database query performance
await performanceService.startDatabaseQueryTrace(
  operation: 'SELECT',
  table: 'customers',
);

// ... perform query

await performanceService.stopDatabaseQueryTrace(
  operation: 'SELECT',
  table: 'customers',
  rowCount: results.length,
);
```

**Report Generation:**
```dart
await performanceService.startReportTrace('LEDGER');
// ... generate report
await performanceService.stopReportTrace('LEDGER', dataSize: 100);
```

**PDF Generation:**
```dart
await performanceService.startPdfGenerationTrace('INVOICE');
// ... generate PDF
await performanceService.stopPdfGenerationTrace(
  'INVOICE',
  pageCount: 2,
  fileSizeKb: 150,
);
```

**Screen Load Times:**
```dart
// Track screen load performance
@override
void initState() {
  super.initState();
  performanceService.startScreenTrace('CustomerList');
}

@override
void dispose() {
  performanceService.stopScreenTrace('CustomerList');
  super.dispose();
}
```

---

## User Feedback System

### Feedback Methods

**General Feedback:**
```dart
await feedbackService.sendGeneralFeedback(
  subject: 'Feature Request',
  body: 'I would like to see...',
);
```

**Bug Reports:**
```dart
await feedbackService.sendBugReport(
  bugTitle: 'App crashes when adding customer',
  bugDescription: 'Detailed description...',
  stepsToReproduce: '1. Open app\n2. Click add customer\n3. Crash',
  expectedBehavior: 'Customer should be added',
  actualBehavior: 'App crashes',
);
```

**Feature Requests:**
```dart
await feedbackService.sendFeatureRequest(
  featureTitle: 'Barcode Scanner',
  featureDescription: 'Add barcode scanning for products',
  useCases: 'Quick product entry for inventory',
);
```

**Support Requests:**
```dart
await feedbackService.sendSupportRequest(
  issue: 'Cannot export report',
  details: 'Export button not working...',
);
```

### Automatic System Info

All feedback emails automatically include:
- Device model and manufacturer
- Android version
- App version and build number
- Device ID (for debugging)

---

## In-App Review System

### Automatic Review Prompts

The review service intelligently prompts users based on:
- **App launches:** Minimum 5 launches
- **Significant actions:** Minimum 10 actions (adding customers, transactions, etc.)
- **Time between prompts:** Minimum 30 days
- **Review status:** Not already reviewed or recently declined

### Triggering Reviews

**Automatic (Recommended):**
```dart
// After significant action
await reviewService.incrementSignificantAction();

// Check and show if eligible
await reviewService.showReviewPromptIfEligible();
```

**Manual Trigger:**
```dart
// Force show review prompt (for testing or specific events)
await reviewService.manualReviewPrompt();
```

**Open Play Store:**
```dart
// Direct user to Play Store for review
await reviewService.openPlayStore();
```

### Track Significant Actions

Add to key user actions:
```dart
// After customer added
await reviewService.incrementSignificantAction();

// After invoice created
await reviewService.incrementSignificantAction();

// After report generated
await reviewService.incrementSignificantAction();
```

---

## Production Build Process

### Using Build Script

```bash
# Navigate to project root
cd hisaab

# Run production build
./scripts/build_production.sh
```

**Script performs:**
1. ✅ Clean previous builds
2. ✅ Get dependencies
3. ✅ Run code generation
4. ✅ Check signing configuration
5. ✅ Run all tests
6. ✅ Analyze code
7. ✅ Build release app bundle
8. ✅ Verify signature
9. ✅ Generate build info

**Output:**
- App bundle: `build/app/outputs/bundle/release/app-release.aab`
- Build info: `build/build_info.txt`

### Version Management

```bash
# Bump version interactively
./scripts/bump_version.sh

# Options:
# 1. Major version (2.0.0)
# 2. Minor version (1.1.0)
# 3. Patch version (1.0.1)
# 4. Build number only (1.0.0+2)
# 5. Custom version
```

Script can automatically:
- Update `pubspec.yaml`
- Create git commit
- Create git tag
- Push to remote

---

## Monitoring Setup

### Day 1: Immediate Setup

1. **Firebase Console**
   - Verify app is receiving analytics events
   - Check Crashlytics dashboard (should show 0 crashes)
   - Bookmark Firebase dashboards

2. **Play Console**
   - Monitor installation numbers
   - Check crash reports
   - Respond to first reviews

3. **Email Alerts**
   - Configure Firebase crash alerts
   - Set up Play Console notifications

### Week 1: Daily Monitoring

**Morning Checklist (10 minutes):**
- [ ] Check crash-free rate (target: > 99%)
- [ ] Review new crash reports
- [ ] Check DAU/MAU numbers
- [ ] Read Play Store reviews
- [ ] Check support email

### Ongoing: Weekly Review

**Weekly Review (30 minutes):**
- [ ] Analyze weekly trends
- [ ] Review top crashes
- [ ] Check performance metrics
- [ ] Review retention rates
- [ ] Plan next update

See `deployment/docs/POST_LAUNCH_MONITORING.md` for complete monitoring guide.

---

## Key Performance Indicators (KPIs)

### Success Metrics (3 Months)

| Metric | Target | Good | Excellent |
|--------|--------|------|-----------|
| Total Installs | 1,000+ | 5,000+ | 10,000+ |
| Crash-Free Rate | 99%+ | 99.5%+ | 99.9%+ |
| Play Store Rating | 4.0+ | 4.3+ | 4.5+ |
| Day 1 Retention | 35%+ | 45%+ | 55%+ |
| Day 7 Retention | 15%+ | 25%+ | 35%+ |
| Avg Session Duration | 5+ min | 10+ min | 15+ min |

### Red Flags

Immediate action required if:
- ⚠️ Crash-free rate < 98%
- ⚠️ Average rating < 4.0
- ⚠️ Multiple data loss reports
- ⚠️ App start time > 5 seconds
- ⚠️ Sudden spike in uninstalls

---

## Troubleshooting

### Firebase Not Working

1. Verify `google-services.json` location
2. Check Firebase initialization in `main.dart`
3. Verify Gradle plugins are applied
4. Clean and rebuild: `flutter clean && flutter pub get`

### Analytics Events Not Showing

1. Use DebugView in Firebase (debug mode)
2. Wait up to 24 hours for production data
3. Verify events are being logged correctly

### Crashlytics Not Showing Crashes

1. Wait 5-10 minutes after crash
2. Ensure app is in release mode
3. Check Crashlytics is enabled in Firebase Console

### Build Script Fails

1. Check signing configuration exists
2. Verify all tests pass
3. Fix code analysis issues
4. Check Flutter version compatibility

---

## Documentation Links

- **Firebase Setup:** `deployment/docs/FIREBASE_SETUP.md`
- **Post-Launch Monitoring:** `deployment/docs/POST_LAUNCH_MONITORING.md`
- **Deployment Checklist:** `deployment/DEPLOYMENT_CHECKLIST.md`
- **Play Store Guide:** `deployment/store/PLAY_STORE_GUIDE.md`

---

## Support

**Firebase Issues:**
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Support](https://firebase.google.com/support)

**Deployment Issues:**
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Android Deployment Guide](https://docs.flutter.dev/deployment/android)

---

## Phase 10 Checklist

### Pre-Launch
- [ ] Firebase project created
- [ ] google-services.json configured
- [ ] Gradle plugins added
- [ ] Services initialized in main.dart
- [ ] Analytics events implemented
- [ ] Crashlytics error handling added
- [ ] Performance traces implemented
- [ ] Feedback system integrated
- [ ] Review prompts configured
- [ ] Build script tested
- [ ] Production build successful

### Launch Day
- [ ] Upload app bundle to Play Console
- [ ] Submit for review
- [ ] Configure Firebase alerts
- [ ] Monitor crash reports (every 2 hours)
- [ ] Respond to first reviews
- [ ] Check Analytics dashboard

### First Week
- [ ] Daily monitoring checklist
- [ ] Respond to all reviews
- [ ] Fix critical bugs immediately
- [ ] Gather user feedback
- [ ] Plan first update

---

**Phase 10 is complete!** Your app is now ready for production launch with comprehensive monitoring and analytics. 🚀

For deployment instructions, proceed to `deployment/DEPLOYMENT_CHECKLIST.md`.
