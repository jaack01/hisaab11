import 'package:in_app_review/in_app_review.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Review service for managing in-app review prompts
///
/// This service handles when and how to show app review prompts
/// to users, with intelligent timing and frequency controls.
class ReviewService {
  final InAppReview _inAppReview;
  final Logger _logger;

  // SharedPreferences keys
  static const String _keyAppLaunchCount = 'app_launch_count';
  static const String _keyLastReviewPromptDate = 'last_review_prompt_date';
  static const String _keyReviewCompleted = 'review_completed';
  static const String _keyReviewDeclined = 'review_declined';
  static const String _keySignificantActionsCount = 'significant_actions_count';

  // Configuration
  static const int _minLaunchesBeforePrompt = 5;
  static const int _minDaysBetweenPrompts = 30;
  static const int _minSignificantActions = 10;

  ReviewService({
    InAppReview? inAppReview,
    Logger? logger,
  })  : _inAppReview = inAppReview ?? InAppReview.instance,
        _logger = logger ?? Logger();

  // ============================================================================
  // Initialization
  // ============================================================================

  /// Initialize review tracking
  Future<void> initialize() async {
    await incrementLaunchCount();
    _logger.d('Review service initialized');
  }

  // ============================================================================
  // Launch Tracking
  // ============================================================================

