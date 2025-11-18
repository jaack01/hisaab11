import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../../../domain/entities/settings.dart';
import '../../datasources/local/database/dao/customer_dao.dart';
import '../../datasources/local/database/dao/transaction_dao.dart';
import '../../datasources/local/database/dao/invoice_dao.dart';
import '../../datasources/local/database/dao/expense_dao.dart';

/// Utility class for exporting data to CSV and Excel formats
class DataExporter {
  DataExporter._();

  /// Export data to CSV
  static Future<ExportResult> exportToCSV({
    required int businessId,
    required String dataType,
    int? startDate,
    int? endDate,
  }) async {
    final data = await _fetchData(
      businessId: businessId,
      dataType: dataType,
      startDate: startDate,
      endDate: endDate,
    );

    if (data.isEmpty) {
      throw Exception('No data found to export');
    }

    // Generate CSV content
    final csvContent = _generateCSV(data);

    // Save to file
    final exportDir = await _getExportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final fileName = '${dataType}_export_$timestamp.csv';
    final filePath = path.join(exportDir.path, fileName);

    final file = File(filePath);
    await file.writeAsString(csvContent);

    final fileSize = await file.length();

    return ExportResult(
      filePath: filePath,
      format: 'csv',
      recordCount: data.length - 1, // Subtract header row
      fileSize: fileSize / (1024 * 1024), // Convert to MB
      timestamp: timestamp,
    );
  }

  /// Export data to Excel (simplified - using CSV format)
  /// For full Excel support, consider using the excel package
  static Future<ExportResult> exportToExcel({
    required int businessId,
    required String dataType,
    int? startDate,
    int? endDate,
  }) async {
    // For now, we'll use CSV format with .xlsx extension
    // In a production app, you would use the 'excel' package for true Excel files
    final data = await _fetchData(
      businessId: businessId,
      dataType: dataType,
      startDate: startDate,
      endDate: endDate,
    );

    if (data.isEmpty) {
      throw Exception('No data found to export');
    }

    final csvContent = _generateCSV(data);

    final exportDir = await _getExportDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final fileName = '${dataType}_export_$timestamp.csv'; // Using .csv for simplicity
    final filePath = path.join(exportDir.path, fileName);

    final file = File(filePath);
    await file.writeAsString(csvContent);

    final fileSize = await file.length();

    return ExportResult(
      filePath: filePath,
      format: 'excel',
      recordCount: data.length - 1,
      fileSize: fileSize / (1024 * 1024),
      timestamp: timestamp,
    );
  }

  /// Fetch data based on type
  static Future<List<Map<String, dynamic>>> _fetchData({
    required int businessId,
    required String dataType,
    int? startDate,
    int? endDate,
  }) async {
    switch (dataType) {
      case 'customers':
        return _fetchCustomers(businessId);
      case 'transactions':
        return _fetchTransactions(businessId, startDate, endDate);
      case 'invoices':
        return _fetchInvoices(businessId, startDate, endDate);
      case 'expenses':
        return _fetchExpenses(businessId, startDate, endDate);
      default:
        throw Exception('Invalid data type');
    }
  }

  /// Fetch customers data
  static Future<List<Map<String, dynamic>>> _fetchCustomers(
    int businessId,
  ) async {
    final dao = CustomerDao();
    final customers = await dao.getByBusinessId(businessId);

    final data = <Map<String, dynamic>>[];

    // Add header row
    data.add({
      'ID': 'ID',
      'Name': 'Name',
      'Phone': 'Phone',
      'Email': 'Email',
      'Address': 'Address',
      'Balance': 'Current Balance',
      'Created': 'Created Date',
    });

    // Add customer rows
    for (final customer in customers) {
      data.add({
        'ID': customer.id.toString(),
        'Name': customer.name,
        'Phone': customer.phone ?? '',
        'Email': customer.email ?? '',
        'Address': customer.address ?? '',
        'Balance': customer.currentBalance.toString(),
        'Created': _formatTimestamp(customer.createdAt),
      });
    }

    return data;
  }

