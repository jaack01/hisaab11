import 'package:equatable/equatable.dart';

/// Business analytics and report data
class BusinessReport extends Equatable {
  final int businessId;
  final int startDate;
  final int endDate;
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
  final double totalReceivable;
  final double totalPayable;
  final int totalCustomers;
  final int totalTransactions;
  final int totalInvoices;
  final int totalItems;
  final Map<String, double> expensesByCategory;
  final Map<String, double> revenueByMonth;
  final List<TopCustomer> topCustomers;
  final List<TopItem> topSellingItems;

  const BusinessReport({
    required this.businessId,
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
    required this.totalReceivable,
    required this.totalPayable,
    required this.totalCustomers,
    required this.totalTransactions,
    required this.totalInvoices,
    required this.totalItems,
    required this.expensesByCategory,
    required this.revenueByMonth,
    required this.topCustomers,
    required this.topSellingItems,
  });

  /// Calculate profit margin percentage
  double get profitMargin {
    if (totalRevenue == 0) return 0.0;
    return (netProfit / totalRevenue) * 100;
  }

  /// Check if business is profitable
  bool get isProfitable => netProfit > 0;

  @override
  List<Object?> get props => [
        businessId,
        startDate,
        endDate,
        totalRevenue,
        totalExpenses,
        netProfit,
        totalReceivable,
        totalPayable,
        totalCustomers,
        totalTransactions,
        totalInvoices,
        totalItems,
        expensesByCategory,
        revenueByMonth,
        topCustomers,
        topSellingItems,
      ];
}

/// Top customer data for reports
class TopCustomer extends Equatable {
  final int customerId;
  final String customerName;
  final double totalAmount;
  final int transactionCount;

  const TopCustomer({
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.transactionCount,
  });

  @override
  List<Object?> get props => [
        customerId,
        customerName,
        totalAmount,
        transactionCount,
      ];
}

/// Top selling item data for reports
class TopItem extends Equatable {
  final int itemId;
  final String itemName;
  final double quantitySold;
  final double revenue;

  const TopItem({
    required this.itemId,
    required this.itemName,
    required this.quantitySold,
    required this.revenue,
  });

  @override
  List<Object?> get props => [
        itemId,
        itemName,
        quantitySold,
        revenue,
      ];
}
