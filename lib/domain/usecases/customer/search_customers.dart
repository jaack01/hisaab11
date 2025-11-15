import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Use case for searching customers
class SearchCustomers {
  final CustomerRepository repository;

  SearchCustomers(this.repository);

  Future<Either<Failure, List<Customer>>> call({
    required int businessId,
    required String query,
  }) async {
    if (query.trim().isEmpty) {
      return const Right([]);
    }

    return await repository.searchCustomers(
      businessId: businessId,
      query: query.trim(),
    );
  }
}
