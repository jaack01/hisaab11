import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reminder.dart';
import '../../repositories/reminder_repository.dart';

/// Use case for getting all reminders for a business
class GetReminders {
  final ReminderRepository repository;

  GetReminders(this.repository);

  Future<Either<Failure, List<Reminder>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getReminders(businessId);
  }
}
