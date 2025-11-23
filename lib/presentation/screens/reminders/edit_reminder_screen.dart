import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/reminder.dart';
import '../../providers/reminder_provider.dart';
import '../../widgets/common/loading_skeleton.dart';
import '../../widgets/common/error_state.dart';
import 'add_reminder_screen.dart';

class EditReminderScreen extends ConsumerStatefulWidget {
  final int reminderId;

  const EditReminderScreen({
    super.key,
    required this.reminderId,
  });

  @override
  ConsumerState<EditReminderScreen> createState() => _EditReminderScreenState();
}

class _EditReminderScreenState extends ConsumerState<EditReminderScreen> {
  Reminder? _reminder;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reminderState = ref.read(reminderProvider);
      _reminder = reminderState.reminders.firstWhere(
        (reminder) => reminder.id == widget.reminderId,
        orElse: () => throw Exception('Reminder not found'),
      );

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Reminder'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: LoadingSkeleton(
            width: double.infinity,
            height: 200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Reminder'),
        ),
        body: ErrorState(
          message: _error!,
          onRetry: _loadReminder,
        ),
      );
    }

    if (_reminder == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Reminder'),
        ),
        body: const Center(
          child: Text('Reminder not found'),
        ),
      );
    }

    // Delegate to AddReminderScreen with reminder data for editing
    return AddReminderScreen(reminder: _reminder);
  }
}
