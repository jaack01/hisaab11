import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local/database/dao/customer_dao.dart';
import '../../data/datasources/local/database/dao/transaction_dao.dart';
import '../../data/datasources/local/database/dao/item_dao.dart';
import '../../data/datasources/local/database/dao/invoice_dao.dart';
import '../../data/datasources/local/database/dao/invoice_item_dao.dart';
import '../../data/datasources/local/database/dao/reminder_dao.dart';
import '../../data/datasources/local/database/dao/expense_dao.dart';
import '../../data/repositories/customer_repository_impl.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/item_repository_impl.dart';
import '../../data/repositories/invoice_repository_impl.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/item_repository.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/report_repository.dart';
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
import '../../domain/usecases/reminder/create_reminder.dart';
import '../../domain/usecases/reminder/get_reminders.dart';
import '../../domain/usecases/reminder/get_pending_reminders.dart';
import '../../domain/usecases/reminder/mark_reminder_sent.dart';
import '../../domain/usecases/expense/add_expense.dart';
import '../../domain/usecases/expense/get_expenses.dart';
import '../../domain/usecases/expense/get_expenses_by_category.dart';
import '../../domain/usecases/expense/get_total_expenses.dart';
import '../../domain/usecases/report/generate_business_report.dart';
import '../../domain/usecases/report/get_dashboard_summary.dart';
import '../../domain/usecases/reports/generate_ledger_report.dart';
import '../../domain/usecases/reports/generate_daybook_report.dart';
import '../../domain/usecases/reports/generate_profit_loss_report.dart';
import '../../domain/usecases/reports/generate_balance_sheet.dart';
import '../../domain/repositories/reports_repository.dart';
import '../../data/repositories/reports_repository_impl.dart';
import '../../domain/usecases/settings/get_settings.dart';
import '../../domain/usecases/settings/update_settings.dart';
import '../../domain/usecases/settings/create_backup.dart';
import '../../domain/usecases/settings/restore_backup.dart';
import '../../domain/usecases/settings/get_available_backups.dart';
import '../../domain/usecases/settings/export_data.dart';
import '../../domain/usecases/settings/get_business_profile.dart';
import '../../domain/usecases/settings/update_business_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/usecases/onboarding/get_onboarding_state.dart';
import '../../domain/usecases/onboarding/complete_onboarding.dart';
import '../../domain/usecases/onboarding/complete_setup.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../../data/repositories/onboarding_repository_impl.dart';

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

final reminderDaoProvider = Provider<ReminderDao>((ref) {
  return ReminderDao();
});

final expenseDaoProvider = Provider<ExpenseDao>((ref) {
  return ExpenseDao();
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

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final dao = ref.read(reminderDaoProvider);
  return ReminderRepositoryImpl(dao);
});

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final dao = ref.read(expenseDaoProvider);
  return ExpenseRepositoryImpl(dao);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  final customerDao = ref.read(customerDaoProvider);
  final transactionDao = ref.read(transactionDaoProvider);
  final invoiceDao = ref.read(invoiceDaoProvider);
  final invoiceItemDao = ref.read(invoiceItemDaoProvider);
  final itemDao = ref.read(itemDaoProvider);
  final expenseDao = ref.read(expenseDaoProvider);
  return ReportRepositoryImpl(
    customerDao: customerDao,
    transactionDao: transactionDao,
    invoiceDao: invoiceDao,
    invoiceItemDao: invoiceItemDao,
    itemDao: itemDao,
    expenseDao: expenseDao,
  );
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  final customerDao = ref.read(customerDaoProvider);
  final transactionDao = ref.read(transactionDaoProvider);
  final invoiceDao = ref.read(invoiceDaoProvider);
  final expenseDao = ref.read(expenseDaoProvider);
  final itemDao = ref.read(itemDaoProvider);
  return ReportsRepositoryImpl(
    customerDao: customerDao,
    transactionDao: transactionDao,
    invoiceDao: invoiceDao,
    expenseDao: expenseDao,
    itemDao: itemDao,
  );
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

// ============================================================================
// USE CASES - REMINDER
// ============================================================================

final createReminderUseCaseProvider = Provider<CreateReminder>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return CreateReminder(repository);
});

