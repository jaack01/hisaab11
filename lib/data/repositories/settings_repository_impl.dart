import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../../core/utils/backup/database_backup.dart';
import '../../core/utils/export/data_exporter.dart';
import '../../domain/entities/settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local/database/dao/customer_dao.dart';

/// Implementation of SettingsRepository using SharedPreferences
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _keyLanguage = 'settings_language';
  static const String _keyTheme = 'settings_theme';
  static const String _keyDateFormat = 'settings_date_format';
  static const String _keyCurrencyFormat = 'settings_currency_format';
  static const String _keyAutoBackupEnabled = 'settings_auto_backup_enabled';
  static const String _keyAutoBackupInterval = 'settings_auto_backup_interval';
  static const String _keyLastBackupPath = 'settings_last_backup_path';
  static const String _keyLastBackupTimestamp = 'settings_last_backup_timestamp';

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final settings = AppSettings(
        language: prefs.getString(_keyLanguage) ?? 'en',
        theme: prefs.getString(_keyTheme) ?? 'system',
        dateFormat: prefs.getString(_keyDateFormat) ?? 'dd/MM/yyyy',
        currencyFormat: prefs.getString(_keyCurrencyFormat) ?? 'INR',
        autoBackupEnabled: prefs.getBool(_keyAutoBackupEnabled) ?? false,
        autoBackupIntervalDays: prefs.getInt(_keyAutoBackupInterval) ?? 7,
        lastBackupPath: prefs.getString(_keyLastBackupPath),
        lastBackupTimestamp: prefs.getInt(_keyLastBackupTimestamp),
      );

      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_keyLanguage, settings.language);
      await prefs.setString(_keyTheme, settings.theme);
      await prefs.setString(_keyDateFormat, settings.dateFormat);
      await prefs.setString(_keyCurrencyFormat, settings.currencyFormat);
      await prefs.setBool(_keyAutoBackupEnabled, settings.autoBackupEnabled);
      await prefs.setInt(_keyAutoBackupInterval, settings.autoBackupIntervalDays);

      if (settings.lastBackupPath != null) {
        await prefs.setString(_keyLastBackupPath, settings.lastBackupPath!);
      }

      if (settings.lastBackupTimestamp != null) {
        await prefs.setInt(_keyLastBackupTimestamp, settings.lastBackupTimestamp!);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_keyLanguage);
      await prefs.remove(_keyTheme);
      await prefs.remove(_keyDateFormat);
      await prefs.remove(_keyCurrencyFormat);
      await prefs.remove(_keyAutoBackupEnabled);
      await prefs.remove(_keyAutoBackupInterval);
      await prefs.remove(_keyLastBackupPath);
      await prefs.remove(_keyLastBackupTimestamp);

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BackupMetadata>> createBackup() async {
    try {
      final metadata = await DatabaseBackup.createBackup();

      // Update last backup info in settings
      final settingsResult = await getSettings();
      settingsResult.fold(
        (l) => null,
        (settings) async {
          final updatedSettings = settings.copyWith(
            lastBackupPath: metadata.filePath,
            lastBackupTimestamp: metadata.timestamp,
          );
          await updateSettings(updatedSettings);
        },
      );

      return Right(metadata);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to create backup: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> restoreBackup(String backupFilePath) async {
    try {
      await DatabaseBackup.restoreBackup(backupFilePath);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to restore backup: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<BackupMetadata>>> getAvailableBackups() async {
    try {
      final backups = await DatabaseBackup.getAvailableBackups();
      return Right(backups);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to get backups: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBackup(String backupFilePath) async {
    try {
      await DatabaseBackup.deleteBackup(backupFilePath);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to delete backup: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExportResult>> exportToCSV({
    required int businessId,
    required String dataType,
    int? startDate,
    int? endDate,
  }) async {
    try {
      final result = await DataExporter.exportToCSV(
        businessId: businessId,
        dataType: dataType,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to export to CSV: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExportResult>> exportToExcel({
    required int businessId,
    required String dataType,
    int? startDate,
    int? endDate,
  }) async {
    try {
      final result = await DataExporter.exportToExcel(
        businessId: businessId,
        dataType: dataType,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } catch (e) {
      return Left(DatabaseFailure(message: 'Failed to export to Excel: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBusinessProfile(
    int businessId,
  ) async {
    try {
      // Get business details from customer DAO
      // In a real app, you would have a separate Business table
      // For now, we'll use SharedPreferences to store business profile
      final prefs = await SharedPreferences.getInstance();
      final keyPrefix = 'business_${businessId}_';

      final profile = {
        'name': prefs.getString('${keyPrefix}name') ?? '',
        'address': prefs.getString('${keyPrefix}address') ?? '',
        'phone': prefs.getString('${keyPrefix}phone') ?? '',
        'email': prefs.getString('${keyPrefix}email') ?? '',
        'gst': prefs.getString('${keyPrefix}gst') ?? '',
        'logo': prefs.getString('${keyPrefix}logo') ?? '',
      };

      return Right(profile);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBusinessProfile(
    int businessId,
    Map<String, dynamic> profile,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keyPrefix = 'business_${businessId}_';

      if (profile.containsKey('name')) {
        await prefs.setString('${keyPrefix}name', profile['name'] as String);
      }
      if (profile.containsKey('address')) {
        await prefs.setString('${keyPrefix}address', profile['address'] as String);
      }
      if (profile.containsKey('phone')) {
        await prefs.setString('${keyPrefix}phone', profile['phone'] as String);
      }
      if (profile.containsKey('email')) {
        await prefs.setString('${keyPrefix}email', profile['email'] as String);
      }
      if (profile.containsKey('gst')) {
        await prefs.setString('${keyPrefix}gst', profile['gst'] as String);
      }
      if (profile.containsKey('logo')) {
        await prefs.setString('${keyPrefix}logo', profile['logo'] as String);
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
