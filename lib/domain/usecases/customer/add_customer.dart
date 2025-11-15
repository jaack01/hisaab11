import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Use case for adding a new customer
class AddCustomer {
  final CustomerRepository repository;

  AddCustomer(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) async {
    // Validate customer data
    if (customer.name.trim().isEmpty) {
      return const Left(
        ValidationFailure(message: 'Customer name is required'),
      );
    }

    // Add timestamp if not provided
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final customerToAdd = customer.copyWith(
      createdAt: customer.createdAt == 0 ? now : customer.createdAt,
      updatedAt: now,
    );

    return await repository.addCustomer(customerToAdd);
  }
}
