import 'package:dartz/dartz.dart';
import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/database/dao/customer_dao.dart';
import '../models/customer_model.dart';

/// Customer repository implementation
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerDao dao;

  CustomerRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, Customer>> addCustomer(Customer customer) async {
    try {
      final customerModel = CustomerModel.fromEntity(customer);
      final id = await dao.insert(customerModel);
      final insertedCustomer = await dao.getById(id);

      if (insertedCustomer == null) {
        return const Left(DatabaseFailure(message: 'Failed to retrieve inserted customer'));
      }

      return Right(insertedCustomer.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to add customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomers({
    required int businessId,
    int? limit,
    int? offset,
  }) async {
    try {
      final customers = await dao.getAllCustomers(
        businessId: businessId,
        limit: limit,
        offset: offset,
      );
      return Right(customers.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get customers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(int id) async {
    try {
      final customer = await dao.getById(id);

      if (customer == null) {
        return const Left(NotFoundFailure(message: 'Customer not found'));
      }

      return Right(customer.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer customer) async {
    try {
      if (customer.id == null) {
        return const Left(ValidationFailure(message: 'Customer ID is required'));
      }

      final customerModel = CustomerModel.fromEntity(customer);
      await dao.update(customerModel, customer.id!);
      final updatedCustomer = await dao.getById(customer.id!);

      if (updatedCustomer == null) {
        return const Left(DatabaseFailure(message: 'Failed to retrieve updated customer'));
      }

      return Right(updatedCustomer.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to update customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(int id) async {
    try {
      await dao.softDelete(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete customer: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> searchCustomers({
    required int businessId,
    required String query,
  }) async {
    try {
      final customers = await dao.searchCustomers(
        businessId: businessId,
        query: query,
      );
      return Right(customers.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to search customers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomersWithOutstanding({
    required int businessId,
  }) async {
    try {
      final customers = await dao.getCustomersWithOutstanding(
        businessId: businessId,
      );
      return Right(customers.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get customers with outstanding: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Customer>>> getCustomersWithCredit({
    required int businessId,
  }) async {
    try {
      final customers = await dao.getCustomersWithCredit(
        businessId: businessId,
      );
      return Right(customers.map((model) => model.toEntity()).toList());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get customers with credit: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> getCustomerCount({required int businessId}) async {
    try {
      final count = await dao.getCustomerCount(businessId: businessId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get customer count: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalReceivable({required int businessId}) async {
    try {
      final total = await dao.getTotalReceivable(businessId: businessId);
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total receivable: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPayable({required int businessId}) async {
    try {
      final total = await dao.getTotalPayable(businessId: businessId);
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get total payable: ${e.toString()}'));
    }
  }
}
