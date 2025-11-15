import 'package:sqflite/sqflite.dart';
import '../../../../models/invoice_model.dart';
import 'base_dao.dart';

/// Data Access Object for invoices
class InvoiceDao extends BaseDao<InvoiceModel> {
  @override
  String get tableName => 'invoices';

  @override
  InvoiceModel fromMap(Map<String, dynamic> map) => InvoiceModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(InvoiceModel entity) => entity.toMap();

  /// Get all invoices for a business (not deleted)
  Future<List<InvoiceModel>> getAllInvoices({
    required int businessId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND is_deleted = 0',
      whereArgs: [businessId],
      orderBy: 'invoice_date DESC, created_at DESC',
    );
  }

  /// Get invoices by customer
  Future<List<InvoiceModel>> getInvoicesByCustomer({
    required int businessId,
    required int customerId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND customer_id = ? AND is_deleted = 0',
      whereArgs: [businessId, customerId],
      orderBy: 'invoice_date DESC',
    );
  }

  /// Get invoices by status
  Future<List<InvoiceModel>> getInvoicesByStatus({
    required int businessId,
    required String status,
  }) async {
    return await getAll(
      where: 'business_id = ? AND status = ? AND is_deleted = 0',
      whereArgs: [businessId, status],
      orderBy: 'invoice_date DESC',
    );
  }

  /// Get invoices by date range
  Future<List<InvoiceModel>> getInvoicesByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    return await getAll(
      where: '''
        business_id = ? AND
        invoice_date >= ? AND
        invoice_date <= ? AND
        is_deleted = 0
      ''',
      whereArgs: [businessId, startDate, endDate],
      orderBy: 'invoice_date DESC',
    );
  }

  /// Get overdue invoices
  Future<List<InvoiceModel>> getOverdueInvoices({
    required int businessId,
    required int currentDate,
  }) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT *
      FROM $tableName
      WHERE business_id = ?
        AND status != 'PAID'
        AND status != 'CANCELLED'
        AND due_date IS NOT NULL
        AND due_date < ?
        AND is_deleted = 0
      ORDER BY due_date ASC
    ''', [businessId, currentDate]);

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Update invoice status
  Future<int> updateStatus({
    required int invoiceId,
    required String status,
  }) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'status': status,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  /// Update invoice payment
  Future<int> updatePayment({
    required int invoiceId,
    required double paidAmount,
  }) async {
    final db = await database;

    // Get current invoice to calculate balance
    final invoice = await getById(invoiceId);
    if (invoice == null) {
      throw Exception('Invoice not found');
    }

    final balanceAmount = invoice.totalAmount - paidAmount;
    String status;

    if (paidAmount >= invoice.totalAmount) {
      status = 'PAID';
    } else if (paidAmount > 0) {
      status = 'PARTIAL';
    } else {
      status = 'UNPAID';
    }

    return await db.update(
      tableName,
      {
        'paid_amount': paidAmount,
        'balance_amount': balanceAmount,
        'status': status,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  /// Get next invoice number
  Future<String> getNextInvoiceNumber({
    required int businessId,
    String prefix = 'INV',
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM $tableName
      WHERE business_id = ?
    ''', [businessId]);

    final count = Sqflite.firstIntValue(result) ?? 0;
    final nextNumber = count + 1;

    // Format: INV-YYYY-MM-NNNN
    final now = DateTime.now();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final number = nextNumber.toString().padLeft(4, '0');

    return '$prefix-$year-$month-$number';
  }

  /// Get total invoice amount for a period
  Future<double> getTotalInvoiceAmount({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total
      FROM $tableName
      WHERE business_id = ?
        AND invoice_date >= ?
        AND invoice_date <= ?
        AND is_deleted = 0
        AND status != 'CANCELLED'
    ''', [businessId, startDate, endDate]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total paid amount for a period
  Future<double> getTotalPaidAmount({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(paid_amount) as total
      FROM $tableName
      WHERE business_id = ?
        AND invoice_date >= ?
        AND invoice_date <= ?
        AND is_deleted = 0
        AND status != 'CANCELLED'
    ''', [businessId, startDate, endDate]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total outstanding amount
  Future<double> getTotalOutstanding({
    required int businessId,
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(balance_amount) as total
      FROM $tableName
      WHERE business_id = ?
        AND is_deleted = 0
        AND status != 'PAID'
        AND status != 'CANCELLED'
    ''', [businessId]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get invoice count
  Future<int> getInvoiceCount({
    required int businessId,
  }) async {
    return await count(
      where: 'business_id = ? AND is_deleted = 0',
      whereArgs: [businessId],
    );
  }

  /// Cancel invoice (soft delete with status change)
  Future<int> cancelInvoice(int id) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'status': 'CANCELLED',
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
