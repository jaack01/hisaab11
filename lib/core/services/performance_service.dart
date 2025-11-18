import 'package:firebase_performance/firebase_performance.dart';
import 'package:logger/logger.dart';

/// Performance monitoring service wrapper for Firebase Performance
///
/// This service provides performance tracking for app operations,
/// including screen load times, database queries, and custom traces.
class PerformanceService {
  final FirebasePerformance _performance;
  final Logger _logger;

  // Active traces cache
  final Map<String, Trace> _activeTraces = {};

  PerformanceService({
    FirebasePerformance? performance,
    Logger? logger,
  })  : _performance = performance ?? FirebasePerformance.instance,
        _logger = logger ?? Logger();

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize performance monitoring
  Future<void> initialize() async {
    try {
      await _performance.setPerformanceCollectionEnabled(true);
      _logger.i('Performance monitoring initialized');
    } catch (e) {
      _logger.e('Failed to initialize performance monitoring: $e');
    }
  }

  // ============================================================================
  // Custom Traces
  // ============================================================================

  /// Start a custom trace
  Future<Trace?> startTrace(String traceName) async {
    try {
      final trace = _performance.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;
      _logger.d('Trace started: $traceName');
      return trace;
    } catch (e) {
      _logger.e('Failed to start trace $traceName: $e');
      return null;
    }
  }

