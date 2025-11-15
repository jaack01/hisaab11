import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/invoice.dart';
import '../entities/invoice_item.dart';

/// Repository interface for invoice management
abstract class InvoiceRepository {
  /// Create a new invoice with items
  Future<Either<Failure, Invoice>> createInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
  });

  /// Get all invoices for a business
  Future<Either<Failure, List<Invoice>>> getInvoices(int businessId);

  /// Get invoice by ID
  Future<Either<Failure, Invoice>> getInvoiceById(int id);

  /// Get invoice items for an invoice
  Future<Either<Failure, List<InvoiceItem>>> getInvoiceItems(int invoiceId);

  /// Get invoices by customer
  Future<Either<Failure, List<Invoice>>> getInvoicesByCustomer({
    required int businessId,
    required int customerId,
  });

  /// Get invoices by status
  Future<Either<Failure, List<Invoice>>> getInvoicesByStatus({
    required int businessId,
    required String status,
  });

  /// Get invoices by date range
  Future<Either<Failure, List<Invoice>>> getInvoicesByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Update invoice status
  Future<Either<Failure, Invoice>> updateInvoiceStatus({
    required int invoiceId,
    required String status,
  });

  /// Update invoice payment
  Future<Either<Failure, Invoice>> updateInvoicePayment({
    required int invoiceId,
    required double paidAmount,
  });

  /// Cancel invoice
  Future<Either<Failure, void>> cancelInvoice(int invoiceId);

  /// Get next invoice number
  Future<Either<Failure, String>> getNextInvoiceNumber(int businessId);

  /// Get total invoice amount for a period
  Future<Either<Failure, double>> getTotalInvoiceAmount({
    required int businessId,
    required int startDate,
    required int endDate,
  });

  /// Get invoice count
  Future<Either<Failure, int>> getInvoiceCount(int businessId);
}
