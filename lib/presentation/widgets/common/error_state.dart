import 'package:flutter/material.dart';

/// Widget to display error state with icon, message, and retry button
class ErrorState extends StatelessWidget {
  final String message;
  final String? subtitle;
  final VoidCallback? onRetry;
  final IconData icon;
  final double iconSize;

  const ErrorState({
    super.key,
    required this.message,
    this.subtitle,
    this.onRetry,
    this.icon = Icons.error_outline,
    this.iconSize = 80.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined error states for common scenarios
class ErrorStates {
  static Widget generic(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      message: 'Something went wrong',
      subtitle: 'Please try again',
      onRetry: onRetry,
    );
  }

  static Widget network(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      icon: Icons.wifi_off,
      message: 'No internet connection',
      subtitle: 'Please check your connection and try again',
      onRetry: onRetry,
    );
  }

  static Widget notFound(
    BuildContext context, {
    String? itemName,
  }) {
    return ErrorState(
      icon: Icons.search_off,
      message: '${itemName ?? "Item"} not found',
      subtitle: 'The requested ${itemName?.toLowerCase() ?? "item"} could not be found',
    );
  }

  static Widget timeout(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      icon: Icons.access_time,
      message: 'Request timeout',
      subtitle: 'The request took too long to complete',
      onRetry: onRetry,
    );
  }

  static Widget serverError(
    BuildContext context, {
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      icon: Icons.cloud_off,
      message: 'Server error',
      subtitle: 'Our servers are having issues. Please try again later',
      onRetry: onRetry,
    );
  }

  static Widget custom(
    BuildContext context, {
    required String message,
    String? subtitle,
    IconData? icon,
    VoidCallback? onRetry,
  }) {
    return ErrorState(
      message: message,
      subtitle: subtitle,
      icon: icon ?? Icons.error_outline,
      onRetry: onRetry,
    );
  }
}
