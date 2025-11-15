import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/reminder.dart';

/// Repository interface for reminder management
abstract class ReminderRepository {
  /// Create a new reminder
  Future<Either<Failure, Reminder>> createReminder(Reminder reminder);

  /// Get all reminders for a business
  Future<Either<Failure, List<Reminder>>> getReminders(int businessId);

  /// Get reminder by ID
  Future<Either<Failure, Reminder>> getReminderById(int id);

  /// Get reminders by customer
  Future<Either<Failure, List<Reminder>>> getRemindersByCustomer({
    required int businessId,
    required int customerId,
  });

  /// Get pending reminders
  Future<Either<Failure, List<Reminder>>> getPendingReminders(int businessId);

  /// Get reminders for today
  Future<Either<Failure, List<Reminder>>> getTodayReminders(int businessId);

  /// Get overdue reminders
  Future<Either<Failure, List<Reminder>>> getOverdueReminders(int businessId);

  /// Update reminder
  Future<Either<Failure, Reminder>> updateReminder(Reminder reminder);

  /// Mark reminder as sent
  Future<Either<Failure, Reminder>> markAsSent(int reminderId);

  /// Cancel reminder
  Future<Either<Failure, void>> cancelReminder(int reminderId);

  /// Delete reminder
  Future<Either<Failure, void>> deleteReminder(int reminderId);

  /// Get reminder count
  Future<Either<Failure, int>> getReminderCount(int businessId);
}
