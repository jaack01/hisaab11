import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';

/// Use case for adding a new expense
class AddExpense {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  Future<Either<Failure, Expense>> call(Expense expense) async {
    // Validate expense
    if (expense.title.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Expense title is required'));
    }

    if (expense.amount <= 0) {
      return Left(ValidationFailure(
        message: 'Expense amount must be greater than zero',
      ));
    }

    if (expense.category.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Expense category is required'));
    }

    return repository.addExpense(expense);
  }
}