  /// Fetch transactions data
  static Future<List<Map<String, dynamic>>> _fetchTransactions(
    int businessId,
    int? startDate,
    int? endDate,
  ) async {
    final dao = TransactionDao();
    final transactions = await dao.getByBusinessId(businessId);

    // Filter by date if provided
    final filteredTransactions = transactions.where((txn) {
      if (startDate != null && txn.transactionDate < startDate) return false;
      if (endDate != null && txn.transactionDate > endDate) return false;
      return true;
    }).toList();

    final data = <Map<String, dynamic>>[];

    // Add header row
    data.add({
      'ID': 'ID',
      'Date': 'Transaction Date',
      'Customer': 'Customer ID',
      'Type': 'Type',
      'Amount': 'Amount',
      'Description': 'Description',
      'Created': 'Created Date',
    });

    // Add transaction rows
    for (final txn in filteredTransactions) {
      data.add({
        'ID': txn.id.toString(),
        'Date': _formatTimestamp(txn.transactionDate),
        'Customer': txn.customerId.toString(),
        'Type': txn.transactionType,
        'Amount': txn.amount.toString(),
        'Description': txn.description ?? '',
        'Created': _formatTimestamp(txn.createdAt),
      });
    }

    return data;
  }

  /// Fetch invoices data
  static Future<List<Map<String, dynamic>>> _fetchInvoices(
    int businessId,
    int? startDate,
    int? endDate,
  ) async {
    final dao = InvoiceDao();
    final invoices = await dao.getByBusinessId(businessId);

    // Filter by date if provided
    final filteredInvoices = invoices.where((invoice) {
      if (startDate != null && invoice.invoiceDate < startDate) return false;
      if (endDate != null && invoice.invoiceDate > endDate) return false;
      return true;
    }).toList();

    final data = <Map<String, dynamic>>[];

    // Add header row
    data.add({
      'ID': 'ID',
      'Number': 'Invoice Number',
      'Date': 'Invoice Date',
      'Customer': 'Customer ID',
      'Total': 'Total Amount',
      'Paid': 'Paid Amount',
      'Status': 'Payment Status',
      'Created': 'Created Date',
    });

    // Add invoice rows
    for (final invoice in filteredInvoices) {
      data.add({
        'ID': invoice.id.toString(),
        'Number': invoice.invoiceNumber,
        'Date': _formatTimestamp(invoice.invoiceDate),
        'Customer': invoice.customerId.toString(),
        'Total': invoice.totalAmount.toString(),
        'Paid': invoice.paidAmount.toString(),
        'Status': invoice.paymentStatus,
        'Created': _formatTimestamp(invoice.createdAt),
      });
    }

    return data;
  }

  /// Fetch expenses data
  static Future<List<Map<String, dynamic>>> _fetchExpenses(
    int businessId,
    int? startDate,
    int? endDate,
  ) async {
    final dao = ExpenseDao();
    final expenses = await dao.getByBusinessId(businessId);

    // Filter by date if provided
    final filteredExpenses = expenses.where((expense) {
      if (startDate != null && expense.expenseDate < startDate) return false;
      if (endDate != null && expense.expenseDate > endDate) return false;
      return true;
    }).toList();

    final data = <Map<String, dynamic>>[];

    // Add header row
    data.add({
      'ID': 'ID',
      'Date': 'Expense Date',
      'Category': 'Category',
      'Amount': 'Amount',
      'Description': 'Description',
      'PaymentMethod': 'Payment Method',
      'Created': 'Created Date',
    });

    // Add expense rows
    for (final expense in filteredExpenses) {
      data.add({
        'ID': expense.id.toString(),
        'Date': _formatTimestamp(expense.expenseDate),
        'Category': expense.category,
        'Amount': expense.amount.toString(),
        'Description': expense.description ?? '',
        'PaymentMethod': expense.paymentMethod ?? '',
        'Created': _formatTimestamp(expense.createdAt),
      });
    }

    return data;
  }

  /// Generate CSV content from data
  static String _generateCSV(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';

    final buffer = StringBuffer();

    // Get headers from first row
    final headers = data[0].keys.toList();

    // Write all rows
    for (final row in data) {
      final values = headers.map((header) {
        final value = row[header]?.toString() ?? '';
        // Escape commas and quotes in CSV
        if (value.contains(',') || value.contains('"') || value.contains('\n')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }).join(',');

      buffer.writeln(values);
    }

    return buffer.toString();
  }

  /// Get export directory
  static Future<Directory> _getExportDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(path.join(documentsDir.path, 'exports'));

    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    return exportDir;
  }

  /// Format timestamp to readable date
  static String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }
}
