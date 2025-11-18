import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/reports.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/local/database/dao/customer_dao.dart';
import '../datasources/local/database/dao/transaction_dao.dart';
import '../datasources/local/database/dao/invoice_dao.dart';
import '../datasources/local/database/dao/expense_dao.dart';
import '../datasources/local/database/dao/item_dao.dart';

/// Implementation of ReportsRepository
class ReportsRepositoryImpl implements ReportsRepository {
  final CustomerDao customerDao;
  final TransactionDao transactionDao;
  final InvoiceDao invoiceDao;
  final ExpenseDao expenseDao;
  final ItemDao itemDao;

  ReportsRepositoryImpl({
    required this.customerDao,
    required this.transactionDao,
    required this.invoiceDao,
    required this.expenseDao,
    required this.itemDao,
  });

  @override
  Future<Either<Failure, LedgerReport>> generateLedgerReport({
    required int customerId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      // Get customer details
      final customerModel = await customerDao.getById(customerId);
      if (customerModel == null) {
        return Left(NotFoundFailure(message: 'Customer not found'));
      }

      // Get transactions for the period
      final transactionModels = await transactionDao.getTransactionsByDateRange(
        customerId: customerId,
        startDate: startDate,
        endDate: endDate,
      );

      final transactions = transactionModels
          .map((model) => model.toEntity())
          .toList();

      // Calculate opening balance (balance before start date)
      final openingBalance = await _calculateOpeningBalance(
        customerId: customerId,
        beforeDate: startDate,
      );

      // Calculate totals
      double totalCredit = 0.0;
      double totalDebit = 0.0;

      for (final txn in transactions) {
        if (txn.transactionType == 'CREDIT') {
          totalCredit += txn.amount;
        } else {
          totalDebit += txn.amount;
        }
      }

      // Closing balance = opening + credit - debit
      final closingBalance = openingBalance + totalCredit - totalDebit;

      final report = LedgerReport(
        customerId: customerId,
        customerName: customerModel.name,
        startDate: startDate,
        endDate: endDate,
        openingBalance: openingBalance,
        transactions: transactions,
        closingBalance: closingBalance,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
      );

      return Right(report);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, DaybookReport>> generateDaybookReport({
    required int businessId,
    required int date,
  }) async {
    try {
      // Calculate start and end of day
      final dayStart = DateTime.fromMillisecondsSinceEpoch(date * 1000);
      final dayEnd = DateTime(dayStart.year, dayStart.month, dayStart.day, 23, 59, 59);

      final startTimestamp = dayStart.millisecondsSinceEpoch ~/ 1000;
      final endTimestamp = dayEnd.millisecondsSinceEpoch ~/ 1000;

      // Get all transactions for the day
      final transactionModels = await transactionDao.getTransactionsByBusinessAndDateRange(
        businessId: businessId,
        startDate: startTimestamp,
        endDate: endTimestamp,
      );

      final transactions = transactionModels
          .map((model) => model.toEntity())
          .toList();

      // Calculate totals
      double totalCredit = 0.0;
      double totalDebit = 0.0;

      for (final txn in transactions) {
        if (txn.transactionType == 'CREDIT') {
          totalCredit += txn.amount;
        } else {
          totalDebit += txn.amount;
        }
      }

      final netCashFlow = totalDebit - totalCredit;

      final report = DaybookReport(
        date: date,
        transactions: transactions,
        totalCredit: totalCredit,
        totalDebit: totalDebit,
        netCashFlow: netCashFlow,
        transactionCount: transactions.length,
      );

      return Right(report);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfitLossReport>> generateProfitLossReport({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      // Get total revenue from invoices
      final totalRevenue = await invoiceDao.getTotalInvoiceAmount(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );

      // Get total expenses
      final totalExpenses = await expenseDao.getTotalExpenses(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );

      // Calculate profit metrics
      final grossProfit = totalRevenue;
      final netProfit = totalRevenue - totalExpenses;
      final profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0.0;

      // Get revenue breakdown (from invoices, we'll use a simple total)
      final revenueByCategory = <String, double>{
        'Sales': totalRevenue,
      };

      // Get expenses breakdown by category
      final expensesByCategory = await expenseDao.getExpensesByCategoryBreakdown(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );

      final report = ProfitLossReport(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
        totalRevenue: totalRevenue,
        totalExpenses: totalExpenses,
        grossProfit: grossProfit,
        netProfit: netProfit,
        profitMargin: profitMargin,
        revenueByCategory: revenueByCategory,
        expensesByCategory: expensesByCategory,
      );

      return Right(report);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BalanceSheetReport>> generateBalanceSheet({
    required int businessId,
    required int asOfDate,
  }) async {
    try {
      // Get receivables and payables
      final receivablesList = await getReceivables(businessId);
      final payablesList = await getPayables(businessId);

      final receivables = receivablesList.fold(
        (l) => <CustomerBalance>[],
        (r) => r,
      );

      final payables = payablesList.fold(
        (l) => <CustomerBalance>[],
        (r) => r,
      );

      // Calculate totals
      final totalReceivable = await customerDao.getTotalReceivable(
        businessId: businessId,
      );

      final totalPayable = await customerDao.getTotalPayable(
        businessId: businessId,
      );

      // Get inventory value
      final inventoryValue = await itemDao.getTotalStockValue(
        businessId: businessId,
      );

      // Cash in hand (simplified - can be enhanced)
      final cashInHand = 0.0; // TODO: Implement cash tracking

      // Calculate totals
      final totalAssets = totalReceivable + inventoryValue + cashInHand;
      final totalLiabilities = totalPayable;
      final netWorth = totalAssets - totalLiabilities;

      final report = BalanceSheetReport(
        businessId: businessId,
        asOfDate: asOfDate,
        totalReceivable: totalReceivable,
        totalPayable: totalPayable,
        cashInHand: cashInHand,
        inventoryValue: inventoryValue,
        totalAssets: totalAssets,
        totalLiabilities: totalLiabilities,
        netWorth: netWorth,
        receivables: receivables,
        payables: payables,
      );

      return Right(report);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerBalance>>> getReceivables(
    int businessId,
  ) async {
    try {
      final customers = await customerDao.getCustomersWithReceivables(
        businessId: businessId,
      );

      final balances = customers.map((customer) {
        return CustomerBalance(
          customerId: customer.id!,
          customerName: customer.name,
          balance: customer.currentBalance,
        );
      }).toList();

      return Right(balances);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerBalance>>> getPayables(
    int businessId,
  ) async {
    try {
      final customers = await customerDao.getCustomersWithPayables(
        businessId: businessId,
      );

      final balances = customers.map((customer) {
        return CustomerBalance(
          customerId: customer.id!,
          customerName: customer.name,
          balance: customer.currentBalance.abs(),
        );
      }).toList();

      return Right(balances);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  /// Calculate opening balance for a customer before a specific date
  Future<double> _calculateOpeningBalance({
    required int customerId,
    required int beforeDate,
  }) async {
    final transactions = await transactionDao.getTransactionsBeforeDate(
      customerId: customerId,
      beforeDate: beforeDate,
    );

    double balance = 0.0;
    for (final txn in transactions) {
      if (txn.transactionType == 'CREDIT') {
        balance += txn.amount;
      } else {
        balance -= txn.amount;
      }
    }

    return balance;
  }
}
