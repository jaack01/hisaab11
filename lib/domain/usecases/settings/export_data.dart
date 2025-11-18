import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/settings.dart';
import '../../repositories/settings_repository.dart';

/// Use case for exporting data to CSV or Excel
class ExportData {
  final SettingsRepository repository;

  ExportData(this.repository);

  Future<Either<Failure, ExportResult>> call({
    required int businessId,
    required String dataType,
    required String format, // 'csv' or 'excel'
    int? startDate,
    int? endDate,
  }) async {
    // Validate business ID
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    // Validate data type
    if (!_isValidDataType(dataType)) {
      return Left(
        ValidationFailure(
          message: 'Invalid data type. Must be: customers, transactions, invoices, or expenses',
        ),
      );
    }

    // Validate format
    if (!['csv', 'excel'].contains(format)) {
      return Left(
        ValidationFailure(message: 'Invalid format. Must be csv or excel'),
      );
    }

    // Validate date range if provided
    if (startDate != null && endDate != null && startDate > endDate) {
      return Left(
        ValidationFailure(message: 'Start date cannot be after end date'),
      );
    }

    // Export based on format
    if (format == 'csv') {
      return repository.exportToCSV(
        businessId: businessId,
        dataType: dataType,
        startDate: startDate,
        endDate: endDate,
      );
    } else {
      return repository.exportToExcel(
        businessId: businessId,
        dataType: dataType,
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  bool _isValidDataType(String dataType) {
    return [
      'customers',
      'transactions',
      'invoices',
      'expenses',
    ].contains(dataType);
  }
}
