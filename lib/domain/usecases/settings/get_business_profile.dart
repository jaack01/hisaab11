import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/settings_repository.dart';

/// Use case for getting business profile settings
class GetBusinessProfile {
  final SettingsRepository repository;

  GetBusinessProfile(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getBusinessProfile(businessId);
  }
}
