import 'package:flutter/material.dart';

// Splash & Home
import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';

// Customers
import '../../presentation/screens/customers/customer_list_screen.dart';
import '../../presentation/screens/customers/customer_detail_screen.dart';
import '../../presentation/screens/customers/add_customer_screen.dart';
import '../../presentation/screens/customers/edit_customer_screen.dart';

// Transactions
import '../../presentation/screens/transactions/add_transaction_screen.dart';
import '../../presentation/screens/transactions/transaction_list_screen.dart';
import '../../presentation/screens/transactions/edit_transaction_screen.dart';

// Invoices
import '../../presentation/screens/invoices/invoice_list_screen.dart';
import '../../presentation/screens/invoices/create_invoice_screen.dart';
import '../../presentation/screens/invoices/invoice_detail_screen.dart';

// Items
import '../../presentation/screens/items/item_list_screen.dart';
import '../../presentation/screens/items/add_item_screen.dart';
import '../../presentation/screens/items/edit_item_screen.dart';

// Reports
import '../../presentation/screens/reports/reports_dashboard_screen.dart';
import '../../presentation/screens/reports/ledger_report_screen.dart';
import '../../presentation/screens/reports/daybook_report_screen.dart';
import '../../presentation/screens/reports/profit_loss_report_screen.dart';
import '../../presentation/screens/reports/balance_sheet_report_screen.dart';

// Expenses
import '../../presentation/screens/expenses/expense_list_screen.dart';
import '../../presentation/screens/expenses/add_expense_screen.dart';
import '../../presentation/screens/expenses/edit_expense_screen.dart';

// Reminders
import '../../presentation/screens/reminders/reminder_list_screen.dart';
import '../../presentation/screens/reminders/add_reminder_screen.dart';
import '../../presentation/screens/reminders/edit_reminder_screen.dart';

// Settings
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/settings/backup_restore_screen.dart';
import '../../presentation/screens/settings/business_profile_screen.dart';

import 'app_routes.dart';

/// App router configuration
class AppRouter {
  /// Generate route based on route settings
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Splash & Home
      case Routes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case Routes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // Customers
      case Routes.customerList:
        return MaterialPageRoute(
          builder: (_) => const CustomerListScreen(),
          settings: settings,
        );

      case Routes.customerDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final customer = args?['customer'];
        if (customer == null) {
          return _errorRoute('Customer is required');
        }
        return MaterialPageRoute(
          builder: (_) => CustomerDetailScreen(customer: customer),
          settings: settings,
        );

      case Routes.addCustomer:
        return MaterialPageRoute(
          builder: (_) => const AddCustomerScreen(),
          settings: settings,
        );

