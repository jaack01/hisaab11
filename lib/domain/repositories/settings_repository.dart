import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/settings.dart';

/// Repository for settings management, backup/restore, and data export
abstract class SettingsRepository {
  /// Get current application settings
  Future<Either<Failure, AppSettings>> getSettings();

  /// Update application settings
  Future<Either<Failure, void>> updateSettings(AppSettings settings);

  /// Reset settings to default
  Future<Either<Failure, void>> resetSettings();

  /// Create a backup of the database
  Future<Either<Failure, BackupMetadata>> createBackup();

  /// Restore database from a backup file
  Future<Either<Failure, void>> restoreBackup(String backupFilePath);

  /// Get list of available backups
  Future<Either<Failure, List<BackupMetadata>>> getAvailableBackups();

  /// Delete a backup file
  Future<Either<Failure, void>> deleteBackup(String backupFilePath);

  /// Export data to CSV
  Future<Either<Failure, ExportResult>> exportToCSV({
    required int businessId,
    required String dataType, // 'customers', 'transactions', 'invoices', 'expenses'
    int? startDate,
    int? endDate,
  });

  /// Export data to Excel
  Future<Either<Failure, ExportResult>> exportToExcel({
    required int businessId,
    required String dataType,
    int? startDate,
    int? endDate,
  });

  /// Get business profile settings
  Future<Either<Failure, Map<String, dynamic>>> getBusinessProfile(
    int businessId,
  );

  /// Update business profile settings
  Future<Either<Failure, void>> updateBusinessProfile(
    int businessId,
    Map<String, dynamic> profile,
  );
}
