import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/usecases/reminder/add_reminder_usecase.dart';
import '../../domain/usecases/reminder/get_reminder_by_id_usecase.dart';
import '../../domain/usecases/reminder/get_reminders_by_customer_usecase.dart';
import '../../domain/usecases/reminder/get_pending_reminders_usecase.dart';
import '../../domain/usecases/reminder/get_all_reminders_usecase.dart';
import '../../domain/usecases/reminder/update_reminder_usecase.dart';
import '../../domain/usecases/reminder/delete_reminder_usecase.dart';
import '../../domain/usecases/reminder/mark_reminder_sent_usecase.dart';

/// Reminder state
class ReminderState {
  final List<Reminder> reminders;
  final Reminder? selectedReminder;
  final bool isLoading;
  final String? error;

  const ReminderState({
    this.reminders = const [],
    this.selectedReminder,
    this.isLoading = false,
    this.error,
  });

  ReminderState copyWith({
    List<Reminder>? reminders,
    Reminder? selectedReminder,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return ReminderState(
      reminders: reminders ?? this.reminders,
      selectedReminder: clearSelected ? null : (selectedReminder ?? this.selectedReminder),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Reminder provider
class ReminderNotifier extends StateNotifier<ReminderState> {
  final AddReminderUseCase _addReminderUseCase;
  final GetReminderByIdUseCase _getReminderByIdUseCase;
  final GetRemindersByCustomerUseCase _getRemindersByCustomerUseCase;
  final GetPendingRemindersUseCase _getPendingRemindersUseCase;
  final GetAllRemindersUseCase _getAllRemindersUseCase;
  final UpdateReminderUseCase _updateReminderUseCase;
  final DeleteReminderUseCase _deleteReminderUseCase;
  final MarkReminderSentUseCase _markReminderSentUseCase;

  ReminderNotifier({
    required AddReminderUseCase addReminderUseCase,
    required GetReminderByIdUseCase getReminderByIdUseCase,
    required GetRemindersByCustomerUseCase getRemindersByCustomerUseCase,
    required GetPendingRemindersUseCase getPendingRemindersUseCase,
    required GetAllRemindersUseCase getAllRemindersUseCase,
    required UpdateReminderUseCase updateReminderUseCase,
    required DeleteReminderUseCase deleteReminderUseCase,
    required MarkReminderSentUseCase markReminderSentUseCase,
  })  : _addReminderUseCase = addReminderUseCase,
        _getReminderByIdUseCase = getReminderByIdUseCase,
        _getRemindersByCustomerUseCase = getRemindersByCustomerUseCase,
        _getPendingRemindersUseCase = getPendingRemindersUseCase,
        _getAllRemindersUseCase = getAllRemindersUseCase,
        _updateReminderUseCase = updateReminderUseCase,
        _deleteReminderUseCase = deleteReminderUseCase,
        _markReminderSentUseCase = markReminderSentUseCase,
        super(const ReminderState());

  /// Load all reminders
  Future<void> loadAllReminders({int? businessId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllRemindersUseCase(businessId ?? 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (reminders) => state = state.copyWith(
        isLoading: false,
        reminders: reminders,
      ),
    );
  }

  /// Load reminder by ID
  Future<void> loadReminderById(int reminderId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getReminderByIdUseCase(reminderId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (reminder) => state = state.copyWith(
        isLoading: false,
        selectedReminder: reminder,
      ),
    );
  }

  /// Load reminders for a specific customer
  Future<void> loadCustomerReminders(int customerId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getRemindersByCustomerUseCase(customerId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (reminders) => state = state.copyWith(
        isLoading: false,
        reminders: reminders,
      ),
    );
  }

  /// Load pending reminders
  Future<void> loadPendingReminders({int? businessId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getPendingRemindersUseCase(businessId ?? 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (reminders) => state = state.copyWith(
        isLoading: false,
        reminders: reminders,
      ),
    );
  }

  /// Add new reminder
  Future<bool> addReminder(Reminder reminder) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addReminderUseCase(reminder);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (reminderId) {
        // Reload reminders
        loadAllReminders(businessId: reminder.businessId);
        return true;
      },
    );
  }

  /// Update reminder
  Future<bool> updateReminder(Reminder reminder) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateReminderUseCase(reminder);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload reminders
        loadAllReminders(businessId: reminder.businessId);
        return true;
      },
    );
  }

  /// Delete reminder
  Future<bool> deleteReminder(int reminderId, int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deleteReminderUseCase(reminderId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload reminders
        loadAllReminders(businessId: businessId);
        return true;
      },
    );
  }

  /// Mark reminder as sent
  Future<bool> markReminderSent(int reminderId, int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _markReminderSentUseCase(reminderId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload reminders
        loadAllReminders(businessId: businessId);
        return true;
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear selected reminder
  void clearSelectedReminder() {
    state = state.copyWith(clearSelected: true);
  }

  /// Get pending reminders (from current state)
  List<Reminder> get pendingReminders {
    return state.reminders
        .where((reminder) => !reminder.isSent && !reminder.isDeleted)
        .toList();
  }

  /// Get sent reminders (from current state)
  List<Reminder> get sentReminders {
    return state.reminders
        .where((reminder) => reminder.isSent && !reminder.isDeleted)
        .toList();
  }

  /// Get reminders by type
  List<Reminder> getRemindersByType(String reminderType) {
    return state.reminders
        .where((reminder) => reminder.reminderType == reminderType)
        .toList();
  }

  /// Get payment reminders
  List<Reminder> get paymentReminders => getRemindersByType('PAYMENT');

  /// Get follow-up reminders
  List<Reminder> get followUpReminders => getRemindersByType('FOLLOW_UP');

  /// Get custom reminders
  List<Reminder> get customReminders => getRemindersByType('CUSTOM');

  /// Get upcoming reminders (reminder date in future)
  List<Reminder> get upcomingReminders {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return pendingReminders
        .where((reminder) => reminder.reminderDate > now)
        .toList();
  }

  /// Get overdue reminders (reminder date in past)
  List<Reminder> get overdueReminders {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return pendingReminders
        .where((reminder) => reminder.reminderDate <= now)
        .toList();
  }

  /// Get reminders sorted by date (earliest first)
  List<Reminder> get remindersSortedByDate {
    final reminders = List<Reminder>.from(state.reminders);
    reminders.sort((a, b) => a.reminderDate.compareTo(b.reminderDate));
    return reminders;
  }
}

// Provider instance (to be configured with dependency injection)
final reminderProvider = StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  throw UnimplementedError('reminderProvider must be overridden with proper dependencies');
});
