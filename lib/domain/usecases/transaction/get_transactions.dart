import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/transaction.dart';
import '../../repositories/transaction_repository.dart';

/// Use case for getting all transactions
class GetTransactions {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    required int businessId,
    int? limit,
    int? offset,
  }) async {
    return await repository.getTransactions(
      businessId: businessId,
      limit: limit,
      offset: offset,
    );
  }
}
