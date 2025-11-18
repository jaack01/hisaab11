import 'package:flutter/material.dart';

/// Widget to display empty state with icon, title, subtitle, and optional action
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double iconSize;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconSize = 80.0,
    this.iconColor,
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
              color: iconColor ?? colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states for common scenarios
class EmptyStates {
  static Widget customers(
    BuildContext context, {
    VoidCallback? onAddCustomer,
  }) {
    return EmptyState(
      icon: Icons.people_outline,
      title: 'No customers yet',
      subtitle: 'Add your first customer to start tracking transactions',
      actionLabel: onAddCustomer != null ? 'Add Customer' : null,
      onAction: onAddCustomer,
    );
  }

  static Widget transactions(
    BuildContext context, {
    VoidCallback? onAddTransaction,
  }) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      subtitle: 'Start adding transactions to track money flow',
      actionLabel: onAddTransaction != null ? 'Add Transaction' : null,
      onAction: onAddTransaction,
    );
  }

  static Widget invoices(
    BuildContext context, {
    VoidCallback? onCreateInvoice,
  }) {
    return EmptyState(
      icon: Icons.description_outlined,
      title: 'No invoices yet',
      subtitle: 'Create professional invoices for your customers',
      actionLabel: onCreateInvoice != null ? 'Create Invoice' : null,
      onAction: onCreateInvoice,
    );
  }

  static Widget items(
    BuildContext context, {
    VoidCallback? onAddItem,
  }) {
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: 'No items yet',
      subtitle: 'Add products or services to create invoices',
      actionLabel: onAddItem != null ? 'Add Item' : null,
      onAction: onAddItem,
    );
  }

  static Widget expenses(
    BuildContext context, {
    VoidCallback? onAddExpense,
  }) {
    return EmptyState(
      icon: Icons.payment_outlined,
      title: 'No expenses yet',
      subtitle: 'Track your business expenses',
      actionLabel: onAddExpense != null ? 'Add Expense' : null,
      onAction: onAddExpense,
    );
  }

  static Widget reminders(
    BuildContext context, {
    VoidCallback? onAddReminder,
  }) {
    return EmptyState(
      icon: Icons.notifications_outlined,
      title: 'No reminders yet',
      subtitle: 'Set reminders for pending payments',
      actionLabel: onAddReminder != null ? 'Add Reminder' : null,
      onAction: onAddReminder,
    );
  }

  static Widget search(BuildContext context) {
    return const EmptyState(
      icon: Icons.search_off,
      title: 'No results found',
      subtitle: 'Try adjusting your search criteria',
    );
  }
}
