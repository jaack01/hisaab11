import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/invoice.dart';
import '../../entities/invoice_item.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for creating a new invoice with items
class CreateInvoice {
  final InvoiceRepository repository;

  CreateInvoice(this.repository);

  Future<Either<Failure, Invoice>> call({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    // Validate invoice
    if (invoice.invoiceNumber.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Invoice number is required'));
    }

    if (invoice.customerId <= 0) {
      return Left(ValidationFailure(message: 'Invalid customer ID'));
    }

    if (invoice.totalAmount < 0) {
      return Left(ValidationFailure(message: 'Total amount cannot be negative'));
    }

    // Validate items
    if (items.isEmpty) {
      return Left(ValidationFailure(message: 'Invoice must have at least one item'));
    }

    for (final item in items) {
      if (item.quantity <= 0) {
        return Left(ValidationFailure(
          message: 'Item quantity must be greater than zero',
        ));
      }

      if (item.rate < 0) {
        return Left(ValidationFailure(
          message: 'Item rate cannot be negative',
        ));
      }
    }

    return repository.createInvoice(
      invoice: invoice,
      items: items,
    );
  }
}
