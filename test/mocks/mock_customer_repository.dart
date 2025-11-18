import 'package:dartz/dartz.dart';
import 'package:hisaab11/core/error/failures.dart';
import 'package:hisaab11/domain/entities/customer.dart';
import 'package:hisaab11/domain/repositories/customer_repository.dart';

class MockCustomerRepository implements CustomerRepository {
  Customer? _mockCustomer;
  List<Customer>? _mockCustomers;
  Failure? _mockFailure;
  int? _mockId;

  void setupAddCustomer(Customer customer) {
    _mockCustomer = customer;
    _mockId = customer.id;
  }

  void setupGetCustomers(List<Customer> customers) {
    _mockCustomers = customers;
  }

  void setupGetCustomerById(Customer customer) {
    _mockCustomer = customer;
  }

  void setupGetCustomerByIdNotFound() {
    _mockFailure = NotFoundFailure(message: 'Customer not found');
  }

  void setupUpdateCustomer() {
    // Success case
  }

  void setupDeleteCustomer() {
    // Success case
  }

  void setupSearchCustomers(List<Customer> customers) {
    _mockCustomers = customers;
  }

  @override
  Future<Either<Failure, int>> addCustomer(Customer customer) async {
    if (_mockId != null) {
      return Right(_mockId!);
    }
    return Left(DatabaseFailure(message: 'Failed to add customer'));
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(int customerId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(int customerId) async {
    if (_mockCustomer != null) {
      return Right(_mockCustomer!);
    }
    if (_mockFailure != null) {
      return Left(_mockFailure!);
    }
    return Left(NotFoundFailure(message: 'Customer not found'));
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomers(int businessId) async {
    if (_mockCustomers != null) {
      return Right(_mockCustomers!);
    }
    return const Right([]);
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers({
    required int businessId,
    required String query,
  }) async {
    if (_mockCustomers != null) {
      return Right(_mockCustomers!);
    }
    return const Right([]);
  }

  @override
  Future<Either<Failure, void>> updateCustomer(Customer customer) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, double>> getTotalReceivable(int businessId) async {
    return const Right(0.0);
  }

  @override
  Future<Either<Failure, double>> getTotalPayable(int businessId) async {
    return const Right(0.0);
  }
}
