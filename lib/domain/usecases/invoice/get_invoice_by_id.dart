import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/invoice.dart';
import '../../repositories/invoice_repository.dart';

/// Use case for getting an invoice by ID
class GetInvoiceById {
  final InvoiceRepository repository;

  GetInvoiceById(this.repository);

  Future<Either<Failure, Invoice>> call(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure(message: 'Invalid invoice ID'));
    }

    return repository.getInvoiceById(id);
  }
}
