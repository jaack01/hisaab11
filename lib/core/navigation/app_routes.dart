/// App route names
class Routes {
  // Core
  static const String splash = '/';
  static const String home = '/home';

  // Customers
  static const String customerList = '/customers';
  static const String customerDetail = '/customers/detail';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/edit';

  // Transactions
  static const String transactionList = '/transactions';
  static const String transactionDetail = '/transactions/detail';
  static const String addTransaction = '/transactions/add';
  static const String editTransaction = '/transactions/edit';

  // Invoices
  static const String invoiceList = '/invoices';
  static const String invoiceDetail = '/invoices/detail';
  static const String createInvoice = '/invoices/create';
  static const String editInvoice = '/invoices/edit';

  // Items
  static const String itemList = '/items';
  static const String addItem = '/items/add';
  static const String editItem = '/items/edit';

  // Reports
  static const String reportsDashboard = '/reports';
  static const String ledgerReport = '/reports/ledger';
  static const String daybookReport = '/reports/daybook';
  static const String profitLossReport = '/reports/profit-loss';
  static const String balanceSheetReport = '/reports/balance-sheet';

  // Expenses
  static const String expenseList = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String editExpense = '/expenses/edit';

  // Reminders
  static const String reminderList = '/reminders';
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/edit';

  // Settings
  static const String settings = '/settings';
  static const String backupRestore = '/settings/backup';
  static const String exportData = '/settings/export';
  static const String businessProfile = '/settings/business';
  static const String about = '/settings/about';

  // Onboarding
  static const String onboarding = '/onboarding';
  static const String setupWizard = '/setup';
}