  /// Increment app launch count
  Future<void> incrementLaunchCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_keyAppLaunchCount) ?? 0;
      await prefs.setInt(_keyAppLaunchCount, currentCount + 1);
      _logger.d('App launch count: ${currentCount + 1}');
    } catch (e) {
      _logger.e('Failed to increment launch count: $e');
    }
  }

  /// Get app launch count
  Future<int> getLaunchCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyAppLaunchCount) ?? 0;
    } catch (e) {
      _logger.e('Failed to get launch count: $e');
      return 0;
    }
  }

  // ============================================================================
  // Significant Actions Tracking
  // ============================================================================

  /// Increment significant actions count
  ///
  /// Significant actions include:
  /// - Adding customers
  /// - Recording transactions
  /// - Creating invoices
  /// - Generating reports
  Future<void> incrementSignificantAction() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_keySignificantActionsCount) ?? 0;
      await prefs.setInt(_keySignificantActionsCount, currentCount + 1);
      _logger.d('Significant actions count: ${currentCount + 1}');
    } catch (e) {
      _logger.e('Failed to increment significant actions: $e');
    }
  }

  /// Get significant actions count
  Future<int> getSignificantActionsCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keySignificantActionsCount) ?? 0;
    } catch (e) {
      _logger.e('Failed to get significant actions count: $e');
      return 0;
    }
  }

  // ============================================================================
  // Review Status
  // ============================================================================

  /// Check if user has completed review
  Future<bool> hasCompletedReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyReviewCompleted) ?? false;
    } catch (e) {
      _logger.e('Failed to check review completion: $e');
      return false;
    }
  }

  /// Mark review as completed
  Future<void> markReviewCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyReviewCompleted, true);
      await prefs.setInt(
        _keyLastReviewPromptDate,
        DateTime.now().millisecondsSinceEpoch,
      );
      _logger.i('Review marked as completed');
    } catch (e) {
      _logger.e('Failed to mark review completed: $e');
    }
  }

  /// Check if user has declined review
  Future<bool> hasDeclinedReview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyReviewDeclined) ?? false;
    } catch (e) {
      _logger.e('Failed to check review declined: $e');
      return false;
    }
  }

  /// Mark review as declined
  Future<void> markReviewDeclined() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyReviewDeclined, true);
      await prefs.setInt(
        _keyLastReviewPromptDate,
        DateTime.now().millisecondsSinceEpoch,
      );
      _logger.i('Review marked as declined');
    } catch (e) {
      _logger.e('Failed to mark review declined: $e');
    }
  }

  // ============================================================================
  // Review Prompt Timing
  // ============================================================================

  /// Get last review prompt date
  Future<DateTime?> getLastReviewPromptDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyLastReviewPromptDate);
      if (timestamp != null) {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get last review prompt date: $e');
      return null;
    }
  }

  /// Check if enough time has passed since last prompt
  Future<bool> hasEnoughTimePassed() async {
    final lastPromptDate = await getLastReviewPromptDate();
    if (lastPromptDate == null) return true;

    final daysSinceLastPrompt =
        DateTime.now().difference(lastPromptDate).inDays;
    return daysSinceLastPrompt >= _minDaysBetweenPrompts;
  }

  // ============================================================================
  // Review Prompt Logic
  // ============================================================================

  /// Check if should show review prompt
  Future<bool> shouldShowReviewPrompt() async {
    try {
      // Don't prompt if already completed
      if (await hasCompletedReview()) {
        _logger.d('Review already completed');
        return false;
      }

      // Don't prompt if declined and not enough time passed
      if (await hasDeclinedReview()) {
        if (!(await hasEnoughTimePassed())) {
          _logger.d('Not enough time since declined review');
          return false;
        }
      }

      // Check if enough time passed since last prompt
      if (!(await hasEnoughTimePassed())) {
        _logger.d('Not enough time since last prompt');
        return false;
      }

      // Check launch count
      final launchCount = await getLaunchCount();
      if (launchCount < _minLaunchesBeforePrompt) {
        _logger.d('Not enough launches: $launchCount/$_minLaunchesBeforePrompt');
        return false;
      }

      // Check significant actions
      final actionsCount = await getSignificantActionsCount();
      if (actionsCount < _minSignificantActions) {
        _logger.d(
          'Not enough significant actions: $actionsCount/$_minSignificantActions',
        );
        return false;
      }

      _logger.i('Should show review prompt');
      return true;
    } catch (e) {
      _logger.e('Failed to check if should show review: $e');
      return false;
    }
  }

  // ============================================================================
  // Review Actions
  // ============================================================================

  /// Check if in-app review is available
  Future<bool> isReviewAvailable() async {
    try {
      return await _inAppReview.isAvailable();
    } catch (e) {
      _logger.e('Failed to check review availability: $e');
      return false;
    }
  }

  /// Request in-app review
  ///
  /// Shows the native in-app review dialog
  Future<bool> requestReview() async {
    try {
      if (!(await isReviewAvailable())) {
        _logger.w('In-app review not available');
        return false;
      }

      await _inAppReview.requestReview();
      await markReviewCompleted();
      _logger.i('Review requested successfully');
      return true;
    } catch (e) {
      _logger.e('Failed to request review: $e');
      return false;
    }
  }

  /// Open Play Store for review
  ///
  /// Opens the app's Play Store page for manual review
  Future<bool> openPlayStore() async {
    try {
      await _inAppReview.openStoreListing(
        appStoreId: '', // Not needed for Android
      );
      await markReviewCompleted();
      _logger.i('Play Store opened for review');
      return true;
    } catch (e) {
      _logger.e('Failed to open Play Store: $e');
      return false;
    }
  }

  /// Show review prompt if conditions are met
  Future<bool> showReviewPromptIfEligible() async {
    if (await shouldShowReviewPrompt()) {
      return await requestReview();
    }
    return false;
  }

  // ============================================================================
  // Manual Review Prompt
  // ============================================================================

  /// Manually trigger review prompt (for testing or specific triggers)
  Future<bool> manualReviewPrompt() async {
    try {
      if (await isReviewAvailable()) {
        await _inAppReview.requestReview();
        _logger.i('Manual review prompt shown');
        return true;
      } else {
        // Fallback to Play Store
        return await openPlayStore();
      }
    } catch (e) {
      _logger.e('Failed to show manual review prompt: $e');
      return false;
    }
  }

  // ============================================================================
  // Reset (for testing)
  // ============================================================================

  /// Reset all review tracking data
  Future<void> resetReviewTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyAppLaunchCount);
      await prefs.remove(_keyLastReviewPromptDate);
      await prefs.remove(_keyReviewCompleted);
      await prefs.remove(_keyReviewDeclined);
      await prefs.remove(_keySignificantActionsCount);
      _logger.i('Review tracking reset');
    } catch (e) {
      _logger.e('Failed to reset review tracking: $e');
    }
  }

  // ============================================================================
  // Debug Information
  // ============================================================================

  /// Get review tracking debug info
  Future<Map<String, dynamic>> getDebugInfo() async {
    return {
      'launchCount': await getLaunchCount(),
      'significantActionsCount': await getSignificantActionsCount(),
      'hasCompletedReview': await hasCompletedReview(),
      'hasDeclinedReview': await hasDeclinedReview(),
      'lastPromptDate': (await getLastReviewPromptDate())?.toIso8601String(),
      'shouldShowPrompt': await shouldShowReviewPrompt(),
      'isReviewAvailable': await isReviewAvailable(),
    };
  }
}
