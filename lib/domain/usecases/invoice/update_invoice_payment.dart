import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for updating invoice payment
class UpdateInvoicePayment {
  final InvoiceRepository repository;

  UpdateInvoicePayment(this.repository);

  Future<Either<Failure, Invoice>> call({
    required int invoiceId,
    required double paidAmount,
  }) async {
    if (invoiceId <= 0) {
      return Left(ValidationFailure(message: 'Invalid invoice ID'));
    }

    if (paidAmount < 0) {
      return Left(ValidationFailure(message: 'Paid amount cannot be negative'));
    }

    return repository.updateInvoicePayment(
      invoiceId: invoiceId,
      paidAmount: paidAmount,
    );
  }
}
