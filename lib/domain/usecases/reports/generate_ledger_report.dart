import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reports.dart';
import '../../repositories/reports_repository.dart';

/// Use case for generating customer ledger report
class GenerateLedgerReport {
  final ReportsRepository repository;

  GenerateLedgerReport(this.repository);

  Future<Either<Failure, LedgerReport>> call({
    required int customerId,
    required int startDate,
    required int endDate,
  }) async {
    if (customerId <= 0) {
      return Left(ValidationFailure(message: 'Invalid customer ID'));
    }

    if (startDate > endDate) {
      return Left(ValidationFailure(
        message: 'Start date cannot be after end date',
      ));
    }

    return repository.generateLedgerReport(
      customerId: customerId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
