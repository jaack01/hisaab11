import 'package:sqflite/sqflite.dart';
import '../../../../models/item_model.dart';
import 'base_dao.dart';

/// Data Access Object for items/products
class ItemDao extends BaseDao<ItemModel> {
  @override
  String get tableName => 'items';

  @override
  ItemModel fromMap(Map<String, dynamic> map) => ItemModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(ItemModel entity) => entity.toMap();

  /// Get all items for a business (only active items)
  Future<List<ItemModel>> getAllItems({
    required int businessId,
    bool includeInactive = false,
  }) async {
    String where = 'business_id = ?';
    List<dynamic> whereArgs = [businessId];

    if (!includeInactive) {
      where += ' AND is_active = 1';
    }

    return await getAll(
      where: where,
      whereArgs: whereArgs,
      orderBy: 'name ASC',
    );
  }

  /// Search items by name or SKU
  Future<List<ItemModel>> searchItems({
    required int businessId,
    required String query,
  }) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: '''
        business_id = ? AND
        is_active = 1 AND
        (name LIKE ? OR sku LIKE ?)
      ''',
      whereArgs: [businessId, '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Get items by category
  Future<List<ItemModel>> getItemsByCategory({
    required int businessId,
    required String category,
  }) async {
    return await getAll(
      where: 'business_id = ? AND category = ? AND is_active = 1',
      whereArgs: [businessId, category],
      orderBy: 'name ASC',
    );
  }

  /// Get low stock items
  Future<List<ItemModel>> getLowStockItems({
    required int businessId,
  }) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT *
      FROM $tableName
      WHERE business_id = ?
        AND is_active = 1
        AND stock_quantity <= low_stock_threshold
      ORDER BY stock_quantity ASC
    ''', [businessId]);

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Get out of stock items
  Future<List<ItemModel>> getOutOfStockItems({
    required int businessId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND is_active = 1 AND stock_quantity <= 0',
      whereArgs: [businessId],
      orderBy: 'name ASC',
    );
  }

  /// Update stock quantity
  Future<int> updateStock({
    required int itemId,
    required double quantity,
  }) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'stock_quantity': quantity,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Adjust stock (add or subtract)
  Future<int> adjustStock({
    required int itemId,
    required double adjustment,
  }) async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE $tableName
      SET stock_quantity = stock_quantity + ?,
          updated_at = ?
      WHERE id = ?
    ''', [
      adjustment,
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      itemId,
    ]);
  }

  /// Get all unique categories
  Future<List<String>> getAllCategories({
    required int businessId,
  }) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT category
      FROM $tableName
      WHERE business_id = ?
        AND category IS NOT NULL
        AND is_active = 1
      ORDER BY category ASC
    ''', [businessId]);

    return maps
        .map((map) => map['category'] as String)
        .where((cat) => cat.isNotEmpty)
        .toList();
  }

  /// Get total stock value (sale price * quantity)
  Future<double> getTotalStockValue({
    required int businessId,
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(stock_quantity * sale_price) as total
      FROM $tableName
      WHERE business_id = ?
        AND is_active = 1
    ''', [businessId]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get total stock value at purchase price
  Future<double> getTotalPurchaseValue({
    required int businessId,
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(stock_quantity * purchase_price) as total
      FROM $tableName
      WHERE business_id = ?
        AND is_active = 1
    ''', [businessId]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get item count for a business
  Future<int> getItemCount({
    required int businessId,
  }) async {
    return await count(
      where: 'business_id = ? AND is_active = 1',
      whereArgs: [businessId],
    );
  }

  /// Deactivate item (soft delete)
  Future<int> deactivateItem(int id) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'is_active': 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Reactivate item
  Future<int> reactivateItem(int id) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'is_active': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
