import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/settings.dart';
import '../../repositories/settings_repository.dart';

/// Use case for getting application settings
class GetSettings {
  final SettingsRepository repository;

  GetSettings(this.repository);

  Future<Either<Failure, AppSettings>> call() async {
    return repository.getSettings();
  }
}
