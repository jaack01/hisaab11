import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reminder.dart';
import '../../repositories/reminder_repository.dart';

/// Use case for marking a reminder as sent
class MarkReminderSent {
  final ReminderRepository repository;

  MarkReminderSent(this.repository);

  Future<Either<Failure, Reminder>> call(int reminderId) async {
    if (reminderId <= 0) {
      return Left(ValidationFailure(message: 'Invalid reminder ID'));
    }

    return repository.markAsSent(reminderId);
  }
}
