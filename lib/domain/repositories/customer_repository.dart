import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/customer.dart';

/// Customer repository interface
abstract class CustomerRepository {
  /// Add a new customer
  Future<Either<Failure, Customer>> addCustomer(Customer customer);

  /// Get all customers for a business
  Future<Either<Failure, List<Customer>>> getCustomers({
    required int businessId,
    int? limit,
    int? offset,
  });

  /// Get customer by ID
  Future<Either<Failure, Customer>> getCustomerById(int id);

  /// Update customer
  Future<Either<Failure, Customer>> updateCustomer(Customer customer);

  /// Delete customer (soft delete)
  Future<Either<Failure, void>> deleteCustomer(int id);

  /// Search customers by name or phone
  Future<Either<Failure, List<Customer>>> searchCustomers({
    required int businessId,
    required String query,
  });

  /// Get customers with outstanding balance (money to receive)
  Future<Either<Failure, List<Customer>>> getCustomersWithOutstanding({
    required int businessId,
  });

  /// Get customers with credit balance (money to pay)
  Future<Either<Failure, List<Customer>>> getCustomersWithCredit({
    required int businessId,
  });

  /// Get total count of customers
  Future<Either<Failure, int>> getCustomerCount({required int businessId});

  /// Get total receivable amount
  Future<Either<Failure, double>> getTotalReceivable({required int businessId});

  /// Get total payable amount
  Future<Either<Failure, double>> getTotalPayable({required int businessId});
}
