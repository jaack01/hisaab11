import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';

/// Use case for getting all expenses for a business
class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<Either<Failure, List<Expense>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getExpenses(businessId);
  }
}
