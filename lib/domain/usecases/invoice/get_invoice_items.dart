import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/invoice_item.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for getting invoice items
class GetInvoiceItems {
  final InvoiceRepository repository;

  GetInvoiceItems(this.repository);

  Future<Either<Failure, List<InvoiceItem>>> call(int invoiceId) async {
    if (invoiceId <= 0) {
      return Left(ValidationFailure(message: 'Invalid invoice ID'));
    }

    return repository.getInvoiceItems(invoiceId);
  }
}
