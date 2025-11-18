import 'package:equatable/equatable.dart';
import 'transaction.dart';

/// Ledger report for a specific customer showing transaction history
class LedgerReport extends Equatable {
  final int customerId;
  final String customerName;
  final int startDate;
  final int endDate;
  final double openingBalance;
  final List<Transaction> transactions;
  final double closingBalance;
  final double totalCredit;
  final double totalDebit;

  const LedgerReport({
    required this.customerId,
    required this.customerName,
    required this.startDate,
    required this.endDate,
    required this.openingBalance,
    required this.transactions,
    required this.closingBalance,
    required this.totalCredit,
    required this.totalDebit,
  });

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        startDate,
        endDate,
        openingBalance,
        transactions,
        closingBalance,
        totalCredit,
        totalDebit,
      ];
}

/// Daybook report showing all transactions for a specific day
class DaybookReport extends Equatable {
  final int date;
  final List<Transaction> transactions;
  final double totalCredit;
  final double totalDebit;
  final double netCashFlow;
  final int transactionCount;

  const DaybookReport({
    required this.date,
    required this.transactions,
    required this.totalCredit,
    required this.totalDebit,
    required this.netCashFlow,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        date,
        transactions,
        totalCredit,
        totalDebit,
        netCashFlow,
        transactionCount,
      ];
}

/// Profit & Loss statement for a period
class ProfitLossReport extends Equatable {
  final int businessId;
  final int startDate;
  final int endDate;
  final double totalRevenue;
  final double totalExpenses;
  final double grossProfit;
  final double netProfit;
  final double profitMargin;
  final Map<String, double> revenueByCategory;
  final Map<String, double> expensesByCategory;

  const ProfitLossReport({
    required this.businessId,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.grossProfit,
    required this.netProfit,
    required this.profitMargin,
    required this.revenueByCategory,
    required this.expensesByCategory,
  });

  /// Check if business is profitable
  bool get isProfitable => netProfit > 0;

  /// Check if business is breaking even
  bool get isBreakingEven => netProfit == 0;

  /// Check if business is in loss
  bool get isInLoss => netProfit < 0;

  @override
  List<Object?> get props => [
        businessId,
        startDate,
        endDate,
        totalRevenue,
        totalExpenses,
        grossProfit,
        netProfit,
        profitMargin,
        revenueByCategory,
        expensesByCategory,
      ];
}

/// Balance Sheet showing assets and liabilities
class BalanceSheetReport extends Equatable {
  final int businessId;
  final int asOfDate;
  final double totalReceivable;
  final double totalPayable;
  final double cashInHand;
  final double inventory Value;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final List<CustomerBalance> receivables;
  final List<CustomerBalance> payables;

  const BalanceSheetReport({
    required this.businessId,
    required this.asOfDate,
    required this.totalReceivable,
    required this.totalPayable,
    required this.cashInHand,
    required this.inventoryValue,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.receivables,
    required this.payables,
  });

  /// Check if business has positive net worth
  bool get hasPositiveNetWorth => netWorth > 0;

  /// Calculate working capital
  double get workingCapital => totalAssets - totalLiabilities;

  @override
  List<Object?> get props => [
        businessId,
        asOfDate,
        totalReceivable,
        totalPayable,
        cashInHand,
        inventoryValue,
        totalAssets,
        totalLiabilities,
        netWorth,
        receivables,
        payables,
      ];
}

/// Customer balance for balance sheet
class CustomerBalance extends Equatable {
  final int customerId;
  final String customerName;
  final double balance;

  const CustomerBalance({
    required this.customerId,
    required this.customerName,
    required this.balance,
  });

  @override
  List<Object?> get props => [customerId, customerName, balance];
}
