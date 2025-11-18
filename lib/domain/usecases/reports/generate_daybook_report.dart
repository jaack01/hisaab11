import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reports.dart';
import '../../repositories/reports_repository.dart';

/// Use case for generating daybook report
class GenerateDaybookReport {
  final ReportsRepository repository;

  GenerateDaybookReport(this.repository);

  Future<Either<Failure, DaybookReport>> call({
    required int businessId,
    required int date,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.generateDaybookReport(
      businessId: businessId,
      date: date,
    );
  }
}
