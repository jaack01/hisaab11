import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../../core/constants/app_constants.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for adding a new transaction
class AddTransaction {
  final TransactionRepository repository;

  AddTransaction(this.repository);

  Future<Either<Failure, Transaction>> call(Transaction transaction) async {
    // Validate transaction data
    if (transaction.customerId <= 0) {
      return const Left(
        ValidationFailure(message: 'Invalid customer ID'),
      );
    }

    if (transaction.amount <= 0) {
      return const Left(
        ValidationFailure(message: 'Amount must be greater than zero'),
      );
    }

    if (transaction.amount < AppConstants.minTransactionAmount ||
        transaction.amount > AppConstants.maxTransactionAmount) {
      return const Left(
        ValidationFailure(message: 'Invalid transaction amount'),
      );
    }

    if (transaction.transactionType != AppConstants.transactionTypeCredit &&
        transaction.transactionType != AppConstants.transactionTypeDebit) {
      return const Left(
        ValidationFailure(message: 'Invalid transaction type'),
      );
    }

    // Add timestamp if not provided
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final transactionToAdd = transaction.copyWith(
      createdAt: transaction.createdAt == 0 ? now : transaction.createdAt,
      updatedAt: now,
    );

    return await repository.addTransaction(transactionToAdd);
  }
}