  /// Stop a custom trace
  Future<void> stopTrace(String traceName) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        await trace.stop();
        _activeTraces.remove(traceName);
        _logger.d('Trace stopped: $traceName');
      } else {
        _logger.w('Trace not found: $traceName');
      }
    } catch (e) {
      _logger.e('Failed to stop trace $traceName: $e');
    }
  }

  /// Set metric for a trace
  Future<void> setTraceMetric({
    required String traceName,
    required String metricName,
    required int value,
  }) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.setMetric(metricName, value);
        _logger.d('Metric set: $traceName.$metricName = $value');
      } else {
        _logger.w('Trace not found: $traceName');
      }
    } catch (e) {
      _logger.e('Failed to set metric: $e');
    }
  }

  /// Increment metric for a trace
  Future<void> incrementTraceMetric({
    required String traceName,
    required String metricName,
    int incrementBy = 1,
  }) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.incrementMetric(metricName, incrementBy);
        _logger.d('Metric incremented: $traceName.$metricName +$incrementBy');
      } else {
        _logger.w('Trace not found: $traceName');
      }
    } catch (e) {
      _logger.e('Failed to increment metric: $e');
    }
  }

  /// Set custom attribute for a trace
  Future<void> setTraceAttribute({
    required String traceName,
    required String attributeName,
    required String attributeValue,
  }) async {
    try {
      final trace = _activeTraces[traceName];
      if (trace != null) {
        trace.putAttribute(attributeName, attributeValue);
        _logger.d('Attribute set: $traceName.$attributeName = $attributeValue');
      } else {
        _logger.w('Trace not found: $traceName');
      }
    } catch (e) {
      _logger.e('Failed to set attribute: $e');
    }
  }

  // ============================================================================
  // Screen Performance Traces
  // ============================================================================

  /// Start screen load trace
  Future<Trace?> startScreenTrace(String screenName) async {
    return await startTrace('screen_$screenName');
  }

  /// Stop screen load trace
  Future<void> stopScreenTrace(String screenName) async {
    await stopTrace('screen_$screenName');
  }

  // ============================================================================
  // Database Performance Traces
  // ============================================================================

  /// Start database query trace
  Future<Trace?> startDatabaseQueryTrace({
    required String operation,
    required String table,
  }) async {
    final traceName = 'db_${operation}_$table';
    final trace = await startTrace(traceName);
    if (trace != null) {
      await setTraceAttribute(
        traceName: traceName,
        attributeName: 'operation',
        attributeValue: operation,
      );
      await setTraceAttribute(
        traceName: traceName,
        attributeName: 'table',
        attributeValue: table,
      );
    }
    return trace;
  }

  /// Stop database query trace
  Future<void> stopDatabaseQueryTrace({
    required String operation,
    required String table,
    int? rowCount,
  }) async {
    final traceName = 'db_${operation}_$table';
    if (rowCount != null) {
      await setTraceMetric(
        traceName: traceName,
        metricName: 'row_count',
        value: rowCount,
      );
    }
    await stopTrace(traceName);
  }

  // ============================================================================
  // Report Generation Performance Traces
  // ============================================================================

  /// Start report generation trace
  Future<Trace?> startReportTrace(String reportType) async {
    final traceName = 'report_$reportType';
    final trace = await startTrace(traceName);
    if (trace != null) {
      await setTraceAttribute(
        traceName: traceName,
        attributeName: 'report_type',
        attributeValue: reportType,
      );
    }
    return trace;
  }

  /// Stop report generation trace
  Future<void> stopReportTrace(String reportType, {int? dataSize}) async {
    final traceName = 'report_$reportType';
    if (dataSize != null) {
      await setTraceMetric(
        traceName: traceName,
        metricName: 'data_size',
        value: dataSize,
      );
    }
    await stopTrace(traceName);
  }

  // ============================================================================
  // PDF Generation Performance Traces
  // ============================================================================

  /// Start PDF generation trace
  Future<Trace?> startPdfGenerationTrace(String documentType) async {
    final traceName = 'pdf_$documentType';
    final trace = await startTrace(traceName);
    if (trace != null) {
      await setTraceAttribute(
        traceName: traceName,
        attributeName: 'document_type',
        attributeValue: documentType,
      );
    }
    return trace;
  }

  /// Stop PDF generation trace
  Future<void> stopPdfGenerationTrace(
    String documentType, {
    int? pageCount,
    int? fileSizeKb,
  }) async {
    final traceName = 'pdf_$documentType';
    if (pageCount != null) {
      await setTraceMetric(
        traceName: traceName,
        metricName: 'page_count',
        value: pageCount,
      );
    }
    if (fileSizeKb != null) {
      await setTraceMetric(
        traceName: traceName,
        metricName: 'file_size_kb',
        value: fileSizeKb,
      );
    }
    await stopTrace(traceName);
  }

  // ============================================================================
  // Backup/Restore Performance Traces
  // ============================================================================

  /// Start backup trace
  Future<Trace?> startBackupTrace() async {
    return await startTrace('backup_database');
  }

  /// Stop backup trace
  Future<void> stopBackupTrace({int? databaseSizeKb}) async {
    if (databaseSizeKb != null) {
      await setTraceMetric(
        traceName: 'backup_database',
        metricName: 'database_size_kb',
        value: databaseSizeKb,
      );
    }
    await stopTrace('backup_database');
  }

  /// Start restore trace
  Future<Trace?> startRestoreTrace() async {
    return await startTrace('restore_database');
  }

  /// Stop restore trace
  Future<void> stopRestoreTrace({int? databaseSizeKb}) async {
    if (databaseSizeKb != null) {
      await setTraceMetric(
        traceName: 'restore_database',
        metricName: 'database_size_kb',
        value: databaseSizeKb,
      );
    }
    await stopTrace('restore_database');
  }

  // ============================================================================
  // Data Export Performance Traces
  // ============================================================================

  /// Start data export trace
  Future<Trace?> startExportTrace(String format) async {
    final traceName = 'export_$format';
    final trace = await startTrace(traceName);
    if (trace != null) {
      await setTraceAttribute(
        traceName: traceName,
        attributeName: 'format',
        attributeValue: format,
      );
    }
    return trace;
  }

  /// Stop data export trace
  Future<void> stopExportTrace(String format, {int? recordCount}) async {
    final traceName = 'export_$format';
    if (recordCount != null) {
      await setTraceMetric(
        traceName: traceName,
        metricName: 'record_count',
        value: recordCount,
      );
    }
    await stopTrace(traceName);
  }

  // ============================================================================
  // App Startup Performance
  // ============================================================================

  /// Start app initialization trace
  Future<Trace?> startAppInitTrace() async {
    return await startTrace('app_initialization');
  }

  /// Stop app initialization trace
  Future<void> stopAppInitTrace() async {
    await stopTrace('app_initialization');
  }

  // ============================================================================
  // HTTP Metrics (for future API integration)
  // ============================================================================

  /// Create HTTP metric
  HttpMetric newHttpMetric({
    required String url,
    required HttpMethod httpMethod,
  }) {
    return _performance.newHttpMetric(url, httpMethod);
  }

  // ============================================================================
  // Helper Method: Measure Async Operation
  // ============================================================================

  /// Measure async operation performance
  Future<T> measureOperation<T>({
    required String operationName,
    required Future<T> Function() operation,
    Map<String, String>? attributes,
    Map<String, int>? metrics,
  }) async {
    // Start trace
    final trace = await startTrace(operationName);

    // Set attributes if provided
    if (trace != null && attributes != null) {
      for (final entry in attributes.entries) {
        await setTraceAttribute(
          traceName: operationName,
          attributeName: entry.key,
          attributeValue: entry.value,
        );
      }
    }

    try {
      // Execute operation
      final result = await operation();

      // Set metrics if provided
      if (trace != null && metrics != null) {
        for (final entry in metrics.entries) {
          await setTraceMetric(
            traceName: operationName,
            metricName: entry.key,
            value: entry.value,
          );
        }
      }

      return result;
    } finally {
      // Always stop trace
      await stopTrace(operationName);
    }
  }

  // ============================================================================
  // Collection Control
  // ============================================================================

  /// Enable performance collection
  Future<void> enablePerformanceCollection() async {
    try {
      await _performance.setPerformanceCollectionEnabled(true);
      _logger.i('Performance collection enabled');
    } catch (e) {
      _logger.e('Failed to enable performance collection: $e');
    }
  }

  /// Disable performance collection
  Future<void> disablePerformanceCollection() async {
    try {
      await _performance.setPerformanceCollectionEnabled(false);
      _logger.i('Performance collection disabled');
    } catch (e) {
      _logger.e('Failed to disable performance collection: $e');
    }
  }

  /// Check if performance collection is enabled
  Future<bool> isPerformanceCollectionEnabled() async {
    try {
      return await _performance.isPerformanceCollectionEnabled();
    } catch (e) {
      _logger.e('Failed to check performance collection status: $e');
      return false;
    }
  }

  // ============================================================================
  // Cleanup
  // ============================================================================

  /// Stop all active traces
  Future<void> stopAllTraces() async {
    final traceNames = _activeTraces.keys.toList();
    for (final traceName in traceNames) {
      await stopTrace(traceName);
    }
    _logger.i('All traces stopped');
  }
}
