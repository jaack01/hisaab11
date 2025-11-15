import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Use case for updating a customer
class UpdateCustomer {
  final CustomerRepository repository;

  UpdateCustomer(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) async {
    // Validate customer data
    if (customer.id == null || customer.id! <= 0) {
      return const Left(
        ValidationFailure(message: 'Invalid customer ID'),
      );
    }

    if (customer.name.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Customer name is required'),
      );
    }

    // Update timestamp
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final customerToUpdate = customer.copyWith(updatedAt: now);

    return await repository.updateCustomer(customerToUpdate);
  }
}
