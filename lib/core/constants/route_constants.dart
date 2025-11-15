/// Route name constants for navigation
class RouteConstants {
  // Private constructor
  RouteConstants._();

  // Root
  static const String root = '/';

  // Splash & Onboarding
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String businessSetup = '/business-setup';

  // Authentication
  static const String pinSetup = '/pin-setup';
  static const String pinVerify = '/pin-verify';

  // Home
  static const String home = '/home';
  static const String dashboard = '/dashboard';

  // Customers
  static const String customers = '/customers';
  static const String customerList = '/customers/list';
  static const String customerDetail = '/customers/:id';
  static const String addCustomer = '/customers/add';
  static const String editCustomer = '/customers/:id/edit';

  // Transactions
  static const String transactions = '/transactions';
  static const String addTransaction = '/transactions/add';
  static const String transactionDetail = '/transactions/:id';
  static const String editTransaction = '/transactions/:id/edit';

  // Invoices
  static const String invoices = '/invoices';
  static const String invoiceList = '/invoices/list';
  static const String createInvoice = '/invoices/create';
  static const String invoiceDetail = '/invoices/:id';
  static const String invoicePreview = '/invoices/:id/preview';
  static const String editInvoice = '/invoices/:id/edit';

  // Reports
  static const String reports = '/reports';
  static const String ledgerReport = '/reports/ledger';
  static const String profitLossReport = '/reports/profit-loss';
  static const String balanceSheetReport = '/reports/balance-sheet';
  static const String daybookReport = '/reports/daybook';
  static const String salesReport = '/reports/sales';
  static const String purchaseReport = '/reports/purchase';
  static const String expenseReport = '/reports/expense';

  // Inventory
  static const String inventory = '/inventory';
  static const String itemsList = '/inventory/items';
  static const String addItem = '/inventory/items/add';
  static const String itemDetail = '/inventory/items/:id';
  static const String editItem = '/inventory/items/:id/edit';

  // Reminders
  static const String reminders = '/reminders';
  static const String addReminder = '/reminders/add';
  static const String editReminder = '/reminders/:id/edit';

  // Expenses
  static const String expenses = '/expenses';
  static const String addExpense = '/expenses/add';
  static const String expenseDetail = '/expenses/:id';
  static const String editExpense = '/expenses/:id/edit';

  // Businesses
  static const String businesses = '/businesses';
  static const String addBusiness = '/businesses/add';
  static const String editBusiness = '/businesses/:id/edit';
  static const String switchBusiness = '/businesses/switch';

  // Settings
  static const String settings = '/settings';
  static const String businessSettings = '/settings/business';
  static const String languageSettings = '/settings/language';
  static const String themeSettings = '/settings/theme';
  static const String securitySettings = '/settings/security';
  static const String backupRestore = '/settings/backup-restore';
  static const String about = '/settings/about';
  static const String help = '/settings/help';

  // Helper methods
  static String customerDetailById(int id) => '/customers/$id';
  static String editCustomerById(int id) => '/customers/$id/edit';
  static String transactionDetailById(int id) => '/transactions/$id';
  static String invoiceDetailById(int id) => '/invoices/$id';
  static String invoicePreviewById(int id) => '/invoices/$id/preview';
  static String itemDetailById(int id) => '/inventory/items/$id';
  static String editItemById(int id) => '/inventory/items/$id/edit';
}
