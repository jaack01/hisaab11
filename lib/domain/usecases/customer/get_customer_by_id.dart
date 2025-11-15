import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Use case for getting a customer by ID
class GetCustomerById {
  final CustomerRepository repository;

  GetCustomerById(this.repository);

  Future<Either<Failure, Customer>> call(int id) async {
    if (id <= 0) {
      return const Left(
        ValidationFailure(message: 'Invalid customer ID'),
      );
    }

    return await repository.getCustomerById(id);
  }
}
