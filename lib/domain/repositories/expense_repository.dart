import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/expense.dart';

/// Repository interface for expense management
abstract class ExpenseRepository {
  /// Add a new expense
  Future<Either<Failure, Expense>> addExpense(Expense expense);

  /// Get all expenses for a business
  Future<Either<Failure, List<Expense>>> getExpenses(int businessId);

  /// Get expense by ID
  Future<Either<Failure, Expense>> getExpenseById(int id);

  /// Update an expense
  Future<Either<Failure, Expense>> updateExpense(Expense expense);

  /// Delete an expense (soft delete)
  Future<Either<Failure, void>> deleteExpense(int id);

  /// Get expenses by category
  Future<Either<Failure, List<Expense>>> getExpensesByCategory({
    required int businessId,
    required String category,
  });

  /// Get expenses by date range
  Future<Either<Failure, List<Expense>>> getExpensesByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get total expenses for a period
  Future<Either<Failure, double>> getTotalExpenses({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get expenses by vendor
  Future<Either<Failure, List<Expense>>> getExpensesByVendor({
    required int businessId,
    required String vendor,
  });

  /// Get all unique expense categories
  Future<Either<Failure, List<String>>> getExpenseCategories(int businessId);

  /// Get expenses for current month
  Future<Either<Failure, List<Expense>>> getCurrentMonthExpenses(int businessId);

  /// Get expense count
  Future<Either<Failure, int>> getExpenseCount(int businessId);
}
