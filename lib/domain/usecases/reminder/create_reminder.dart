import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reminder.dart';
import '../../repositories/reminder_repository.dart';

/// Use case for creating a new reminder
class CreateReminder {
  final ReminderRepository repository;

  CreateReminder(this.repository);

  Future<Either<Failure, Reminder>> call(Reminder reminder) async {
    // Validate reminder
    if (reminder.title.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Reminder title is required'));
    }

    if (reminder.customerId <= 0) {
      return Left(ValidationFailure(message: 'Invalid customer ID'));
    }

    if (reminder.amount < 0) {
      return Left(ValidationFailure(message: 'Amount cannot be negative'));
    }

    // Validate channel
    const validChannels = ['SMS', 'WHATSAPP', 'NOTIFICATION'];
    if (!validChannels.contains(reminder.channel)) {
      return Left(ValidationFailure(message: 'Invalid reminder channel'));
    }

    return repository.createReminder(reminder);
  }
}
