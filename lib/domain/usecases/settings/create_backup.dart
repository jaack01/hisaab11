import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/settings.dart';
import '../../repositories/settings_repository.dart';

/// Use case for creating a database backup
class CreateBackup {
  final SettingsRepository repository;

  CreateBackup(this.repository);

  Future<Either<Failure, BackupMetadata>> call() async {
    return repository.createBackup();
  }
}
