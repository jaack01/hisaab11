import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/report_repository.dart';

/// Use case for getting dashboard summary
class GetDashboardSummary {
  final ReportRepository repository;

  GetDashboardSummary(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getDashboardSummary(businessId);
  }
}
