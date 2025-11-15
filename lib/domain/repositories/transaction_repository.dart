import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/transaction.dart';

/// Transaction repository interface
abstract class TransactionRepository {
  /// Add a new transaction
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction);

  /// Get all transactions for a business
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required int businessId,
    int? limit,
    int? offset,
  });

  /// Get transactions for a specific customer
  Future<Either<Failure, List<Transaction>>> getTransactionsByCustomer({
    required int customerId,
    int? limit,
    int? offset,
  });

  /// Get transaction by ID
  Future<Either<Failure, Transaction>> getTransactionById(int id);

  /// Update transaction
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction);

  /// Delete transaction (soft delete)
  Future<Either<Failure, void>> deleteTransaction(int id);

  /// Get transactions by date range
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get total credit amount for a customer
  Future<Either<Failure, double>> getTotalCreditForCustomer(int customerId);

  /// Get total debit amount for a customer
  Future<Either<Failure, double>> getTotalDebitForCustomer(int customerId);

  /// Get customer balance
  Future<Either<Failure, double>> getCustomerBalance(int customerId);

  /// Get transaction count
  Future<Either<Failure, int>> getTransactionCount({
    required int businessId,
  });

  /// Get recent transactions
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    required int businessId,
    int limit = 10,
  });
}
