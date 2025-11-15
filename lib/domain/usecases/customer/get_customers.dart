import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Use case for getting all customers
class GetCustomers {
  final CustomerRepository repository;

  GetCustomers(this.repository);

  Future<Either<Failure, List<Customer>>> call({
    required int businessId,
    int? limit,
    int? offset,
  }) async {
    return await repository.getCustomers(
      businessId: businessId,
      limit: limit,
      offset: offset,
    );
  }
}
