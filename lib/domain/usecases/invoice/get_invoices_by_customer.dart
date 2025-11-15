import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for getting invoices by customer
class GetInvoicesByCustomer {
  final InvoiceRepository repository;

  GetInvoicesByCustomer(this.repository);

  Future<Either<Failure, List<Invoice>>> call({
    required int businessId,
    required int customerId,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    if (customerId <= 0) {
      return Left(ValidationFailure(message: 'Invalid customer ID'));
    }

    return repository.getInvoicesByCustomer(
      businessId: businessId,
      customerId: customerId,
    );
  }
}
