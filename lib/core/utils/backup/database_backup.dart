import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/settings.dart';
import '../../datasources/local/database/database_helper.dart';

/// Utility class for database backup and restore operations
class DatabaseBackup {
  DatabaseBackup._();

  /// Create a backup of the database
  static Future<BackupMetadata> createBackup() async {
    // Get the database path
    final dbPath = await DatabaseHelper.getDatabasePath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception('Database file not found');
    }

    // Get backup directory
    final backupDir = await _getBackupDirectory();

    // Generate backup filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final fileName = 'hisaab_backup_$timestamp.db';
    final backupPath = path.join(backupDir.path, fileName);

    // Copy database file to backup location
    final backupFile = await dbFile.copy(backupPath);

    // Get database statistics
    final stats = await _getDatabaseStats();
    final fileSize = await backupFile.length();

    return BackupMetadata(
      fileName: fileName,
      filePath: backupPath,
      timestamp: timestamp,
      databaseVersion: stats['version'] as int,
      customerCount: stats['customerCount'] as int,
      transactionCount: stats['transactionCount'] as int,
      invoiceCount: stats['invoiceCount'] as int,
      fileSize: fileSize / (1024 * 1024), // Convert to MB
    );
  }

  /// Restore database from backup
  static Future<void> restoreBackup(String backupFilePath) async {
    final backupFile = File(backupFilePath);

    if (!await backupFile.exists()) {
      throw Exception('Backup file not found');
    }

    // Get current database path
    final dbPath = await DatabaseHelper.getDatabasePath();

    // Close the database connection before restoring
    await DatabaseHelper.close();

    // Delete current database
    final dbFile = File(dbPath);
    if (await dbFile.exists()) {
      await dbFile.delete();
    }

    // Copy backup to database location
    await backupFile.copy(dbPath);

    // Reinitialize database
    await DatabaseHelper.database;
  }

  /// Get list of available backups
  static Future<List<BackupMetadata>> getAvailableBackups() async {
    final backupDir = await _getBackupDirectory();

    if (!await backupDir.exists()) {
      return [];
    }

    final backups = <BackupMetadata>[];

    // List all .db files in backup directory
    await for (final entity in backupDir.list()) {
      if (entity is File && entity.path.endsWith('.db')) {
        try {
          final fileName = path.basename(entity.path);
          final fileSize = await entity.length();

          // Extract timestamp from filename (format: hisaab_backup_TIMESTAMP.db)
          final timestampStr = fileName
              .replaceAll('hisaab_backup_', '')
              .replaceAll('.db', '');
          final timestamp = int.tryParse(timestampStr) ??
              (await entity.lastModified()).millisecondsSinceEpoch ~/ 1000;

          // Get backup stats (if possible)
          Map<String, dynamic> stats = {
            'version': 1,
            'customerCount': 0,
            'transactionCount': 0,
            'invoiceCount': 0,
          };

          backups.add(BackupMetadata(
            fileName: fileName,
            filePath: entity.path,
            timestamp: timestamp,
            databaseVersion: stats['version'] as int,
            customerCount: stats['customerCount'] as int,
            transactionCount: stats['transactionCount'] as int,
            invoiceCount: stats['invoiceCount'] as int,
            fileSize: fileSize / (1024 * 1024), // Convert to MB
          ));
        } catch (e) {
          // Skip invalid backup files
          continue;
        }
      }
    }

    // Sort by timestamp descending (newest first)
    backups.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return backups;
  }

  /// Delete a backup file
  static Future<void> deleteBackup(String backupFilePath) async {
    final file = File(backupFilePath);

    if (await file.exists()) {
      await file.delete();
    }
  }

  /// Get backup directory
  static Future<Directory> _getBackupDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(documentsDir.path, 'backups'));

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    return backupDir;
  }

  /// Get database statistics
  static Future<Map<String, dynamic>> _getDatabaseStats() async {
    final db = await DatabaseHelper.database;

    // Get counts from various tables
    final customerCount = await db.rawQuery('SELECT COUNT(*) as count FROM customers WHERE is_deleted = 0');
    final transactionCount = await db.rawQuery('SELECT COUNT(*) as count FROM transactions WHERE is_deleted = 0');
    final invoiceCount = await db.rawQuery('SELECT COUNT(*) as count FROM invoices WHERE is_deleted = 0');

    // Get database version
    final version = await db.getVersion();

    return {
      'version': version,
      'customerCount': customerCount[0]['count'] as int,
      'transactionCount': transactionCount[0]['count'] as int,
      'invoiceCount': invoiceCount[0]['count'] as int,
    };
  }
}
