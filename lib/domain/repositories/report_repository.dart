import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/report.dart';

/// Repository interface for business reports and analytics
abstract class ReportRepository {
  /// Generate business report for a date range
  Future<Either<Failure, BusinessReport>> generateBusinessReport({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get total revenue for a period
  Future<Either<Failure, double>> getTotalRevenue({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get total expenses for a period
  Future<Either<Failure, double>> getTotalExpenses({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get net profit for a period
  Future<Either<Failure, double>> getNetProfit({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get total receivable amount
  Future<Either<Failure, double>> getTotalReceivable(int businessId);

  /// Get total payable amount
  Future<Either<Failure, double>> getTotalPayable(int businessId);

  /// Get expenses breakdown by category
  Future<Either<Failure, Map<String, double>>> getExpensesByCategory({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get revenue breakdown by month
  Future<Either<Failure, Map<String, double>>> getRevenueByMonth({
    required int businessId,
    required int year,
  });

  /// Get top customers by transaction value
  Future<Either<Failure, List<TopCustomer>>> getTopCustomers({
    required int businessId,
    required int limit,
  });

  /// Get top selling items
  Future<Either<Failure, List<TopItem>>> getTopSellingItems({
    required int businessId,
    required int limit,
  });

  /// Get dashboard summary
  Future<Either<Failure, Map<String, dynamic>>> getDashboardSummary(
    int businessId,
  );
}
