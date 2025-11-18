import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Feedback service for collecting user feedback
///
/// This service provides methods for collecting and sending user
/// feedback via email, including device and app information.
class FeedbackService {
  final Logger _logger;

  FeedbackService({Logger? logger}) : _logger = logger ?? Logger();

  // Support email address
  static const String supportEmail = 'support@hisaab.app';
  static const String feedbackEmail = 'feedback@hisaab.app';
  static const String bugReportEmail = 'bugs@hisaab.app';

  // ============================================================================
  // Device & App Info
  // ============================================================================

  /// Get device information
  Future<Map<String, String>> getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      return {
        'Device': '${androidInfo.manufacturer} ${androidInfo.model}',
        'Android Version': 'Android ${androidInfo.version.release} (SDK ${androidInfo.version.sdkInt})',
        'Device ID': androidInfo.id,
        'Brand': androidInfo.brand,
        'Board': androidInfo.board,
        'Hardware': androidInfo.hardware,
      };
    } catch (e) {
      _logger.e('Failed to get device info: $e');
      return {'Device': 'Unknown', 'Android Version': 'Unknown'};
    }
  }

  /// Get app information
  Future<Map<String, String>> getAppInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      return {
        'App Name': packageInfo.appName,
        'Package Name': packageInfo.packageName,
        'Version': packageInfo.version,
        'Build Number': packageInfo.buildNumber,
      };
    } catch (e) {
      _logger.e('Failed to get app info: $e');
      return {
        'App Name': 'Hisaab',
        'Version': 'Unknown',
        'Build Number': 'Unknown',
      };
    }
  }

  /// Generate device and app info string
  Future<String> generateSystemInfo() async {
    final deviceInfo = await getDeviceInfo();
    final appInfo = await getAppInfo();

    final buffer = StringBuffer();
    buffer.writeln('\n--- System Information ---');

    // App info
    appInfo.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln();

    // Device info
    deviceInfo.forEach((key, value) {
      buffer.writeln('$key: $value');
    });

    buffer.writeln('-------------------------\n');

    return buffer.toString();
  }

  // ============================================================================
  // Feedback Submission
  // ============================================================================

  /// Send general feedback
  Future<bool> sendGeneralFeedback({
    String? subject,
    String? body,
  }) async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: feedbackEmail,
        queryParameters: {
          'subject': subject ?? 'Hisaab - General Feedback',
          'body': '''
${body ?? '[Your feedback here]'}

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to send general feedback: $e');
      return false;
    }
  }

  /// Send bug report
  Future<bool> sendBugReport({
    String? bugTitle,
    String? bugDescription,
    String? stepsToReproduce,
    String? expectedBehavior,
    String? actualBehavior,
  }) async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: bugReportEmail,
        queryParameters: {
          'subject': bugTitle ?? 'Hisaab - Bug Report',
          'body': '''
## Bug Report

**Bug Title:** ${bugTitle ?? '[Bug title]'}

**Description:**
${bugDescription ?? '[Describe the bug]'}

**Steps to Reproduce:**
${stepsToReproduce ?? '1. \n2. \n3. '}

**Expected Behavior:**
${expectedBehavior ?? '[What should happen]'}

**Actual Behavior:**
${actualBehavior ?? '[What actually happened]'}

**Screenshots:** (Attach if possible)

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to send bug report: $e');
      return false;
    }
  }

  /// Send feature request
  Future<bool> sendFeatureRequest({
    String? featureTitle,
    String? featureDescription,
    String? useCases,
  }) async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: feedbackEmail,
        queryParameters: {
          'subject': 'Hisaab - Feature Request: ${featureTitle ?? '[Feature]'}',
          'body': '''
## Feature Request

**Feature Title:** ${featureTitle ?? '[Feature title]'}

**Description:**
${featureDescription ?? '[Describe the feature]'}

**Use Cases:**
${useCases ?? '[How would you use this feature?]'}

**Additional Context:** (Optional)

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to send feature request: $e');
      return false;
    }
  }

  /// Send rating feedback
  Future<bool> sendRatingFeedback({
    required int rating,
    String? feedback,
  }) async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: feedbackEmail,
        queryParameters: {
          'subject': 'Hisaab - App Rating: $rating/5 stars',
          'body': '''
## App Rating Feedback

**Rating:** $rating/5 stars

**Feedback:**
${feedback ?? '[Optional feedback]'}

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to send rating feedback: $e');
      return false;
    }
  }

  /// Send support request
  Future<bool> sendSupportRequest({
    String? issue,
    String? details,
  }) async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: {
          'subject': 'Hisaab - Support Request',
          'body': '''
## Support Request

**Issue:** ${issue ?? '[Describe your issue]'}

**Details:**
${details ?? '[Provide more details]'}

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to send support request: $e');
      return false;
    }
  }

  // ============================================================================
  // Contact Methods
  // ============================================================================

  /// Send email to support
  Future<bool> contactSupport() async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: supportEmail,
        queryParameters: {
          'subject': 'Hisaab - Contact Support',
          'body': '''
[Your message here]

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to contact support: $e');
      return false;
    }
  }

  /// Report a data issue
  Future<bool> reportDataIssue({
    required String issueType,
    String? description,
  }) async {
    try {
      final systemInfo = await generateSystemInfo();

      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: bugReportEmail,
        queryParameters: {
          'subject': 'Hisaab - Data Issue: $issueType',
          'body': '''
## Data Issue Report

**Issue Type:** $issueType

**Description:**
${description ?? '[Describe the data issue]'}

**When did this occur?**
[Date and time]

**What data was affected?**
[Customer/Transaction/Invoice/etc.]

$systemInfo
          ''',
        },
      );

      return await _launchEmail(emailUri);
    } catch (e) {
      _logger.e('Failed to report data issue: $e');
      return false;
    }
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Launch email app
  Future<bool> _launchEmail(Uri emailUri) async {
    try {
      if (await canLaunchUrl(emailUri)) {
        final launched = await launchUrl(
          emailUri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          _logger.i('Email app launched successfully');
          return true;
        } else {
          _logger.w('Failed to launch email app');
          return false;
        }
      } else {
        _logger.w('Cannot launch email app');
        return false;
      }
    } catch (e) {
      _logger.e('Error launching email app: $e');
      return false;
    }
  }

  // ============================================================================
  // Quick Actions
  // ============================================================================

  /// Quick feedback with minimal info
  Future<bool> quickFeedback(String message) async {
    return await sendGeneralFeedback(
      subject: 'Quick Feedback',
      body: message,
    );
  }

  /// Quick bug report
  Future<bool> quickBugReport(String bugDescription) async {
    return await sendBugReport(
      bugTitle: 'Quick Bug Report',
      bugDescription: bugDescription,
    );
  }
}
