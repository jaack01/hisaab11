import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/expense_repository.dart';

/// Use case for getting total expenses for a period
class GetTotalExpenses {
  final ExpenseRepository repository;

  GetTotalExpenses(this.repository);

  Future<Either<Failure, double>> call({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    if (startDate > endDate) {
      return Left(ValidationFailure(
        message: 'Start date cannot be after end date',
      ));
    }

    return repository.getTotalExpenses(
      businessId: businessId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
