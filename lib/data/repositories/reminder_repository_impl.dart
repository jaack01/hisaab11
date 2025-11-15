import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/local/database/dao/reminder_dao.dart';
import '../models/reminder_model.dart';

/// Implementation of ReminderRepository
class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderDao dao;

  ReminderRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, Reminder>> createReminder(Reminder reminder) async {
    try {
      final model = ReminderModel.fromEntity(reminder);
      final id = await dao.insert(model);
      final insertedModel = model.copyWith(id: id);
      return Right(insertedModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getReminders(int businessId) async {
    try {
      final models = await dao.getAllReminders(businessId: businessId);
      final reminders = models.map((model) => model.toEntity()).toList();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> getReminderById(int id) async {
    try {
      final model = await dao.getById(id);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Reminder not found'));
      }
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getRemindersByCustomer({
    required int businessId,
    required int customerId,
  }) async {
    try {
      final models = await dao.getRemindersByCustomer(
        businessId: businessId,
        customerId: customerId,
      );
      final reminders = models.map((model) => model.toEntity()).toList();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getPendingReminders(
    int businessId,
  ) async {
    try {
      final models = await dao.getPendingReminders(businessId: businessId);
      final reminders = models.map((model) => model.toEntity()).toList();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getTodayReminders(
    int businessId,
  ) async {
    try {
      final currentDate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final models = await dao.getTodayReminders(
        businessId: businessId,
        currentDate: currentDate,
      );
      final reminders = models.map((model) => model.toEntity()).toList();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Reminder>>> getOverdueReminders(
    int businessId,
  ) async {
    try {
      final currentDate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final models = await dao.getOverdueReminders(
        businessId: businessId,
        currentDate: currentDate,
      );
      final reminders = models.map((model) => model.toEntity()).toList();
      return Right(reminders);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> updateReminder(Reminder reminder) async {
    try {
      if (reminder.id == null) {
        return Left(ValidationFailure(message: 'Reminder ID is required'));
      }

      final model = ReminderModel.fromEntity(reminder);
      await dao.update(model, reminder.id!);
      return Right(reminder);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Reminder>> markAsSent(int reminderId) async {
    try {
      await dao.markAsSent(reminderId);
      final model = await dao.getById(reminderId);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Reminder not found'));
      }
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelReminder(int reminderId) async {
    try {
      await dao.cancelReminder(reminderId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReminder(int reminderId) async {
    try {
      await dao.delete(reminderId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getReminderCount(int businessId) async {
    try {
      final count = await dao.getReminderCount(businessId: businessId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
