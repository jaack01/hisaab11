import 'package:sqflite/sqflite.dart';
import '../../../../models/expense_model.dart';
import 'base_dao.dart';

/// Data Access Object for expenses
class ExpenseDao extends BaseDao<ExpenseModel> {
  @override
  String get tableName => 'expenses';

  @override
  ExpenseModel fromMap(Map<String, dynamic> map) => ExpenseModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(ExpenseModel entity) => entity.toMap();

  /// Get all expenses for a business (not deleted)
  Future<List<ExpenseModel>> getAllExpenses({
    required int businessId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND is_deleted = 0',
      whereArgs: [businessId],
      orderBy: 'expense_date DESC, created_at DESC',
    );
  }

  /// Get expenses by category
  Future<List<ExpenseModel>> getExpensesByCategory({
    required int businessId,
    required String category,
  }) async {
    return await getAll(
      where: 'business_id = ? AND category = ? AND is_deleted = 0',
      whereArgs: [businessId, category],
      orderBy: 'expense_date DESC',
    );
  }

  /// Get expenses by date range
  Future<List<ExpenseModel>> getExpensesByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    return await getAll(
      where: '''
        business_id = ? AND
        expense_date >= ? AND
        expense_date <= ? AND
        is_deleted = 0
      ''',
      whereArgs: [businessId, startDate, endDate],
      orderBy: 'expense_date DESC',
    );
  }

  /// Get expenses by vendor
  Future<List<ExpenseModel>> getExpensesByVendor({
    required int businessId,
    required String vendor,
  }) async {
    return await getAll(
      where: 'business_id = ? AND vendor = ? AND is_deleted = 0',
      whereArgs: [businessId, vendor],
      orderBy: 'expense_date DESC',
    );
  }

  /// Get total expenses for a period
  Future<double> getTotalExpenses({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total
      FROM $tableName
      WHERE business_id = ?
        AND expense_date >= ?
        AND expense_date <= ?
        AND is_deleted = 0
    ''', [businessId, startDate, endDate]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  /// Get all unique expense categories
  Future<List<String>> getAllCategories({
    required int businessId,
  }) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT category
      FROM $tableName
      WHERE business_id = ?
        AND category IS NOT NULL
        AND is_deleted = 0
      ORDER BY category ASC
    ''', [businessId]);

    return maps
        .map((map) => map['category'] as String)
        .where((cat) => cat.isNotEmpty)
        .toList();
  }

  /// Get expenses breakdown by category
  Future<Map<String, double>> getExpensesByCategory Breakdown({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM $tableName
      WHERE business_id = ?
        AND expense_date >= ?
        AND expense_date <= ?
        AND is_deleted = 0
      GROUP BY category
      ORDER BY total DESC
    ''', [businessId, startDate, endDate]);

    final Map<String, double> breakdown = {};
    for (final map in maps) {
      final category = map['category'] as String;
      final total = (map['total'] as num).toDouble();
      breakdown[category] = total;
    }

    return breakdown;
  }

  /// Get current month expenses
  Future<List<ExpenseModel>> getCurrentMonthExpenses({
    required int businessId,
    required int year,
    required int month,
  }) async {
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    final startTimestamp = firstDay.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = lastDay.millisecondsSinceEpoch ~/ 1000;

    return await getExpensesByDateRange(
      businessId: businessId,
      startDate: startTimestamp,
      endDate: endTimestamp,
    );
  }

  /// Get expense count
  Future<int> getExpenseCount({
    required int businessId,
  }) async {
    return await count(
      where: 'business_id = ? AND is_deleted = 0',
      whereArgs: [businessId],
    );
  }

  /// Soft delete expense
  Future<int> deleteExpense(int id) async {
    return await softDelete(id);
  }

  /// Get all unique vendors
  Future<List<String>> getAllVendors({
    required int businessId,
  }) async {
    final db = await database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT vendor
      FROM $tableName
      WHERE business_id = ?
        AND vendor IS NOT NULL
        AND vendor != ''
        AND is_deleted = 0
      ORDER BY vendor ASC
    ''', [businessId]);

    return maps
        .map((map) => map['vendor'] as String)
        .where((vendor) => vendor.isNotEmpty)
        .toList();
  }

  /// Get recurring expenses
  Future<List<ExpenseModel>> getRecurringExpenses({
    required int businessId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND is_recurring = 1 AND is_deleted = 0',
      whereArgs: [businessId],
      orderBy: 'expense_date DESC',
    );
  }
}
