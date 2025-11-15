import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/database/dao/transaction_dao.dart';
import '../models/transaction_model.dart';

/// Transaction repository implementation
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionDao dao;

  TransactionRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, Transaction>> addTransaction(Transaction transaction) async {
    try {
      final transactionModel = TransactionModel.fromEntity(transaction);
      final id = await dao.insert(transactionModel);
      final insertedTransaction = await dao.getById(id);

      if (insertedTransaction == null) {
        return const Left(DatabaseFailure(message: 'Failed to retrieve inserted transaction'));
      }

      return Right(insertedTransaction.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to add transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    required int businessId,
    int? limit,
    int? offset,
  }) async {
    try {
      final transactions = await dao.getAllTransactions(
        businessId: businessId,
        limit: limit,
        offset: offset,
      );
      return Right(transactions.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get transactions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByCustomer({
    required int customerId,
    int? limit,
    int? offset,
  }) async {
    try {
      final transactions = await dao.getTransactionsByCustomer(
        customerId: customerId,
        limit: limit,
        offset: offset,
      );
      return Right(transactions.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get transactions by customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(int id) async {
    try {
      final transaction = await dao.getById(id);

      if (transaction == null) {
        return const Left(NotFoundFailure(message: 'Transaction not found'));
      }

      return Right(transaction.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Transaction>> updateTransaction(Transaction transaction) async {
    try {
      if (transaction.id == null) {
        return const Left(ValidationFailure(message: 'Transaction ID is required'));
      }

      final transactionModel = TransactionModel.fromEntity(transaction);
      await dao.update(transactionModel, transaction.id!);
      final updatedTransaction = await dao.getById(transaction.id!);

      if (updatedTransaction == null) {
        return const Left(DatabaseFailure(message: 'Failed to retrieve updated transaction'));
      }

      return Right(updatedTransaction.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(int id) async {
    try {
      await dao.softDelete(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete transaction: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final transactions = await dao.getTransactionsByDateRange(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(transactions.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get transactions by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalCreditForCustomer(int customerId) async {
    try {
      final total = await dao.getTotalCreditForCustomer(customerId);
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total credit: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalDebitForCustomer(int customerId) async {
    try {
      final total = await dao.getTotalDebitForCustomer(customerId);
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total debit: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getCustomerBalance(int customerId) async {
    try {
      final credit = await dao.getTotalCreditForCustomer(customerId);
      final debit = await dao.getTotalDebitForCustomer(customerId);
      final balance = credit - debit;
      return Right(balance);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get customer balance: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getTransactionCount({
    required int businessId,
  }) async {
    try {
      final count = await dao.getTransactionCount(businessId: businessId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get transaction count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getRecentTransactions({
    required int businessId,
    int limit = 10,
  }) async {
    try {
      final transactions = await dao.getRecentTransactions(
        businessId: businessId,
        limit: limit,
      );
      return Right(transactions.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get recent transactions: ${e.toString()}'));
    }
  }
}
