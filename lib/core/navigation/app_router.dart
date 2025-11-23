import 'package:flutter/material.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/customers/customer_list_screen.dart';
import '../../presentation/screens/customers/customer_detail_screen.dart';
import '../../presentation/screens/customers/add_customer_screen.dart';
import '../../presentation/screens/transactions/add_transaction_screen.dart';
// Import other screens as they are created
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
        final customerId = args?['customerId'] as int?;
        if (customerId == null) {
          return _errorRoute('Customer ID is required');
        }
        return MaterialPageRoute(
          builder: (_) => CustomerDetailScreen(customerId: customerId),
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
        final customerId = args?['customerId'] as int?;
        return MaterialPageRoute(
          builder: (_) => AddTransactionScreen(customerId: customerId),
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
          builder: (_) => EditInvoiceScreen(invoiceId: invoiceId),
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
          builder: (_) => const ExportDataScreen(),
          settings: settings,
        );

      case Routes.businessProfile:
        return MaterialPageRoute(
          builder: (_) => const BusinessProfileScreen(),
          settings: settings,
        );

      case Routes.about:
        return MaterialPageRoute(
          builder: (_) => const AboutScreen(),
          settings: settings,
        );

      // Onboarding
      case Routes.onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );

      case Routes.setupWizard:
        return MaterialPageRoute(
          builder: (_) => const SetupWizardScreen(),
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

// Placeholder screens (to be implemented)

class EditCustomerScreen extends StatelessWidget {
  final int customerId;
  const EditCustomerScreen({super.key, required this.customerId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Edit Customer');
}

class TransactionListScreen extends StatelessWidget {
  final int? customerId;
  const TransactionListScreen({super.key, this.customerId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Transactions');
}

class EditTransactionScreen extends StatelessWidget {
  final int transactionId;
  const EditTransactionScreen({super.key, required this.transactionId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Edit Transaction');
}

class InvoiceListScreen extends StatelessWidget {
  const InvoiceListScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Invoices');
}

class CreateInvoiceScreen extends StatelessWidget {
  final int? customerId;
  const CreateInvoiceScreen({super.key, this.customerId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Create Invoice');
}

class InvoiceDetailScreen extends StatelessWidget {
  final int invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Invoice Detail');
}

class EditInvoiceScreen extends StatelessWidget {
  final int invoiceId;
  const EditInvoiceScreen({super.key, required this.invoiceId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Edit Invoice');
}

class ItemListScreen extends StatelessWidget {
  const ItemListScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Items');
}

class AddItemScreen extends StatelessWidget {
  const AddItemScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Add Item');
}

class EditItemScreen extends StatelessWidget {
  final int itemId;
  const EditItemScreen({super.key, required this.itemId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Edit Item');
}

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Reports');
}

class LedgerReportScreen extends StatelessWidget {
  final int? customerId;
  const LedgerReportScreen({super.key, this.customerId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Ledger Report');
}

class DaybookReportScreen extends StatelessWidget {
  const DaybookReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Daybook Report');
}

class ProfitLossReportScreen extends StatelessWidget {
  const ProfitLossReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Profit & Loss');
}

class BalanceSheetReportScreen extends StatelessWidget {
  const BalanceSheetReportScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Balance Sheet');
}

class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Expenses');
}

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Add Expense');
}

class EditExpenseScreen extends StatelessWidget {
  final int expenseId;
  const EditExpenseScreen({super.key, required this.expenseId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Edit Expense');
}

class ReminderListScreen extends StatelessWidget {
  const ReminderListScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Reminders');
}

class AddReminderScreen extends StatelessWidget {
  final int? customerId;
  const AddReminderScreen({super.key, this.customerId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Add Reminder');
}

class EditReminderScreen extends StatelessWidget {
  final int reminderId;
  const EditReminderScreen({super.key, required this.reminderId});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Edit Reminder');
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Settings');
}

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Backup & Restore');
}

class ExportDataScreen extends StatelessWidget {
  const ExportDataScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Export Data');
}

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Business Profile');
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'About');
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Onboarding');
}

class SetupWizardScreen extends StatelessWidget {
  const SetupWizardScreen({super.key});
  @override
  Widget build(BuildContext context) => _PlaceholderScreen(title: 'Setup');
}

// Generic placeholder screen
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
