# Beta Testing Guide - Hisaab

## Overview

Beta testing is crucial for identifying bugs, gathering feedback, and ensuring app quality before public release. This guide outlines the beta testing process for Hisaab.

## Beta Testing Tracks

### 1. Internal Testing

**Purpose**: Initial testing by development team

**Duration**: 1-2 weeks

**Participants**:
- Developers
- QA team
- Product managers
- Internal stakeholders

**Distribution**:
- Google Play Console → Release → Testing → Internal testing
- Add testers by email address
- Instant app access (no approval needed)

**Focus Areas**:
- Core functionality testing
- Critical bug identification
- Basic user flows
- Performance issues

### 2. Closed Testing (Alpha)

**Purpose**: Testing with trusted external users

**Duration**: 2-4 weeks

**Participants**:
- 50-100 selected users
- Early adopters
- Business owners (target audience)
- Accounting professionals

**Distribution**:
- Create closed testing track in Play Console
- Send invitation links to testers
- Require testers to accept invitation

**Focus Areas**:
- Real-world usage scenarios
- Feature completeness
- UI/UX feedback
- Performance on various devices
- Data accuracy

### 3. Open Testing (Beta)

**Purpose**: Public beta with broader audience

**Duration**: 4-6 weeks

**Participants**:
- Unlimited users
- General public interested in app
- Can be limited to specific countries

**Distribution**:
- Create open testing track
- Publicly accessible via Play Store link
- Optional: Limit to specific countries (India initially)

**Focus Areas**:
- Large-scale testing
- Edge cases
- Device compatibility
- Network conditions
- Final polish

## Setting Up Beta Testing

### Step 1: Prepare Beta Build

```bash
# Increment version for beta
# pubspec.yaml: version: 1.0.0-beta.1+1

# Build app bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### Step 2: Create Testing Track

1. Open [Google Play Console](https://play.google.com/console)
2. Select your app
3. Navigate to Release → Testing
4. Choose track type (Internal/Closed/Open)
5. Create new release
6. Upload app bundle (.aab)
7. Fill release notes
8. Save and review
9. Start rollout

### Step 3: Add Testers

**Internal Testing:**
```
1. Testing → Internal testing → Testers
2. Create email list
3. Add tester emails (one per line)
4. Save
```

**Closed Testing:**
```
1. Testing → Closed testing → Testers
2. Create tester list
3. Add emails or create opt-in URL
4. Share invitation link
```

**Open Testing:**
```
1. Testing → Open testing
2. Opt-in URL is automatically generated
3. Share publicly or limit by country
```

### Step 4: Distribute Invitation

**Email Template for Closed Beta:**

```
Subject: Join Hisaab Beta Testing Program

Hello [Name],

You're invited to join the beta testing program for Hisaab, a new business accounting app designed for small businesses in India.

What is Hisaab?
Hisaab helps you manage customers, track transactions, generate invoices, and create business reports - all for free and completely offline.

Why We Need Your Help:
We're looking for feedback from real business owners to help us improve the app before public launch.

How to Join:
1. Click this link: [Beta Testing Opt-in URL]
2. Accept the invitation
3. Download Hisaab from Google Play Store
4. Start testing and send us feedback!

What to Test:
• Add your real customers and transactions
• Create invoices
• Generate reports
• Try all features
• Report any bugs or issues

Feedback:
Send feedback to beta@hisaab.app or use in-app feedback button

Testing Period: [Start Date] to [End Date]

Thank you for helping us build a better app!

Best regards,
Hisaab Team
```

## Beta Testing Checklist

### Pre-Beta Checklist

- [ ] All critical features implemented
- [ ] Internal testing completed
- [ ] Known bugs documented
- [ ] Release notes prepared
- [ ] Privacy policy published
- [ ] Feedback mechanism ready
- [ ] Analytics/crash reporting enabled
- [ ] Beta version number updated

### During Beta Checklist

- [ ] Monitor crash reports daily
- [ ] Respond to feedback within 24-48 hours
- [ ] Track and prioritize bugs
- [ ] Release updates as needed
- [ ] Collect usage analytics
- [ ] Document feature requests
- [ ] Engage with active testers
- [ ] Survey testers for satisfaction

### Post-Beta Checklist

- [ ] Review all feedback
- [ ] Fix critical bugs
- [ ] Implement important feature requests
- [ ] Prepare final release notes
- [ ] Thank beta testers
- [ ] Plan production release
- [ ] Update documentation
- [ ] Prepare marketing materials

## Feedback Collection

### In-App Feedback

Implement feedback button in app settings:

```dart
// Add to settings screen
ListTile(
  leading: Icon(Icons.feedback),
  title: Text('Send Feedback'),
  subtitle: Text('Report bugs or suggest features'),
  onTap: () async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'beta@hisaab.app',
      queryParameters: {
        'subject': 'Hisaab Beta Feedback - v1.0.0-beta.1',
        'body': '''
Device: ${await getDeviceInfo()}
Android Version: ${await getAndroidVersion()}
App Version: 1.0.0-beta.1

Feedback:
[Your feedback here]
        ''',
      },
    );
    await launchUrl(emailUri);
  },
)
```

### Feedback Form

Create Google Form for structured feedback:

**Questions:**
1. How did you use Hisaab? (Daily/Weekly/Rarely)
2. What features did you use most?
3. What features are missing?
4. Did you encounter any bugs? (Describe)
5. How would you rate the app? (1-5 stars)
6. Would you recommend Hisaab? (Yes/No)
7. Additional comments

**Form URL**: Share via email and in-app

### Bug Reporting Template

```markdown
## Bug Report