final getRemindersUseCaseProvider = Provider<GetReminders>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return GetReminders(repository);
});

final getPendingRemindersUseCaseProvider = Provider<GetPendingReminders>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return GetPendingReminders(repository);
});

final markReminderSentUseCaseProvider = Provider<MarkReminderSent>((ref) {
  final repository = ref.read(reminderRepositoryProvider);
  return MarkReminderSent(repository);
});

// ============================================================================
// USE CASES - EXPENSE
// ============================================================================

final addExpenseUseCaseProvider = Provider<AddExpense>((ref) {
  final repository = ref.read(expenseRepositoryProvider);
  return AddExpense(repository);
});

final getExpensesUseCaseProvider = Provider<GetExpenses>((ref) {
  final repository = ref.read(expenseRepositoryProvider);
  return GetExpenses(repository);
});

final getExpensesByCategoryUseCaseProvider = Provider<GetExpensesByCategory>((ref) {
  final repository = ref.read(expenseRepositoryProvider);
  return GetExpensesByCategory(repository);
});

final getTotalExpensesUseCaseProvider = Provider<GetTotalExpenses>((ref) {
  final repository = ref.read(expenseRepositoryProvider);
  return GetTotalExpenses(repository);
});

// ============================================================================
// USE CASES - REPORT
// ============================================================================

final generateBusinessReportUseCaseProvider = Provider<GenerateBusinessReport>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GenerateBusinessReport(repository);
});

final getDashboardSummaryUseCaseProvider = Provider<GetDashboardSummary>((ref) {
  final repository = ref.read(reportRepositoryProvider);
  return GetDashboardSummary(repository);
});

// ============================================================================
// USE CASES - REPORTS (Phase 3)
// ============================================================================

final generateLedgerReportUseCaseProvider = Provider<GenerateLedgerReport>((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GenerateLedgerReport(repository);
});

final generateDaybookReportUseCaseProvider = Provider<GenerateDaybookReport>((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GenerateDaybookReport(repository);
});

final generateProfitLossReportUseCaseProvider = Provider<GenerateProfitLossReport>((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GenerateProfitLossReport(repository);
});

final generateBalanceSheetUseCaseProvider = Provider<GenerateBalanceSheet>((ref) {
  final repository = ref.read(reportsRepositoryProvider);
  return GenerateBalanceSheet(repository);
});

// ============================================================================
// USE CASES - SETTINGS (Phase 6)
// ============================================================================

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

final getSettingsUseCaseProvider = Provider<GetSettings>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return GetSettings(repository);
});

final updateSettingsUseCaseProvider = Provider<UpdateSettings>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return UpdateSettings(repository);
});

final createBackupUseCaseProvider = Provider<CreateBackup>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return CreateBackup(repository);
});

final restoreBackupUseCaseProvider = Provider<RestoreBackup>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return RestoreBackup(repository);
});

final getAvailableBackupsUseCaseProvider = Provider<GetAvailableBackups>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return GetAvailableBackups(repository);
});

final exportDataUseCaseProvider = Provider<ExportData>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return ExportData(repository);
});

final getBusinessProfileUseCaseProvider = Provider<GetBusinessProfile>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return GetBusinessProfile(repository);
});

final updateBusinessProfileUseCaseProvider = Provider<UpdateBusinessProfile>((ref) {
  final repository = ref.read(settingsRepositoryProvider);
  return UpdateBusinessProfile(repository);
});

// ============================================================================
// USE CASES - ONBOARDING (Phase 7)
// ============================================================================

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl();
});

final getOnboardingStateUseCaseProvider = Provider<GetOnboardingState>((ref) {
  final repository = ref.read(onboardingRepositoryProvider);
  return GetOnboardingState(repository);
});

final completeOnboardingUseCaseProvider = Provider<CompleteOnboarding>((ref) {
  final repository = ref.read(onboardingRepositoryProvider);
  return CompleteOnboarding(repository);
});

final completeSetupUseCaseProvider = Provider<CompleteSetup>((ref) {
  final repository = ref.read(onboardingRepositoryProvider);
  return CompleteSetup(repository);
});
