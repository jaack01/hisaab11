import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/report.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/local/database/dao/customer_dao.dart';
import '../datasources/local/database/dao/transaction_dao.dart';
import '../datasources/local/database/dao/invoice_dao.dart';
import '../datasources/local/database/dao/invoice_item_dao.dart';
import '../datasources/local/database/dao/item_dao.dart';
import '../datasources/local/database/dao/expense_dao.dart';

/// Implementation of ReportRepository
class ReportRepositoryImpl implements ReportRepository {
  final CustomerDao customerDao;
  final TransactionDao transactionDao;
  final InvoiceDao invoiceDao;
  final InvoiceItemDao invoiceItemDao;
  final ItemDao itemDao;
  final ExpenseDao expenseDao;

  ReportRepositoryImpl({
    required this.customerDao,
    required this.transactionDao,
    required this.invoiceDao,
    required this.invoiceItemDao,
    required this.itemDao,
    required this.expenseDao,
  });

  @override
  Future<Either<Failure, BusinessReport>> generateBusinessReport({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      // Gather all data in parallel
      final results = await Future.wait([
        getTotalRevenue(
          businessId: businessId,
          startDate: startDate,
          endDate: endDate,
        ),
        getTotalExpenses(
          businessId: businessId,
          startDate: startDate,
          endDate: endDate,
        ),
        getTotalReceivable(businessId),
        getTotalPayable(businessId),
        getExpensesByCategory(
          businessId: businessId,
          startDate: startDate,
          endDate: endDate,
        ),
        getTopCustomers(businessId: businessId, limit: 10),
        getTopSellingItems(businessId: businessId, limit: 10),
      ]);

      final revenue = results[0].fold((l) => 0.0, (r) => r as double);
      final expenses = results[1].fold((l) => 0.0, (r) => r as double);
      final receivable = results[2].fold((l) => 0.0, (r) => r as double);
      final payable = results[3].fold((l) => 0.0, (r) => r as double);
      final expenseBreakdown = results[4].fold(
        (l) => <String, double>{},
        (r) => r as Map<String, double>,
      );
      final topCustomers = results[5].fold(
        (l) => <TopCustomer>[],
        (r) => r as List<TopCustomer>,
      );
      final topItems = results[6].fold(
        (l) => <TopItem>[],
        (r) => r as List<TopItem>,
      );

      // Get counts
      final customerCount = await customerDao.getCustomerCount(
        businessId: businessId,
      );
      final transactionCount = await transactionDao.getTransactionCount(
        businessId: businessId,
      );
      final invoiceCount = await invoiceDao.getInvoiceCount(
        businessId: businessId,
      );
      final itemCount = await itemDao.getItemCount(
        businessId: businessId,
      );

      // Get revenue by month (for current year)
      final now = DateTime.now();
      final revenueByMonth = await _getRevenueByMonth(businessId, now.year);

      final report = BusinessReport(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
        totalRevenue: revenue,
        totalExpenses: expenses,
        netProfit: revenue - expenses,
        totalReceivable: receivable,
        totalPayable: payable,
        totalCustomers: customerCount,
        totalTransactions: transactionCount,
        totalInvoices: invoiceCount,
        totalItems: itemCount,
        expensesByCategory: expenseBreakdown,
        revenueByMonth: revenueByMonth,
        topCustomers: topCustomers,
        topSellingItems: topItems,
      );

      return Right(report);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalRevenue({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final total = await invoiceDao.getTotalInvoiceAmount(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpenses({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final total = await expenseDao.getTotalExpenses(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getNetProfit({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final revenue = await invoiceDao.getTotalInvoiceAmount(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      final expenses = await expenseDao.getTotalExpenses(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(revenue - expenses);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalReceivable(int businessId) async {
    try {
      final total = await customerDao.getTotalReceivable(
        businessId: businessId,
      );
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalPayable(int businessId) async {
    try {
      final total = await customerDao.getTotalPayable(
        businessId: businessId,
      );
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final breakdown = await expenseDao.getExpensesByCategoryBreakdown(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(breakdown);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, double>>> getRevenueByMonth({
    required int businessId,
    required int year,
  }) async {
    try {
      final revenueMap = await _getRevenueByMonth(businessId, year);
      return Right(revenueMap);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopCustomer>>> getTopCustomers({
    required int businessId,
    required int limit,
  }) async {
    try {
      final topCustomerMaps = await transactionDao.getTopCustomers(
        businessId: businessId,
        limit: limit,
      );

      final topCustomers = topCustomerMaps.map((map) {
        return TopCustomer(
          customerId: map['customer_id'] as int,
          customerName: map['customer_name'] as String,
          totalAmount: (map['total_amount'] as num).toDouble(),
          transactionCount: map['transaction_count'] as int,
        );
      }).toList();

      return Right(topCustomers);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TopItem>>> getTopSellingItems({
    required int businessId,
    required int limit,
  }) async {
    try {
      final topItemMaps = await invoiceItemDao.getTopSellingItems(
        businessId: businessId,
        limit: limit,
      );

      final topItems = topItemMaps.map((map) {
        return TopItem(
          itemId: map['item_id'] as int? ?? 0,
          itemName: map['item_name'] as String,
          quantitySold: (map['total_quantity'] as num).toDouble(),
          revenue: (map['total_revenue'] as num).toDouble(),
        );
      }).toList();

      return Right(topItems);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary(
    int businessId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      final startTimestamp = startOfMonth.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = endOfMonth.millisecondsSinceEpoch ~/ 1000;

      // Get current month data
      final monthRevenue = await invoiceDao.getTotalInvoiceAmount(
        businessId: businessId,
        startDate: startTimestamp,
        endDate: endTimestamp,
      );

      final monthExpenses = await expenseDao.getTotalExpenses(
        businessId: businessId,
        startDate: startTimestamp,
        endDate: endTimestamp,
      );

      final totalReceivable = await customerDao.getTotalReceivable(
        businessId: businessId,
      );

      final totalPayable = await customerDao.getTotalPayable(
        businessId: businessId,
      );

      final outstandingInvoices = await invoiceDao.getTotalOutstanding(
        businessId: businessId,
      );

      final customerCount = await customerDao.getCustomerCount(
        businessId: businessId,
      );

      final invoiceCount = await invoiceDao.getInvoiceCount(
        businessId: businessId,
      );

      final summary = {
        'monthRevenue': monthRevenue,
        'monthExpenses': monthExpenses,
        'monthProfit': monthRevenue - monthExpenses,
        'totalReceivable': totalReceivable,
        'totalPayable': totalPayable,
        'outstandingInvoices': outstandingInvoices,
        'customerCount': customerCount,
        'invoiceCount': invoiceCount,
        'updatedAt': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      return Right(summary);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Helper method to get revenue by month for a year
  Future<Map<String, double>> _getRevenueByMonth(
    int businessId,
    int year,
  ) async {
    final Map<String, double> revenueByMonth = {};

    for (int month = 1; month <= 12; month++) {
      final firstDay = DateTime(year, month, 1);
      final lastDay = DateTime(year, month + 1, 0);

      final startTimestamp = firstDay.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = lastDay.millisecondsSinceEpoch ~/ 1000;

      final monthRevenue = await invoiceDao.getTotalInvoiceAmount(
        businessId: businessId,
        startDate: startTimestamp,
        endDate: endTimestamp,
      );

      final monthName = _getMonthName(month);
      revenueByMonth[monthName] = monthRevenue;
    }

    return revenueByMonth;
  }

  /// Helper method to get month name
  String _getMonthName(int month) {
    const monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return monthNames[month - 1];
  }
}
