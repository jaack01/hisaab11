import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for getting the next invoice number
class GetNextInvoiceNumber {
  final InvoiceRepository repository;

  GetNextInvoiceNumber(this.repository);

  Future<Either<Failure, String>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getNextInvoiceNumber(businessId);
  }
}
