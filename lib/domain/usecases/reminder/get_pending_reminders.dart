import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reminder.dart';
import '../../repositories/reminder_repository.dart';

/// Use case for getting pending reminders
class GetPendingReminders {
  final ReminderRepository repository;

  GetPendingReminders(this.repository);

  Future<Either<Failure, List<Reminder>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getPendingReminders(businessId);
  }
}
