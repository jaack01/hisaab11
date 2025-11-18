import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/reports.dart';

/// Repository interface for generating various business reports
abstract class ReportsRepository {
  /// Generate ledger report for a customer
  Future<Either<Failure, LedgerReport>> generateLedgerReport({
    required int customerId,
    required int startDate,
    required int endDate,
  });

  /// Generate daybook report for a specific date
  Future<Either<Failure, DaybookReport>> generateDaybookReport({
    required int businessId,
    required int date,
  });

  /// Generate profit & loss report for a period
  Future<Either<Failure, ProfitLossReport>> generateProfitLossReport({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Generate balance sheet as of a date
  Future<Either<Failure, BalanceSheetReport>> generateBalanceSheet({
    required int businessId,
    required int asOfDate,
  });

  /// Get all customers with receivable balances
  Future<Either<Failure, List<CustomerBalance>>> getReceivables(int businessId);

  /// Get all customers with payable balances
  Future<Either<Failure, List<CustomerBalance>>> getPayables(int businessId);
}
