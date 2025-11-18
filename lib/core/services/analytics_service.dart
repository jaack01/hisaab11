import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

/// Analytics service wrapper for Firebase Analytics
///
/// This service provides a clean interface for tracking user events,
/// screen views, and user properties throughout the app.
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final Logger _logger;

  AnalyticsService({
    FirebaseAnalytics? analytics,
    Logger? logger,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _logger = logger ?? Logger();

  /// Get Firebase Analytics observer for navigation tracking
  FirebaseAnalyticsObserver getAnalyticsObserver() {
    return FirebaseAnalyticsObserver(analytics: _analytics);
  }

  // ============================================================================
  // Screen View Events
  // ============================================================================

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      _logger.d('Screen view logged: $screenName');
    } catch (e) {
      _logger.e('Failed to log screen view: $e');
    }
  }

  // ============================================================================
  // Customer Events
  // ============================================================================

  /// Log customer added event
  Future<void> logCustomerAdded() async {
    await _logEvent('customer_added');
  }

  /// Log customer updated event
  Future<void> logCustomerUpdated() async {
    await _logEvent('customer_updated');
  }

  /// Log customer deleted event
  Future<void> logCustomerDeleted() async {
    await _logEvent('customer_deleted');
  }

  /// Log customer viewed event
  Future<void> logCustomerViewed() async {
    await _logEvent('customer_viewed');
  }

  // ============================================================================
  // Transaction Events
  // ============================================================================

  /// Log transaction added event
  Future<void> logTransactionAdded({
    required String transactionType,
    required double amount,
  }) async {
    await _logEvent(
      'transaction_added',
      parameters: {
        'transaction_type': transactionType,
        'amount': amount,
      },
    );
  }

  /// Log transaction updated event
  Future<void> logTransactionUpdated() async {
    await _logEvent('transaction_updated');
  }

  /// Log transaction deleted event
  Future<void> logTransactionDeleted() async {
    await _logEvent('transaction_deleted');
  }

  // ============================================================================
  // Invoice Events
  // ============================================================================

  /// Log invoice created event
  Future<void> logInvoiceCreated({
    required int itemCount,
    required double totalAmount,
    required String paymentStatus,
  }) async {
    await _logEvent(
      'invoice_created',
      parameters: {
        'item_count': itemCount,
        'total_amount': totalAmount,
        'payment_status': paymentStatus,
      },
    );
  }

  /// Log invoice shared event
  Future<void> logInvoiceShared({required String shareMethod}) async {
    await _logEvent(
      'invoice_shared',
      parameters: {'share_method': shareMethod},
    );
  }

  /// Log invoice payment updated event
  Future<void> logInvoicePaymentUpdated({
    required String oldStatus,
    required String newStatus,
  }) async {
    await _logEvent(
      'invoice_payment_updated',
      parameters: {
        'old_status': oldStatus,
        'new_status': newStatus,
      },
    );
  }

  // ============================================================================
  // Report Events
  // ============================================================================

  /// Log report generated event
  Future<void> logReportGenerated({required String reportType}) async {
    await _logEvent(
      'report_generated',
      parameters: {'report_type': reportType},
    );
  }

  /// Log report exported event
  Future<void> logReportExported({
    required String reportType,
    required String format,
  }) async {
    await _logEvent(
      'report_exported',
      parameters: {
        'report_type': reportType,
        'format': format,
      },
    );
  }

  /// Log report shared event
  Future<void> logReportShared({required String reportType}) async {
    await _logEvent(
      'report_shared',
      parameters: {'report_type': reportType},
    );
  }

  // ============================================================================
  // Expense Events
  // ============================================================================

  /// Log expense added event
  Future<void> logExpenseAdded({
    required String category,
    required double amount,
  }) async {
    await _logEvent(
      'expense_added',
      parameters: {
        'category': category,
        'amount': amount,
      },
    );
  }

  /// Log expense deleted event
  Future<void> logExpenseDeleted() async {
    await _logEvent('expense_deleted');
  }

  // ============================================================================
  // Reminder Events
  // ============================================================================

  /// Log reminder set event
  Future<void> logReminderSet({
    required String reminderType,
    required int daysAhead,
  }) async {
    await _logEvent(
      'reminder_set',
      parameters: {
        'reminder_type': reminderType,
        'days_ahead': daysAhead,
      },
    );
  }

  /// Log reminder sent event
  Future<void> logReminderSent({required String method}) async {
    await _logEvent(
      'reminder_sent',
      parameters: {'method': method},
    );
  }

  // ============================================================================
  // Backup & Export Events
  // ============================================================================

  /// Log backup created event
  Future<void> logBackupCreated({required String backupType}) async {
    await _logEvent(
      'backup_created',
      parameters: {'backup_type': backupType},
    );
  }

  /// Log backup restored event
  Future<void> logBackupRestored() async {
    await _logEvent('backup_restored');
  }

  /// Log data exported event
  Future<void> logDataExported({
    required String dataType,
    required String format,
  }) async {
    await _logEvent(
      'data_exported',
      parameters: {
        'data_type': dataType,
        'format': format,
      },
    );
  }

  // ============================================================================
  // Settings Events
  // ============================================================================

  /// Log language changed event
  Future<void> logLanguageChanged({required String language}) async {
    await _logEvent(
      'language_changed',
      parameters: {'language': language},
    );
  }

  /// Log theme changed event
  Future<void> logThemeChanged({required String theme}) async {
    await _logEvent(
      'theme_changed',
      parameters: {'theme': theme},
    );
  }

  /// Log auto-backup toggled event
  Future<void> logAutoBackupToggled({required bool enabled}) async {
    await _logEvent(
      'auto_backup_toggled',
      parameters: {'enabled': enabled},
    );
  }

  // ============================================================================
  // App Lifecycle Events
  // ============================================================================

  /// Log app opened event
  Future<void> logAppOpened() async {
    await _logEvent('app_opened');
  }

  /// Log onboarding completed event
  Future<void> logOnboardingCompleted() async {
    await _logEvent('onboarding_completed');
  }

  /// Log feature discovery event
  Future<void> logFeatureDiscovered({required String featureName}) async {
    await _logEvent(
      'feature_discovered',
      parameters: {'feature_name': featureName},
    );
  }

  // ============================================================================
  // User Feedback Events
  // ============================================================================

  /// Log feedback submitted event
  Future<void> logFeedbackSubmitted({required String feedbackType}) async {
    await _logEvent(
      'feedback_submitted',
      parameters: {'feedback_type': feedbackType},
    );
  }

  /// Log app rated event
  Future<void> logAppRated({required int rating}) async {
    await _logEvent(
      'app_rated',
      parameters: {'rating': rating},
    );
  }

  /// Log review prompted event
  Future<void> logReviewPrompted() async {
    await _logEvent('review_prompted');
  }

  // ============================================================================
  // Error Events
  // ============================================================================

  /// Log error event
  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
  }) async {
    await _logEvent(
      'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        if (stackTrace != null) 'stack_trace': stackTrace,
      },
    );
  }

  // ============================================================================
  // User Properties
  // ============================================================================

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _logger.d('User property set: $name = $value');
    } catch (e) {
      _logger.e('Failed to set user property: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _logger.d('User ID set: $userId');
    } catch (e) {
      _logger.e('Failed to set user ID: $e');
    }
  }

  // ============================================================================
  // Private Helper Methods
  // ============================================================================

  /// Log custom event
  Future<void> _logEvent(
    String eventName, {
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      _logger.d('Event logged: $eventName ${parameters ?? ''}');
    } catch (e) {
      _logger.e('Failed to log event $eventName: $e');
    }
  }

  /// Enable analytics collection
  Future<void> enableAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(true);
      _logger.i('Analytics collection enabled');
    } catch (e) {
      _logger.e('Failed to enable analytics: $e');
    }
  }

  /// Disable analytics collection
  Future<void> disableAnalytics() async {
    try {
      await _analytics.setAnalyticsCollectionEnabled(false);
      _logger.i('Analytics collection disabled');
    } catch (e) {
      _logger.e('Failed to disable analytics: $e');
    }
  }
}
