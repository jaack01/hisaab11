import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';

/// Use case for getting expenses by category
class GetExpensesByCategory {
  final ExpenseRepository repository;

  GetExpensesByCategory(this.repository);

  Future<Either<Failure, List<Expense>>> call({
    required int businessId,
    required String category,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    if (category.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Category cannot be empty'));
    }

    return repository.getExpensesByCategory(
      businessId: businessId,
      category: category,
    );
  }
}
