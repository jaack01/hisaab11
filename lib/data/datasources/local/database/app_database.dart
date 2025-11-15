import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import 'migrations/migration_v1.dart';

/// Singleton class for managing SQLite database
class AppDatabase {
  // Singleton instance
  static final AppDatabase _instance = AppDatabase._internal();
  static Database? _database;

  // Private constructor
  AppDatabase._internal();

  // Factory constructor returns singleton instance
  factory AppDatabase() => _instance;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    try {
      // Get database path
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConstants.databaseName);

      // Open database
      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onDowngrade: _onDowngrade,
        onOpen: _onOpen,
        onConfigure: _onConfigure,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to initialize database',
        originalException: e,
      );
    }
  }

  /// Configure database (enable foreign keys)
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    try {
      // Execute migration v1 (creates all tables, triggers, views)
      await MigrationV1.execute(db);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to create database tables',
        originalException: e,
      );
    }
  }

  /// Upgrade database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    try {
      // Handle future migrations
      // if (oldVersion < 2 && newVersion >= 2) {
      //   await MigrationV2.execute(db);
      // }
      // Add more migrations as needed
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to upgrade database',
        originalException: e,
      );
    }
  }

  /// Downgrade database (usually not recommended, but handle gracefully)
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // Handle downgrade if needed
    // Usually you should avoid downgrades in production
  }

  /// Called when database is opened
  Future<void> _onOpen(Database db) async {
    // Can perform any initialization here
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Delete database (for testing or reset)
  Future<void> deleteDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, AppConstants.databaseName);
    await deleteDatabase(path);
    _database = null;
  }

  /// Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      throw DatabaseException(
        message: 'Raw query failed',
        originalException: e,
      );
    }
  }

  /// Execute raw update/insert/delete
  Future<int> rawExecute(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    try {
      final db = await database;
      return await db.rawUpdate(sql, arguments);
    } catch (e) {
      throw DatabaseException(
        message: 'Raw execute failed',
        originalException: e,
      );
    }
  }

  /// Begin transaction
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      final db = await database;
      return await db.transaction(action);
    } catch (e) {
      throw DatabaseException(
        message: 'Transaction failed',
        originalException: e,
      );
    }
  }

  /// Get database path
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, AppConstants.databaseName);
  }

  /// Get database size in bytes
  Future<int> getDatabaseSize() async {
    try {
      final path = await getDatabasePath();
      final file = await databaseFactory.openDatabase(path);
      await file.close();
      // Note: Getting actual file size would require dart:io
      // which is not available in this context
      return 0; // Placeholder
    } catch (e) {
      return 0;
    }
  }

  /// Backup database
  Future<String> backup(String backupPath) async {
    try {
      final sourcePath = await getDatabasePath();
      // Note: Actual file copy would require dart:io
      // This is a placeholder for the backup functionality
      return backupPath;
    } catch (e) {
      throw DatabaseException(
        message: 'Backup failed',
        originalException: e,
      );
    }
  }

  /// Restore database from backup
  Future<void> restore(String backupPath) async {
    try {
      await close();
      final targetPath = await getDatabasePath();
      // Note: Actual file restore would require dart:io
      // This is a placeholder for the restore functionality
      _database = await _initDatabase();
    } catch (e) {
      throw DatabaseException(
        message: 'Restore failed',
        originalException: e,
      );
    }
  }

  /// Check if table exists
  Future<bool> tableExists(String tableName) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [tableName],
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get table row count
  Future<int> getTableRowCount(String tableName) async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM $tableName');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Clear all tables (for testing)
  Future<void> clearAllTables() async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        // Delete in correct order to respect foreign keys
        await txn.delete('invoice_items');
        await txn.delete('invoices');
        await txn.delete('payments');
        await txn.delete('transactions');
        await txn.delete('reminders');
        await txn.delete('expenses');
        await txn.delete('items');
        await txn.delete('customers');
        await txn.delete('businesses');
        await txn.delete('settings');
        await txn.delete('backup_log');
        await txn.delete('reports_cache');
      });
    } catch (e) {
      throw DatabaseException(
        message: 'Clear all tables failed',
        originalException: e,
      );
    }
  }
}
