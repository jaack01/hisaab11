import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/reports.dart';
import '../../repositories/reports_repository.dart';

/// Use case for generating balance sheet
class GenerateBalanceSheet {
  final ReportsRepository repository;

  GenerateBalanceSheet(this.repository);

  Future<Either<Failure, BalanceSheetReport>> call({
    required int businessId,
    required int asOfDate,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.generateBalanceSheet(
      businessId: businessId,
      asOfDate: asOfDate,
    );
  }
}
