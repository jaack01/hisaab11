import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Crashlytics service wrapper for Firebase Crashlytics
///
/// This service provides crash reporting, error logging, and custom
/// key-value tracking for debugging production issues.
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;
  final Logger _logger;

  CrashlyticsService({
    FirebaseCrashlytics? crashlytics,
    Logger? logger,
  })  : _crashlytics = crashlytics ?? FirebaseCrashlytics.instance,
        _logger = logger ?? Logger();

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize Crashlytics with Flutter error handling
  Future<void> initialize() async {
    try {
      // Enable Crashlytics collection
      await _crashlytics.setCrashlyticsCollectionEnabled(true);

      // Pass all uncaught Flutter errors to Crashlytics
      FlutterError.onError = _crashlytics.recordFlutterFatalError;

      // Pass all uncaught asynchronous errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        _crashlytics.recordError(error, stack, fatal: true);
        return true;
      };

      _logger.i('Crashlytics initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize Crashlytics: $e');
    }
  }

  // ============================================================================
  // Error Logging
  // ============================================================================

  /// Log a non-fatal error
  Future<void> logError({
    required dynamic error,
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
      _logger.e('Error logged to Crashlytics: $error');
    } catch (e) {
      _logger.e('Failed to log error to Crashlytics: $e');
    }
  }

  /// Log a Flutter error
  Future<void> logFlutterError(FlutterErrorDetails details) async {
    try {
      await _crashlytics.recordFlutterError(details);
      _logger.e('Flutter error logged: ${details.exception}');
    } catch (e) {
      _logger.e('Failed to log Flutter error: $e');
    }
  }

  /// Log a custom exception with additional context
  Future<void> logException({
    required Exception exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) async {
    try {
      // Set context as custom keys
      if (context != null) {
        for (final entry in context.entries) {
          await setCustomKey(entry.key, entry.value.toString());
        }
      }

      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: exception.toString(),
        fatal: false,
      );

      _logger.e('Exception logged: $exception');
    } catch (e) {
      _logger.e('Failed to log exception: $e');
    }
  }

  // ============================================================================
  // Custom Keys (Debugging Context)
  // ============================================================================

  /// Set custom key-value pair for debugging
  Future<void> setCustomKey(String key, String value) async {
    try {
      await _crashlytics.setCustomKey(key, value);
      _logger.d('Custom key set: $key = $value');
    } catch (e) {
      _logger.e('Failed to set custom key: $e');
    }
  }

  /// Set multiple custom keys at once
  Future<void> setCustomKeys(Map<String, String> keys) async {
    try {
      for (final entry in keys.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
      _logger.d('Custom keys set: ${keys.length} keys');
    } catch (e) {
      _logger.e('Failed to set custom keys: $e');
    }
  }

  // ============================================================================
  // User Context
  // ============================================================================

  /// Set user identifier for crash reports
  Future<void> setUserIdentifier(String userId) async {
    try {
      await _crashlytics.setUserIdentifier(userId);
      _logger.d('User identifier set: $userId');
    } catch (e) {
      _logger.e('Failed to set user identifier: $e');
    }
  }

  /// Clear user identifier
  Future<void> clearUserIdentifier() async {
    try {
      await _crashlytics.setUserIdentifier('');
      _logger.d('User identifier cleared');
    } catch (e) {
      _logger.e('Failed to clear user identifier: $e');
    }
  }

  // ============================================================================
  // Breadcrumb Logging
  // ============================================================================

  /// Log a breadcrumb message for debugging
  Future<void> log(String message) async {
    try {
      await _crashlytics.log(message);
      _logger.d('Breadcrumb logged: $message');
    } catch (e) {
      _logger.e('Failed to log breadcrumb: $e');
    }
  }

  /// Log user action as breadcrumb
  Future<void> logUserAction(String action, {Map<String, dynamic>? data}) async {
    final message = data != null
        ? 'User Action: $action | Data: $data'
        : 'User Action: $action';
    await log(message);
  }

  /// Log screen view as breadcrumb
  Future<void> logScreenView(String screenName) async {
    await log('Screen View: $screenName');
  }

  // ============================================================================
  // Database Operations Logging
  // ============================================================================

  /// Log database operation
  Future<void> logDatabaseOperation({
    required String operation,
    required String table,
    bool success = true,
    String? error,
  }) async {
    final status = success ? 'SUCCESS' : 'FAILED';
    final message = 'DB Operation: $operation on $table - $status';
    await log(message);

    if (!success && error != null) {
      await setCustomKey('last_db_error', error);
    }
  }

  // ============================================================================
  // Network Operations Logging
  // ============================================================================

  /// Log network operation (for future API integrations)
  Future<void> logNetworkOperation({
    required String operation,
    required String endpoint,
    int? statusCode,
    bool success = true,
    String? error,
  }) async {
    final status = success ? 'SUCCESS' : 'FAILED';
    final message = 'Network: $operation $endpoint - $status '
        '${statusCode != null ? '(HTTP $statusCode)' : ''}';
    await log(message);

    if (!success && error != null) {
      await setCustomKey('last_network_error', error);
    }
  }

  // ============================================================================
  // Test Crash (Development Only)
  // ============================================================================

  /// Force a crash for testing Crashlytics (development only)
  void forceCrash() {
    if (kDebugMode) {
      _logger.w('Forcing crash for testing...');
      _crashlytics.crash();
    } else {
      _logger.w('Force crash ignored in production mode');
    }
  }

  // ============================================================================
  // Collection Control
  // ============================================================================

  /// Enable crash collection
  Future<void> enableCrashCollection() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      _logger.i('Crash collection enabled');
    } catch (e) {
      _logger.e('Failed to enable crash collection: $e');
    }
  }

  /// Disable crash collection
  Future<void> disableCrashCollection() async {
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(false);
      _logger.i('Crash collection disabled');
    } catch (e) {
      _logger.e('Failed to disable crash collection: $e');
    }
  }

  /// Check if crash collection is enabled
  Future<bool> isCrashCollectionEnabled() async {
    try {
      return await _crashlytics.isCrashlyticsCollectionEnabled();
    } catch (e) {
      _logger.e('Failed to check crash collection status: $e');
      return false;
    }
  }

  // ============================================================================
  // Unsent Reports
  // ============================================================================

  /// Check for unsent crash reports
  Future<bool> checkForUnsentReports() async {
    try {
      return await _crashlytics.checkForUnsentReports();
    } catch (e) {
      _logger.e('Failed to check for unsent reports: $e');
      return false;
    }
  }

  /// Delete unsent crash reports
  Future<void> deleteUnsentReports() async {
    try {
      await _crashlytics.deleteUnsentReports();
      _logger.i('Unsent reports deleted');
    } catch (e) {
      _logger.e('Failed to delete unsent reports: $e');
    }
  }

  /// Send unsent crash reports
  Future<void> sendUnsentReports() async {
    try {
      await _crashlytics.sendUnsentReports();
      _logger.i('Unsent reports sent');
    } catch (e) {
      _logger.e('Failed to send unsent reports: $e');
    }
  }

  // ============================================================================
  // App-Specific Error Handlers
  // ============================================================================

  /// Log customer operation error
  Future<void> logCustomerError({
    required String operation,
    required dynamic error,
    int? customerId,
  }) async {
    await setCustomKeys({
      'operation_type': 'customer',
      'operation': operation,
      if (customerId != null) 'customer_id': customerId.toString(),
    });
    await logError(error: error, reason: 'Customer operation failed');
  }

  /// Log transaction operation error
  Future<void> logTransactionError({
    required String operation,
    required dynamic error,
    int? transactionId,
  }) async {
    await setCustomKeys({
      'operation_type': 'transaction',
      'operation': operation,
      if (transactionId != null) 'transaction_id': transactionId.toString(),
    });
    await logError(error: error, reason: 'Transaction operation failed');
  }

  /// Log invoice operation error
  Future<void> logInvoiceError({
    required String operation,
    required dynamic error,
    int? invoiceId,
  }) async {
    await setCustomKeys({
      'operation_type': 'invoice',
      'operation': operation,
      if (invoiceId != null) 'invoice_id': invoiceId.toString(),
    });
    await logError(error: error, reason: 'Invoice operation failed');
  }

  /// Log report generation error
  Future<void> logReportError({
    required String reportType,
    required dynamic error,
  }) async {
    await setCustomKeys({
      'operation_type': 'report',
      'report_type': reportType,
    });
    await logError(error: error, reason: 'Report generation failed');
  }

  /// Log backup/restore error
  Future<void> logBackupError({
    required String operation,
    required dynamic error,
  }) async {
    await setCustomKeys({
      'operation_type': 'backup',
      'operation': operation,
    });
    await logError(error: error, reason: 'Backup operation failed');
  }
}
