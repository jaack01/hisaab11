import 'package:sqflite/sqflite.dart';
import '../../../../models/invoice_item_model.dart';
import 'base_dao.dart';

/// Data Access Object for invoice items
class InvoiceItemDao extends BaseDao<InvoiceItemModel> {
  @override
  String get tableName => 'invoice_items';

  @override
  InvoiceItemModel fromMap(Map<String, dynamic> map) =>
      InvoiceItemModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(InvoiceItemModel entity) => entity.toMap();

  /// Get all items for an invoice
  Future<List<InvoiceItemModel>> getInvoiceItems({
    required int invoiceId,
  }) async {
    return await getAll(
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
      orderBy: 'created_at ASC',
    );
  }

  /// Insert multiple invoice items in a batch
  Future<List<int>> insertInvoiceItems(
    List<InvoiceItemModel> items,
  ) async {
    return await insertBatch(items);
  }

  /// Delete all items for an invoice
  Future<int> deleteInvoiceItems(int invoiceId) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }

  /// Get total items count for an invoice
  Future<int> getItemsCount({
    required int invoiceId,
  }) async {
    return await count(
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );
  }

  /// Get item by product ID in an invoice
  Future<InvoiceItemModel?> getItemByProductId({
    required int invoiceId,
    required int itemId,
  }) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'invoice_id = ? AND item_id = ?',
      whereArgs: [invoiceId, itemId],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return fromMap(maps.first);
  }

  /// Get total quantity for an item across all invoices
  Future<double> getTotalQuantitySold({
    required int itemId,
    int? startDate,
    int? endDate,
  }) async {
    final db = await database;
    String sql = '''
      SELECT SUM(quantity) as total
      FROM $tableName
      WHERE item_id = ?
    ''';
    List<dynamic> args = [itemId];

    if (startDate != null && endDate != null) {
      sql += ' AND created_at >= ? AND created_at <= ?';
      args.addAll([startDate, endDate]);
    }

    final result = await db.rawQuery(sql, args);
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get top selling items
  Future<List<Map<String, dynamic>>> getTopSellingItems({
    required int businessId,
    int limit = 10,
    int? startDate,
    int? endDate,
  }) async {
    final db = await database;
    String sql = '''
      SELECT
        ii.item_id,
        ii.item_name,
        SUM(ii.quantity) as total_quantity,
        SUM(ii.total_amount) as total_revenue
      FROM $tableName ii
      INNER JOIN invoices i ON ii.invoice_id = i.id
      WHERE i.business_id = ?
        AND i.is_deleted = 0
        AND i.status != 'CANCELLED'
    ''';
    List<dynamic> args = [businessId];

    if (startDate != null && endDate != null) {
      sql += ' AND i.invoice_date >= ? AND i.invoice_date <= ?';
      args.addAll([startDate, endDate]);
    }

    sql += '''
      GROUP BY ii.item_id, ii.item_name
      ORDER BY total_quantity DESC
      LIMIT ?
    ''';
    args.add(limit);

    return await db.rawQuery(sql, args);
  }
}
