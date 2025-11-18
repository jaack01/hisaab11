import 'package:flutter/services.dart';

/// Utility class for haptic feedback
class AppHaptics {
  AppHaptics._();

  /// Light impact haptic feedback
  /// Use for subtle interactions like button presses
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact haptic feedback
  /// Use for standard interactions like list item selection
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact haptic feedback
  /// Use for important actions like delete or save
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback
  /// Use for picker or scroll wheel interactions
  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate haptic feedback
  /// Use for notifications or alerts
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success haptic feedback
  /// Custom pattern for successful operations
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Error haptic feedback
  /// Custom pattern for errors
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Warning haptic feedback
  /// Custom pattern for warnings
  static Future<void> warning() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }
}

/// Haptic-enabled widget wrapper
/// Wraps any widget with haptic feedback on tap
class HapticWrapper extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final HapticFeedbackType feedbackType;

  const HapticWrapper({
    super.key,
    required this.child,
    this.onTap,
    this.feedbackType = HapticFeedbackType.light,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null
          ? () async {
              await _performHaptic();
              onTap!();
            }
          : null,
      child: child,
    );
  }

  Future<void> _performHaptic() async {
    switch (feedbackType) {
      case HapticFeedbackType.light:
        await AppHaptics.light();
        break;
      case HapticFeedbackType.medium:
        await AppHaptics.medium();
        break;
      case HapticFeedbackType.heavy:
        await AppHaptics.heavy();
        break;
      case HapticFeedbackType.selection:
        await AppHaptics.selection();
        break;
      case HapticFeedbackType.success:
        await AppHaptics.success();
        break;
      case HapticFeedbackType.error:
        await AppHaptics.error();
        break;
      case HapticFeedbackType.warning:
        await AppHaptics.warning();
        break;
    }
  }
}

/// Types of haptic feedback
enum HapticFeedbackType {
  light,
  medium,
  heavy,
  selection,
  success,
  error,
  warning,
}
