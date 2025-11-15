import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/local/database/dao/expense_dao.dart';
import '../models/expense_model.dart';

/// Implementation of ExpenseRepository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseDao dao;

  ExpenseRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, Expense>> addExpense(Expense expense) async {
    try {
      final model = ExpenseModel.fromEntity(expense);
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
  Future<Either<Failure, List<Expense>>> getExpenses(int businessId) async {
    try {
      final models = await dao.getAllExpenses(businessId: businessId);
      final expenses = models.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> getExpenseById(int id) async {
    try {
      final model = await dao.getById(id);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Expense not found'));
      }
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) {
        return Left(ValidationFailure(message: 'Expense ID is required'));
      }

      final model = ExpenseModel.fromEntity(expense);
      await dao.update(model, expense.id!);
      return Right(expense);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(int id) async {
    try {
      await dao.deleteExpense(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByCategory({
    required int businessId,
    required String category,
  }) async {
    try {
      final models = await dao.getExpensesByCategory(
        businessId: businessId,
        category: category,
      );
      final expenses = models.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final models = await dao.getExpensesByDateRange(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      final expenses = models.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpenses({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final total = await dao.getTotalExpenses(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpensesByVendor({
    required int businessId,
    required String vendor,
  }) async {
    try {
      final models = await dao.getExpensesByVendor(
        businessId: businessId,
        vendor: vendor,
      );
      final expenses = models.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getExpenseCategories(
    int businessId,
  ) async {
    try {
      final categories = await dao.getAllCategories(businessId: businessId);
      return Right(categories);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getCurrentMonthExpenses(
    int businessId,
  ) async {
    try {
      final now = DateTime.now();
      final models = await dao.getCurrentMonthExpenses(
        businessId: businessId,
        year: now.year,
        month: now.month,
      );
      final expenses = models.map((model) => model.toEntity()).toList();
      return Right(expenses);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getExpenseCount(int businessId) async {
    try {
      final count = await dao.getExpenseCount(businessId: businessId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
