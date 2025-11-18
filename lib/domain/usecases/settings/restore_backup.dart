import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/settings_repository.dart';

/// Use case for restoring database from backup
class RestoreBackup {
  final SettingsRepository repository;

  RestoreBackup(this.repository);

  Future<Either<Failure, void>> call(String backupFilePath) async {
    // Validate backup file exists
    final file = File(backupFilePath);
    if (!await file.exists()) {
      return Left(
        ValidationFailure(message: 'Backup file not found'),
      );
    }

    // Validate file extension
    if (!backupFilePath.endsWith('.db')) {
      return Left(
        ValidationFailure(message: 'Invalid backup file format'),
      );
    }

    return repository.restoreBackup(backupFilePath);
  }
}
