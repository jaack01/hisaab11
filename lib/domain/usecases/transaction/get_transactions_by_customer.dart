import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for getting transactions by customer
class GetTransactionsByCustomer {
  final TransactionRepository repository;

  GetTransactionsByCustomer(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    required int customerId,
    int? limit,
    int? offset,
  }) async {
    if (customerId <= 0) {
      return const Left(
        ValidationFailure(message: 'Invalid customer ID'),
      );
    }

    return await repository.getTransactionsByCustomer(
      customerId: customerId,
      limit: limit,
      offset: offset,
    );
  }
}
