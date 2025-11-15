import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database/dao/customer_dao.dart';
import '../../data/datasources/local/database/dao/transaction_dao.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/customer/add_customer.dart';
import '../../domain/usecases/customer/delete_customer.dart';
import '../../domain/usecases/customer/get_customer_by_id.dart';
import '../../domain/usecases/customer/get_customers.dart';
import '../../domain/usecases/customer/search_customers.dart';
import '../../domain/usecases/customer/update_customer.dart';
import '../../domain/usecases/transaction/add_transaction.dart';
import '../../domain/usecases/transaction/get_transactions.dart';
import '../../domain/usecases/transaction/get_transactions_by_customer.dart';

// ============================================================================
// DATA SOURCES (DAOs)
// ============================================================================

final customerDaoProvider = Provider<CustomerDao>((ref) {
  return CustomerDao();
});

final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return TransactionDao();
});

// ============================================================================
// REPOSITORIES
// ============================================================================

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final dao = ref.read(customerDaoProvider);
  return CustomerRepositoryImpl(dao);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final dao = ref.read(transactionDaoProvider);
  return TransactionRepositoryImpl(dao);
});

// ============================================================================
// USE CASES - CUSTOMER
// ============================================================================

final addCustomerUseCaseProvider = Provider<AddCustomer>((ref) {
  final repository = ref.read(customerRepositoryProvider);
  return AddCustomer(repository);
});

final getCustomersUseCaseProvider = Provider<GetCustomers>((ref) {
  final repository = ref.read(customerRepositoryProvider);
  return GetCustomers(repository);
});

final getCustomerByIdUseCaseProvider = Provider<GetCustomerById>((ref) {
  final repository = ref.read(customerRepositoryProvider);
  return GetCustomerById(repository);
});

final updateCustomerUseCaseProvider = Provider<UpdateCustomer>((ref) {
  final repository = ref.read(customerRepositoryProvider);
  return UpdateCustomer(repository);
});

final deleteCustomerUseCaseProvider = Provider<DeleteCustomer>((ref) {
  final repository = ref.read(customerRepositoryProvider);
  return DeleteCustomer(repository);
});

final searchCustomersUseCaseProvider = Provider<SearchCustomers>((ref) {
  final repository = ref.read(customerRepositoryProvider);
  return SearchCustomers(repository);
});

// ============================================================================
// USE CASES - TRANSACTION
// ============================================================================

final addTransactionUseCaseProvider = Provider<AddTransaction>((ref) {
  final repository = ref.read(transactionRepositoryProvider);
  return AddTransaction(repository);
});

final getTransactionsUseCaseProvider = Provider<GetTransactions>((ref) {
  final repository = ref.read(transactionRepositoryProvider);
  return GetTransactions(repository);
});

final getTransactionsByCustomerUseCaseProvider = Provider<GetTransactionsByCustomer>((ref) {
  final repository = ref.read(transactionRepositoryProvider);
  return GetTransactionsByCustomer(repository);
});
