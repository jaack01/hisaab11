import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/utils/date_utils.dart' as app_date;
import '../../../domain/entities/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/error_state.dart';
import '../../widgets/common/loading_skeleton.dart';

class ReminderListScreen extends ConsumerStatefulWidget {
  const ReminderListScreen({super.key});

  @override
  ConsumerState<ReminderListScreen> createState() => _ReminderListScreenState();
}

class _ReminderListScreenState extends ConsumerState<ReminderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load reminders on screen load
    Future.microtask(() {
      ref.read(reminderProvider.notifier).loadAllReminders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reminderState = ref.watch(reminderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterOptions(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Overdue'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: reminderState.isLoading
          ? _buildLoadingState()
          : reminderState.error != null
              ? ErrorState(
                  message: reminderState.error!,
                  onRetry: () {
                    ref.read(reminderProvider.notifier).loadAllReminders();
                  },
                )
              : _buildReminderList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, Routes.addReminder);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Reminder'),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LoadingSkeleton(
          width: double.infinity,
          height: 80,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildReminderList() {
    final upcomingReminders = ref.read(reminderProvider.notifier).upcomingReminders;
    final overdueReminders = ref.read(reminderProvider.notifier).overdueReminders;
    final sentReminders = ref.read(reminderProvider.notifier).sentReminders;

    return TabBarView(
      controller: _tabController,
      children: [
        _buildReminderTab(upcomingReminders, 'Upcoming'),
        _buildReminderTab(overdueReminders, 'Overdue'),
        _buildReminderTab(sentReminders, 'Sent'),
      ],
    );
  }

  Widget _buildReminderTab(List<Reminder> reminders, String tabName) {
    if (reminders.isEmpty) {
      return EmptyState(
        icon: Icons.notifications_none,
        title: 'No $tabName Reminders',
        subtitle: 'Set reminders to follow up with customers',
        actionLabel: 'Add Reminder',
        onAction: () {
          Navigator.pushNamed(context, Routes.addReminder);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(reminderProvider.notifier).loadAllReminders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminders[index];
          return _ReminderCard(
            reminder: reminder,
            onTap: () {
              Navigator.pushNamed(
                context,
                Routes.editReminder,
                arguments: {'reminderId': reminder.id},
              );
            },
            onMarkSent: reminder.isSent
                ? null
                : () async {
                    await ref
                        .read(reminderProvider.notifier)
                        .markReminderSent(reminder.id!, reminder.businessId);
                  },
          );
        },
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Payment Reminders'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Filter by type
              },
            ),
            ListTile(
              leading: const Icon(Icons.follow_the_signs),
              title: const Text('Follow-up Reminders'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Filter by type
              },
            ),
            ListTile(
              leading: const Icon(Icons.note),
              title: const Text('Custom Reminders'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Filter by type
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback onTap;
  final VoidCallback? onMarkSent;

  const _ReminderCard({
    required this.reminder,
    required this.onTap,
    this.onMarkSent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final isOverdue = !reminder.isSent && reminder.reminderDate < now;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type indicator
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getTypeColor(reminder.reminderType).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTypeIcon(reminder.reminderType),
                      color: _getTypeColor(reminder.reminderType),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Reminder details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatReminderType(reminder.reminderType),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (reminder.customerName != null)
                          Row(
                            children: [
                              const Icon(Icons.person, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                reminder.customerName!,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Status badge
                  if (isOverdue)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Overdue',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else if (reminder.isSent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Sent',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Message
              if (reminder.message != null)
                Text(
                  reminder.message!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 8),

              // Date and actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: isOverdue ? Colors.red : theme.textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        app_date.AppDateUtils.formatDate(reminder.reminderDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isOverdue ? Colors.red : null,
                          fontWeight: isOverdue ? FontWeight.w600 : null,
                        ),
                      ),
                    ],
                  ),

                  if (onMarkSent != null)
                    TextButton.icon(
                      onPressed: onMarkSent,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Mark Sent'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'PAYMENT':
        return Colors.orange;
      case 'FOLLOW_UP':
        return Colors.blue;
      case 'CUSTOM':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'PAYMENT':
        return Icons.payments;
      case 'FOLLOW_UP':
        return Icons.follow_the_signs;
      case 'CUSTOM':
        return Icons.note;
      default:
        return Icons.notifications;
    }
  }

  String _formatReminderType(String type) {
    switch (type) {
      case 'PAYMENT':
        return 'Payment Reminder';
      case 'FOLLOW_UP':
        return 'Follow-up Reminder';
      case 'CUSTOM':
        return 'Custom Reminder';
      default:
        return type;
    }
  }
}
