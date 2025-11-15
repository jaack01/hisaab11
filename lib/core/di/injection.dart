import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database/dao/customer_dao.dart';
import '../../data/datasources/local/database/dao/transaction_dao.dart';
import '../../data/datasources/local/database/dao/item_dao.dart';
import '../../data/datasources/local/database/dao/invoice_dao.dart';
import '../../data/datasources/local/database/dao/invoice_item_dao.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/usecases/customer/add_customer.dart';
import '../../domain/usecases/customer/delete_customer.dart';
import '../../domain/usecases/customer/get_customer_by_id.dart';
import '../../domain/usecases/customer/get_customers.dart';
import '../../domain/usecases/customer/search_customers.dart';
import '../../domain/usecases/customer/update_customer.dart';
import '../../domain/usecases/transaction/add_transaction.dart';
import '../../domain/usecases/transaction/get_transactions.dart';
import '../../domain/usecases/transaction/get_transactions_by_customer.dart';
import '../../domain/usecases/item/add_item.dart';
import '../../domain/usecases/item/get_items.dart';
import '../../domain/usecases/item/get_item_by_id.dart';
import '../../domain/usecases/item/update_item.dart';
import '../../domain/usecases/item/delete_item.dart';
import '../../domain/usecases/item/search_items.dart';
import '../../domain/usecases/item/get_low_stock_items.dart';
import '../../domain/usecases/item/update_stock.dart';
import '../../domain/usecases/invoice/create_invoice.dart';
import '../../domain/usecases/invoice/get_invoices.dart';
import '../../domain/usecases/invoice/get_invoice_by_id.dart';
import '../../domain/usecases/invoice/get_invoice_items.dart';
import '../../domain/usecases/invoice/get_invoices_by_customer.dart';
import '../../domain/usecases/invoice/update_invoice_payment.dart';
import '../../domain/usecases/invoice/get_next_invoice_number.dart';

// ============================================================================
// DATA SOURCES (DAOs)
// ============================================================================

final customerDaoProvider = Provider<CustomerDao>((ref) {
  return CustomerDao();
});

final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return TransactionDao();
});

final itemDaoProvider = Provider<ItemDao>((ref) {
  return ItemDao();
});

final invoiceDaoProvider = Provider<InvoiceDao>((ref) {
  return InvoiceDao();
});

final invoiceItemDaoProvider = Provider<InvoiceItemDao>((ref) {
  return InvoiceItemDao();
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

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final dao = ref.read(itemDaoProvider);
  return ItemRepositoryImpl(dao);
});

final invoiceRepositoryProvider = Provider<InvoiceRepository>((ref) {
  final invoiceDao = ref.read(invoiceDaoProvider);
  final invoiceItemDao = ref.read(invoiceItemDaoProvider);
  return InvoiceRepositoryImpl(invoiceDao, invoiceItemDao);
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

// ============================================================================
// USE CASES - ITEM
// ============================================================================

final addItemUseCaseProvider = Provider<AddItem>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return AddItem(repository);
});

final getItemsUseCaseProvider = Provider<GetItems>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return GetItems(repository);
});

final getItemByIdUseCaseProvider = Provider<GetItemById>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return GetItemById(repository);
});

final updateItemUseCaseProvider = Provider<UpdateItem>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return UpdateItem(repository);
});

final deleteItemUseCaseProvider = Provider<DeleteItem>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return DeleteItem(repository);
});

final searchItemsUseCaseProvider = Provider<SearchItems>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return SearchItems(repository);
});

final getLowStockItemsUseCaseProvider = Provider<GetLowStockItems>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return GetLowStockItems(repository);
});

final updateStockUseCaseProvider = Provider<UpdateStock>((ref) {
  final repository = ref.read(itemRepositoryProvider);
  return UpdateStock(repository);
});

// ============================================================================
// USE CASES - INVOICE
// ============================================================================

final createInvoiceUseCaseProvider = Provider<CreateInvoice>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return CreateInvoice(repository);
});

final getInvoicesUseCaseProvider = Provider<GetInvoices>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return GetInvoices(repository);
});

final getInvoiceByIdUseCaseProvider = Provider<GetInvoiceById>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return GetInvoiceById(repository);
});

final getInvoiceItemsUseCaseProvider = Provider<GetInvoiceItems>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return GetInvoiceItems(repository);
});

final getInvoicesByCustomerUseCaseProvider = Provider<GetInvoicesByCustomer>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return GetInvoicesByCustomer(repository);
});

final updateInvoicePaymentUseCaseProvider = Provider<UpdateInvoicePayment>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return UpdateInvoicePayment(repository);
});

final getNextInvoiceNumberUseCaseProvider = Provider<GetNextInvoiceNumber>((ref) {
  final repository = ref.read(invoiceRepositoryProvider);
  return GetNextInvoiceNumber(repository);
});
