import 'package:hisaab11/domain/entities/customer.dart';
import 'package:hisaab11/domain/entities/transaction.dart';
import 'package:hisaab11/domain/entities/invoice.dart';
import 'package:hisaab11/domain/entities/item.dart';
import 'package:hisaab11/domain/entities/expense.dart';
import 'package:hisaab11/domain/entities/reminder.dart';
import 'package:hisaab11/domain/entities/reports.dart';
import 'package:hisaab11/domain/entities/settings.dart';

/// Test data helper class
class TestData {
  TestData._();

  // Timestamps
  static final int now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  static final int yesterday = now - (24 * 60 * 60);
  static final int lastWeek = now - (7 * 24 * 60 * 60);
  static final int lastMonth = now - (30 * 24 * 60 * 60);

  // Customer test data
  static Customer customer1 = Customer(
    id: 1,
    businessId: 1,
    name: 'John Doe',
    phone: '9876543210',
    email: 'john@example.com',
    address: '123 Main St',
    currentBalance: 1000.0,
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Customer customer2 = Customer(
    id: 2,
    businessId: 1,
    name: 'Jane Smith',
    phone: '9876543211',
    email: 'jane@example.com',
    address: '456 Oak Ave',
    currentBalance: -500.0,
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Customer deletedCustomer = Customer(
    id: 3,
    businessId: 1,
    name: 'Deleted Customer',
    phone: '9876543212',
    currentBalance: 0.0,
    isDeleted: true,
    createdAt: lastMonth,
    updatedAt: lastMonth,
  );

  // Transaction test data
  static Transaction creditTransaction = Transaction(
    id: 1,
    businessId: 1,
    customerId: 1,
    transactionType: 'CREDIT',
    amount: 1000.0,
    transactionDate: now,
    description: 'You gave ₹1,000',
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Transaction debitTransaction = Transaction(
    id: 2,
    businessId: 1,
    customerId: 1,
    transactionType: 'DEBIT',
    amount: 500.0,
    transactionDate: yesterday,
    description: 'You got ₹500',
    isDeleted: false,
    createdAt: yesterday,
    updatedAt: yesterday,
  );

  // Item test data
  static Item item1 = Item(
    id: 1,
    businessId: 1,
    name: 'Product A',
    description: 'Test product A',
    price: 100.0,
    unit: 'piece',
    stockQuantity: 50,
    lowStockThreshold: 10,
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Item lowStockItem = Item(
    id: 2,
    businessId: 1,
    name: 'Product B',
    description: 'Test product B',
    price: 200.0,
    unit: 'piece',
    stockQuantity: 5,
    lowStockThreshold: 10,
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  // Invoice test data
  static Invoice paidInvoice = Invoice(
    id: 1,
    businessId: 1,
    customerId: 1,
    invoiceNumber: 'INV-001',
    invoiceDate: now,
    dueDate: now + (7 * 24 * 60 * 60),
    totalAmount: 1000.0,
    paidAmount: 1000.0,
    paymentStatus: 'PAID',
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Invoice partialInvoice = Invoice(
    id: 2,
    businessId: 1,
    customerId: 1,
    invoiceNumber: 'INV-002',
    invoiceDate: yesterday,
    dueDate: yesterday + (7 * 24 * 60 * 60),
    totalAmount: 2000.0,
    paidAmount: 1000.0,
    paymentStatus: 'PARTIAL',
    isDeleted: false,
    createdAt: yesterday,
    updatedAt: yesterday,
  );

  static Invoice unpaidInvoice = Invoice(
    id: 3,
    businessId: 1,
    customerId: 2,
    invoiceNumber: 'INV-003',
    invoiceDate: lastWeek,
    dueDate: lastWeek + (7 * 24 * 60 * 60),
    totalAmount: 1500.0,
    paidAmount: 0.0,
    paymentStatus: 'UNPAID',
    isDeleted: false,
    createdAt: lastWeek,
    updatedAt: lastWeek,
  );

  // Expense test data
  static Expense expense1 = Expense(
    id: 1,
    businessId: 1,
    category: 'Rent',
    amount: 10000.0,
    expenseDate: now,
    description: 'Office rent',
    paymentMethod: 'Cash',
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Expense expense2 = Expense(
    id: 2,
    businessId: 1,
    category: 'Salary',
    amount: 15000.0,
    expenseDate: yesterday,
    description: 'Staff salary',
    paymentMethod: 'Bank Transfer',
    isDeleted: false,
    createdAt: yesterday,
    updatedAt: yesterday,
  );

  // Reminder test data
  static Reminder pendingReminder = Reminder(
    id: 1,
    businessId: 1,
    customerId: 1,
    amount: 1000.0,
    dueDate: now + (3 * 24 * 60 * 60),
    message: 'Payment reminder',
    status: 'PENDING',
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );

  static Reminder sentReminder = Reminder(
    id: 2,
    businessId: 1,
    customerId: 2,
    amount: 500.0,
    dueDate: yesterday,
    message: 'Payment overdue',
    status: 'SENT',
    sentAt: yesterday,
    isDeleted: false,
    createdAt: lastWeek,
    updatedAt: yesterday,
  );

  // Report test data
  static LedgerReport ledgerReport = LedgerReport(
    customerId: 1,
    customerName: 'John Doe',
    startDate: lastMonth,
    endDate: now,
    openingBalance: 0.0,
    transactions: [creditTransaction, debitTransaction],
    closingBalance: 500.0,
    totalCredit: 1000.0,
    totalDebit: 500.0,
  );

  static DaybookReport daybookReport = DaybookReport(
    date: now,
    transactions: [creditTransaction],
    totalCredit: 1000.0,
    totalDebit: 0.0,
    netCashFlow: -1000.0,
    transactionCount: 1,
  );

  static ProfitLossReport profitLossReport = ProfitLossReport(
    businessId: 1,
    startDate: lastMonth,
    endDate: now,
    totalRevenue: 50000.0,
    totalExpenses: 25000.0,
    grossProfit: 50000.0,
    netProfit: 25000.0,
    profitMargin: 50.0,
    revenueByCategory: {'Sales': 50000.0},
    expensesByCategory: {'Rent': 10000.0, 'Salary': 15000.0},
  );

  static BalanceSheetReport balanceSheetReport = BalanceSheetReport(
    businessId: 1,
    asOfDate: now,
    totalReceivable: 10000.0,
    totalPayable: 2000.0,
    cashInHand: 5000.0,
    inventoryValue: 15000.0,
    totalAssets: 30000.0,
    totalLiabilities: 2000.0,
    netWorth: 28000.0,
    receivables: const [
      CustomerBalance(customerId: 1, customerName: 'John Doe', balance: 10000.0),
    ],
    payables: const [
      CustomerBalance(customerId: 2, customerName: 'Supplier A', balance: 2000.0),
    ],
  );

  // Settings test data
  static const AppSettings defaultSettings = AppSettings();

  static const AppSettings customSettings = AppSettings(
    language: 'hi',
    theme: 'dark',
    dateFormat: 'MM/dd/yyyy',
    currencyFormat: 'USD',
    autoBackupEnabled: true,
    autoBackupIntervalDays: 1,
  );

  // Helper methods
  static List<Customer> getCustomerList({int count = 10}) {
    return List.generate(
      count,
      (index) => Customer(
        id: index + 1,
        businessId: 1,
        name: 'Customer ${index + 1}',
        phone: '98765432${10 + index}',
        currentBalance: (index % 2 == 0) ? 1000.0 : -500.0,
        isDeleted: false,
        createdAt: now - (index * 24 * 60 * 60),
        updatedAt: now - (index * 24 * 60 * 60),
      ),
    );
  }

  static List<Transaction> getTransactionList({int count = 20}) {
    return List.generate(
      count,
      (index) => Transaction(
        id: index + 1,
        businessId: 1,
        customerId: (index % 5) + 1,
        transactionType: index % 2 == 0 ? 'CREDIT' : 'DEBIT',
        amount: (index + 1) * 100.0,
        transactionDate: now - (index * 24 * 60 * 60),
        description: 'Transaction ${index + 1}',
        isDeleted: false,
        createdAt: now - (index * 24 * 60 * 60),
        updatedAt: now - (index * 24 * 60 * 60),
      ),
    );
  }

  static List<Item> getItemList({int count = 15}) {
    return List.generate(
      count,
      (index) => Item(
        id: index + 1,
        businessId: 1,
        name: 'Item ${index + 1}',
        description: 'Description ${index + 1}',
        price: (index + 1) * 50.0,
        unit: 'piece',
        stockQuantity: index % 3 == 0 ? 5 : 50,
        lowStockThreshold: 10,
        isDeleted: false,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
