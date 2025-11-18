import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/settings_repository.dart';

/// Use case for updating business profile settings
class UpdateBusinessProfile {
  final SettingsRepository repository;

  UpdateBusinessProfile(this.repository);

  Future<Either<Failure, void>> call(
    int businessId,
    Map<String, dynamic> profile,
  ) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    if (profile.isEmpty) {
      return Left(ValidationFailure(message: 'Profile data cannot be empty'));
    }

    return repository.updateBusinessProfile(businessId, profile);
  }
}
