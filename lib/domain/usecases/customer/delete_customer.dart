import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/customer_repository.dart';

/// Use case for deleting a customer
class DeleteCustomer {
  final CustomerRepository repository;

  DeleteCustomer(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    if (id <= 0) {
      return const Left(
        ValidationFailure(message: 'Invalid customer ID'),
      );
    }

    return await repository.deleteCustomer(id);
  }
}
