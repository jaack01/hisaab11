import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/repositories/invoice_repository.dart';
import '../datasources/local/database/dao/invoice_dao.dart';
import '../datasources/local/database/dao/invoice_item_dao.dart';
import '../models/invoice_model.dart';
import '../models/invoice_item_model.dart';

/// Implementation of InvoiceRepository
class InvoiceRepositoryImpl implements InvoiceRepository {
  final InvoiceDao invoiceDao;
  final InvoiceItemDao invoiceItemDao;

  InvoiceRepositoryImpl(this.invoiceDao, this.invoiceItemDao);

  @override
  Future<Either<Failure, Invoice>> createInvoice({
    required Invoice invoice,
    required List<InvoiceItem> items,
  }) async {
    try {
      // Insert invoice
      final invoiceModel = InvoiceModel.fromEntity(invoice);
      final invoiceId = await invoiceDao.insert(invoiceModel);

      // Insert invoice items
      final itemModels = items
          .map((item) => InvoiceItemModel.fromEntity(
                item.copyWith(invoiceId: invoiceId),
              ))
          .toList();

      await invoiceItemDao.insertInvoiceItems(itemModels);

      // Return created invoice
      final createdModel = invoiceModel.copyWith(id: invoiceId);
      return Right(createdModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoices(int businessId) async {
    try {
      final models = await invoiceDao.getAllInvoices(businessId: businessId);
      final invoices = models.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> getInvoiceById(int id) async {
    try {
      final model = await invoiceDao.getById(id);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Invoice not found'));
      }
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<InvoiceItem>>> getInvoiceItems(
    int invoiceId,
  ) async {
    try {
      final models = await invoiceItemDao.getInvoiceItems(
        invoiceId: invoiceId,
      );
      final items = models.map((model) => model.toEntity()).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoicesByCustomer({
    required int businessId,
    required int customerId,
  }) async {
    try {
      final models = await invoiceDao.getInvoicesByCustomer(
        businessId: businessId,
        customerId: customerId,
      );
      final invoices = models.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoicesByStatus({
    required int businessId,
    required String status,
  }) async {
    try {
      final models = await invoiceDao.getInvoicesByStatus(
        businessId: businessId,
        status: status,
      );
      final invoices = models.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Invoice>>> getInvoicesByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final models = await invoiceDao.getInvoicesByDateRange(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      final invoices = models.map((model) => model.toEntity()).toList();
      return Right(invoices);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateInvoiceStatus({
    required int invoiceId,
    required String status,
  }) async {
    try {
      await invoiceDao.updateStatus(
        invoiceId: invoiceId,
        status: status,
      );

      final model = await invoiceDao.getById(invoiceId);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Invoice not found'));
      }

      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Invoice>> updateInvoicePayment({
    required int invoiceId,
    required double paidAmount,
  }) async {
    try {
      await invoiceDao.updatePayment(
        invoiceId: invoiceId,
        paidAmount: paidAmount,
      );

      final model = await invoiceDao.getById(invoiceId);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Invoice not found'));
      }

      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelInvoice(int invoiceId) async {
    try {
      await invoiceDao.cancelInvoice(invoiceId);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getNextInvoiceNumber(
    int businessId,
  ) async {
    try {
      final invoiceNumber = await invoiceDao.getNextInvoiceNumber(
        businessId: businessId,
      );
      return Right(invoiceNumber);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalInvoiceAmount({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final total = await invoiceDao.getTotalInvoiceAmount(
        businessId: businessId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(total);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getInvoiceCount(int businessId) async {
    try {
      final count = await invoiceDao.getInvoiceCount(businessId: businessId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