**App Version**: 1.0.0-beta.1
**Device**: [e.g., Samsung Galaxy S21]
**Android Version**: [e.g., 12]

**Steps to Reproduce**:
1. [First step]
2. [Second step]
3. [Third step]

**Expected Behavior**:
[What should happen]

**Actual Behavior**:
[What actually happened]

**Screenshots** (if applicable):
[Attach screenshots]

**Additional Context**:
[Any other relevant information]
```

## Testing Scenarios

### Scenario 1: New User Onboarding

1. Install app for first time
2. Complete onboarding flow
3. Set up business profile
4. Add first customer
5. Record first transaction
6. Generate first report

**Success Criteria**: User completes all steps without confusion

### Scenario 2: Daily Business Operations

1. Open app
2. Add 5-10 new transactions
3. Create 2-3 invoices
4. Add new customers
5. Check customer balances
6. Generate daybook report

**Success Criteria**: All operations complete successfully and quickly

### Scenario 3: Month-End Tasks

1. Review all transactions for the month
2. Generate ledger reports for top customers
3. Create profit & loss report
4. Export data to Excel
5. Create backup
6. Share reports via email

**Success Criteria**: All reports generate correctly with accurate data

### Scenario 4: Data Management

1. Add bulk customers (20+)
2. Add bulk transactions (50+)
3. Search for specific customer
4. Filter transactions by date
5. Edit customer details
6. Delete old transactions
7. Restore backup

**Success Criteria**: App handles large datasets without lag

### Scenario 5: Error Handling

1. Enter invalid data (empty fields, negative amounts)
2. Try to create invoice without items
3. Attempt to delete customer with transactions
4. Generate report with no data
5. Try to restore invalid backup

**Success Criteria**: App shows appropriate error messages, doesn't crash

## Analytics to Track

### Usage Metrics

- Daily active users (DAU)
- Session duration
- Feature usage frequency
- Screen navigation patterns
- Most used features

### Performance Metrics

- App launch time
- Database query speed
- PDF generation time
- Crash rate
- ANR (App Not Responding) rate

### Engagement Metrics

- Retention rate (Day 1, Day 7, Day 30)
- Number of customers added
- Number of transactions recorded
- Number of reports generated
- Backup usage

## Common Beta Issues

### Issue 1: Installation Problems

**Symptom**: Can't install or update app
**Cause**: Device compatibility, storage space
**Solution**: Check device requirements, clear space

### Issue 2: Data Loss

**Symptom**: Data disappears after update
**Cause**: Database migration issue
**Solution**: Implement proper migration, add backups

### Issue 3: Crashes on Specific Devices

**Symptom**: App crashes on certain devices
**Cause**: Device-specific compatibility issue
**Solution**: Test on multiple devices, fix compatibility

### Issue 4: Performance Issues

**Symptom**: App is slow or laggy
**Cause**: Inefficient database queries, UI blocking operations
**Solution**: Optimize queries, use background tasks

### Issue 5: UI/UX Confusion

**Symptom**: Users can't find features or get confused
**Cause**: Unclear navigation, poor labeling
**Solution**: Improve UI, add onboarding, better labels

## Beta Communication Plan

### Week 1
- Send welcome email
- Gather initial feedback
- Address critical bugs

### Week 2-3
- Send mid-beta survey
- Release bug fix update
- Share progress report

### Week 4
- Send final survey
- Collect feature requests
- Announce production timeline

### Post-Beta
- Thank you email with discount/feature (if applicable)
- Announce production release date
- Invite to join early access program

## Success Metrics

**Beta is successful if:**
- [ ] 80%+ of testers use app at least 3 times
- [ ] Crash rate < 1%
- [ ] Average rating 4+ stars
- [ ] 50%+ would recommend app
- [ ] All critical bugs identified and fixed
- [ ] At least 20 pieces of constructive feedback received

## Graduation to Production

**Requirements to exit beta:**
- [ ] All critical bugs fixed
- [ ] Crash rate < 0.5%
- [ ] Performance metrics meet targets
- [ ] Positive feedback from majority of testers
- [ ] Core features fully tested
- [ ] Documentation complete
- [ ] Support system ready

## Resources

- [Google Play Console - Testing](https://play.google.com/console/about/testing/)
- [Android Beta Testing Best Practices](https://developer.android.com/distribute/best-practices/launch/beta-tests)
- [Pre-Launch Reports](https://developer.android.com/distribute/console/pre-launch-reports)

---

**Remember**: Beta testers are your most valuable users. Treat their feedback as gold and show appreciation for their time!