      case Routes.editCustomer:
        final args = settings.arguments as Map<String, dynamic>?;
        final customerId = args?['customerId'] as int?;
        if (customerId == null) {
          return _errorRoute('Customer ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => EditCustomerScreen(customerId: customerId),
          settings: settings,
        );

      // Transactions
      case Routes.addTransaction:
        final args = settings.arguments as Map<String, dynamic>?;
        final customer = args?['customer'];
        final initialType = args?['initialType'] as String?;
        return MaterialPageRoute(
          builder: (_) => AddTransactionScreen(
            customer: customer,
            initialType: initialType,
          ),
          settings: settings,
        );

      case Routes.transactionList:
        final args = settings.arguments as Map<String, dynamic>?;
        final customerId = args?['customerId'] as int?;
        return MaterialPageRoute(
          builder: (_) => TransactionListScreen(customerId: customerId),
          settings: settings,
        );

      case Routes.editTransaction:
        final args = settings.arguments as Map<String, dynamic>?;
        final transactionId = args?['transactionId'] as int?;
        if (transactionId == null) {
          return _errorRoute('Transaction ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => EditTransactionScreen(transactionId: transactionId),
          settings: settings,
        );

      // Invoices
      case Routes.invoiceList:
        return MaterialPageRoute(
          builder: (_) => const InvoiceListScreen(),
          settings: settings,
        );

      case Routes.createInvoice:
        final args = settings.arguments as Map<String, dynamic>?;
        final customerId = args?['customerId'] as int?;
        return MaterialPageRoute(
          builder: (_) => CreateInvoiceScreen(customerId: customerId),
          settings: settings,
        );

      case Routes.invoiceDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        final invoiceId = args?['invoiceId'] as int?;
        if (invoiceId == null) {
          return _errorRoute('Invoice ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => InvoiceDetailScreen(invoiceId: invoiceId),
          settings: settings,
        );

      case Routes.editInvoice:
        final args = settings.arguments as Map<String, dynamic>?;
        final invoiceId = args?['invoiceId'] as int?;
        if (invoiceId == null) {
          return _errorRoute('Invoice ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen(title: 'Edit Invoice'),
          settings: settings,
        );

      // Items
      case Routes.itemList:
        return MaterialPageRoute(
          builder: (_) => const ItemListScreen(),
          settings: settings,
        );

      case Routes.addItem:
        return MaterialPageRoute(
          builder: (_) => const AddItemScreen(),
          settings: settings,
        );

      case Routes.editItem:
        final args = settings.arguments as Map<String, dynamic>?;
        final itemId = args?['itemId'] as int?;
        if (itemId == null) {
          return _errorRoute('Item ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => EditItemScreen(itemId: itemId),
          settings: settings,
        );

      // Reports
      case Routes.reportsDashboard:
        return MaterialPageRoute(
          builder: (_) => const ReportsDashboardScreen(),
          settings: settings,
        );

      case Routes.ledgerReport:
        final args = settings.arguments as Map<String, dynamic>?;
        final customerId = args?['customerId'] as int?;
        return MaterialPageRoute(
          builder: (_) => LedgerReportScreen(customerId: customerId),
          settings: settings,
        );

      case Routes.daybookReport:
        return MaterialPageRoute(
          builder: (_) => const DaybookReportScreen(),
          settings: settings,
        );

      case Routes.profitLossReport:
        return MaterialPageRoute(
          builder: (_) => const ProfitLossReportScreen(),
          settings: settings,
        );

      case Routes.balanceSheetReport:
        return MaterialPageRoute(
          builder: (_) => const BalanceSheetReportScreen(),
          settings: settings,
        );

      // Expenses
      case Routes.expenseList:
        return MaterialPageRoute(
          builder: (_) => const ExpenseListScreen(),
          settings: settings,
        );

      case Routes.addExpense:
        return MaterialPageRoute(
          builder: (_) => const AddExpenseScreen(),
          settings: settings,
        );

      case Routes.editExpense:
        final args = settings.arguments as Map<String, dynamic>?;
        final expenseId = args?['expenseId'] as int?;
        if (expenseId == null) {
          return _errorRoute('Expense ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => EditExpenseScreen(expenseId: expenseId),
          settings: settings,
        );

      // Reminders
      case Routes.reminderList:
        return MaterialPageRoute(
          builder: (_) => const ReminderListScreen(),
          settings: settings,
        );

      case Routes.addReminder:
        final args = settings.arguments as Map<String, dynamic>?;
        final customerId = args?['customerId'] as int?;
        return MaterialPageRoute(
          builder: (_) => AddReminderScreen(customerId: customerId),
          settings: settings,
        );

      case Routes.editReminder:
        final args = settings.arguments as Map<String, dynamic>?;
        final reminderId = args?['reminderId'] as int?;
        if (reminderId == null) {
          return _errorRoute('Reminder ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => EditReminderScreen(reminderId: reminderId),
          settings: settings,
        );

      // Settings
      case Routes.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );

      case Routes.backupRestore:
        return MaterialPageRoute(
          builder: (_) => const BackupRestoreScreen(),
          settings: settings,
        );

      case Routes.exportData:
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen(title: 'Export Data'),
          settings: settings,
        );

      case Routes.businessProfile:
        return MaterialPageRoute(
          builder: (_) => const BusinessProfileScreen(),
          settings: settings,
        );

      case Routes.about:
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen(title: 'About'),
          settings: settings,
        );

      // Onboarding
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen(title: 'Onboarding'),
          settings: settings,
        );

      case Routes.setupWizard:
        return MaterialPageRoute(
          builder: (_) => _PlaceholderScreen(title: 'Setup'),
          settings: settings,
        );

      // Default
      default:
        return _errorRoute('Route not found: ${settings.name}');
    }
  }

  /// Error route for undefined routes
  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Text(
            message,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}

// Generic placeholder screen for unimplemented screens
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
