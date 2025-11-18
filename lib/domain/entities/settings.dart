import 'package:equatable/equatable.dart';

/// Application settings entity
class AppSettings extends Equatable {
  final String language; // 'en' or 'hi'
  final String theme; // 'light', 'dark', or 'system'
  final String dateFormat; // 'dd/MM/yyyy', 'MM/dd/yyyy', 'yyyy-MM-dd'
  final String currencyFormat; // 'INR', 'USD', etc.
  final bool autoBackupEnabled;
  final int autoBackupIntervalDays; // 1, 7, 30
  final String? lastBackupPath;
  final int? lastBackupTimestamp;

  const AppSettings({
    this.language = 'en',
    this.theme = 'system',
    this.dateFormat = 'dd/MM/yyyy',
    this.currencyFormat = 'INR',
    this.autoBackupEnabled = false,
    this.autoBackupIntervalDays = 7,
    this.lastBackupPath,
    this.lastBackupTimestamp,
  });

  /// Check if backup is needed based on auto-backup settings
  bool get needsBackup {
    if (!autoBackupEnabled) return false;
    if (lastBackupTimestamp == null) return true;

    final lastBackupDate = DateTime.fromMillisecondsSinceEpoch(
      lastBackupTimestamp! * 1000,
    );
    final daysSinceBackup = DateTime.now().difference(lastBackupDate).inDays;

    return daysSinceBackup >= autoBackupIntervalDays;
  }

  /// Copy with method for updating settings
  AppSettings copyWith({
    String? language,
    String? theme,
    String? dateFormat,
    String? currencyFormat,
    bool? autoBackupEnabled,
    int? autoBackupIntervalDays,
    String? lastBackupPath,
    int? lastBackupTimestamp,
  }) {
    return AppSettings(
      language: language ?? this.language,
      theme: theme ?? this.theme,
      dateFormat: dateFormat ?? this.dateFormat,
      currencyFormat: currencyFormat ?? this.currencyFormat,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      autoBackupIntervalDays:
          autoBackupIntervalDays ?? this.autoBackupIntervalDays,
      lastBackupPath: lastBackupPath ?? this.lastBackupPath,
      lastBackupTimestamp: lastBackupTimestamp ?? this.lastBackupTimestamp,
    );
  }

  @override
  List<Object?> get props => [
        language,
        theme,
        dateFormat,
        currencyFormat,
        autoBackupEnabled,
        autoBackupIntervalDays,
        lastBackupPath,
        lastBackupTimestamp,
      ];
}

/// Backup metadata entity
class BackupMetadata extends Equatable {
  final String fileName;
  final String filePath;
  final int timestamp;
  final int databaseVersion;
  final int customerCount;
  final int transactionCount;
  final int invoiceCount;
  final double fileSize; // in MB

  const BackupMetadata({
    required this.fileName,
    required this.filePath,
    required this.timestamp,
    required this.databaseVersion,
    required this.customerCount,
    required this.transactionCount,
    required this.invoiceCount,
    required this.fileSize,
  });

  /// Get formatted date
  String get formattedDate {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  /// Get formatted file size
  String get formattedSize {
    if (fileSize < 1) {
      return '${(fileSize * 1024).toStringAsFixed(2)} KB';
    }
    return '${fileSize.toStringAsFixed(2)} MB';
  }

  @override
  List<Object?> get props => [
        fileName,
        filePath,
        timestamp,
        databaseVersion,
        customerCount,
        transactionCount,
        invoiceCount,
        fileSize,
      ];
}

/// Export result entity
class ExportResult extends Equatable {
  final String filePath;
  final String format; // 'csv' or 'excel'
  final int recordCount;
  final double fileSize; // in MB
  final int timestamp;

  const ExportResult({
    required this.filePath,
    required this.format,
    required this.recordCount,
    required this.fileSize,
    required this.timestamp,
  });

  /// Get formatted file size
  String get formattedSize {
    if (fileSize < 1) {
      return '${(fileSize * 1024).toStringAsFixed(2)} KB';
    }
    return '${fileSize.toStringAsFixed(2)} MB';
  }

  @override
  List<Object?> get props => [
        filePath,
        format,
        recordCount,
        fileSize,
        timestamp,
      ];
}
