import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for getting all invoices for a business
class GetInvoices {
  final InvoiceRepository repository;

  GetInvoices(this.repository);

  Future<Either<Failure, List<Invoice>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getInvoices(businessId);
  }
}
