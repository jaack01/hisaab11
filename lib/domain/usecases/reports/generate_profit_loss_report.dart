import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reports.dart';
import '../../repositories/reports_repository.dart';

/// Use case for generating profit & loss report
class GenerateProfitLossReport {
  final ReportsRepository repository;

  GenerateProfitLossReport(this.repository);

  Future<Either<Failure, ProfitLossReport>> call({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    if (startDate > endDate) {
      return Left(ValidationFailure(
        message: 'Start date cannot be after end date',
      ));
    }

    return repository.generateProfitLossReport(
      businessId: businessId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
