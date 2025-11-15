import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/report.dart';
import '../../repositories/report_repository.dart';

/// Use case for generating business report
class GenerateBusinessReport {
  final ReportRepository repository;

  GenerateBusinessReport(this.repository);

  Future<Either<Failure, BusinessReport>> call({
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

    return repository.generateBusinessReport(
      businessId: businessId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
