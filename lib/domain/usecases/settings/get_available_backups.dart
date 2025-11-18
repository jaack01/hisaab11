import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/settings.dart';
import '../../repositories/settings_repository.dart';

/// Use case for getting list of available backups
class GetAvailableBackups {
  final SettingsRepository repository;

  GetAvailableBackups(this.repository);

  Future<Either<Failure, List<BackupMetadata>>> call() async {
    return repository.getAvailableBackups();
  }
}
