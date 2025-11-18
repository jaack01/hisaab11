import 'package:sqflite/sqflite.dart';
import '../../../../../core/constants/db_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../models/transaction_model.dart';
import '../app_database.dart';
import 'base_dao.dart';

/// Transaction Data Access Object
class TransactionDao extends BaseDao<TransactionModel> {
  TransactionDao() : super();

  @override
  String get tableName => DbConstants.tableTransactions;

  @override
  TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(TransactionModel entity) {
    return entity.toJson();
  }

  /// Get all transactions for a business
  Future<List<TransactionModel>> getAllTransactions({
    required int businessId,
    int? limit,
    int? offset,
  }) async {
    try {
      return await getAll(
        where: '${DbConstants.colTransactionBusinessId} = ? AND ${DbConstants.colTransactionIsDeleted} = 0',
        whereArgs: [businessId],
        orderBy: '${DbConstants.colTransactionDate} DESC, ${DbConstants.colTransactionCreatedAt} DESC',
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions',
        originalException: e,
      );
    }
  }

  /// Get transactions for a specific customer
  Future<List<TransactionModel>> getTransactionsByCustomer({
    required int customerId,
    int? limit,
    int? offset,
  }) async {
    try {
      return await getAll(
        where: '${DbConstants.colTransactionCustomerId} = ? AND ${DbConstants.colTransactionIsDeleted} = 0',
        whereArgs: [customerId],
        orderBy: '${DbConstants.colTransactionDate} DESC, ${DbConstants.colTransactionCreatedAt} DESC',
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions by customer',
        originalException: e,
      );
    }
  }

  /// Get transactions by date range
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colTransactionBusinessId} = ? AND
          ${DbConstants.colTransactionIsDeleted} = 0 AND
          ${DbConstants.colTransactionDate} BETWEEN ? AND ?
        ''',
        whereArgs: [businessId, startDate, endDate],
        orderBy: '${DbConstants.colTransactionDate} DESC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions by date range',
        originalException: e,
      );
    }
  }

  /// Get total credit amount for a customer
  Future<double> getTotalCreditForCustomer(int customerId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT SUM(${DbConstants.colTransactionAmount}) as total
        FROM $tableName
        WHERE ${DbConstants.colTransactionCustomerId} = ? AND
              ${DbConstants.colTransactionType} = 'CREDIT' AND
              ${DbConstants.colTransactionIsDeleted} = 0
      ''', [customerId]);

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get total credit',
        originalException: e,
      );
    }
  }

  /// Get total debit amount for a customer
  Future<double> getTotalDebitForCustomer(int customerId) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT SUM(${DbConstants.colTransactionAmount}) as total
        FROM $tableName
        WHERE ${DbConstants.colTransactionCustomerId} = ? AND
              ${DbConstants.colTransactionType} = 'DEBIT' AND
              ${DbConstants.colTransactionIsDeleted} = 0
      ''', [customerId]);

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get total debit',
        originalException: e,
      );
    }
  }

  /// Get recent transactions
  Future<List<TransactionModel>> getRecentTransactions({
    required int businessId,
    int limit = 10,
  }) async {
    try {
      return await getAllTransactions(
        businessId: businessId,
        limit: limit,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get recent transactions',
        originalException: e,
      );
    }
  }

  /// Get transaction count for a business
  Future<int> getTransactionCount({required int businessId}) async {
    try {
      return await count(
        where: '${DbConstants.colTransactionBusinessId} = ? AND ${DbConstants.colTransactionIsDeleted} = 0',
        whereArgs: [businessId],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transaction count',
        originalException: e,
      );
    }
  }

  /// Get transactions by date range for a specific customer
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required int customerId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colTransactionCustomerId} = ? AND
          ${DbConstants.colTransactionIsDeleted} = 0 AND
          ${DbConstants.colTransactionDate} BETWEEN ? AND ?
        ''',
        whereArgs: [customerId, startDate, endDate],
        orderBy: '${DbConstants.colTransactionDate} ASC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions by date range for customer',
        originalException: e,
      );
    }
  }

  /// Get transactions before a specific date for a customer
  Future<List<TransactionModel>> getTransactionsBeforeDate({
    required int customerId,
    required int beforeDate,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colTransactionCustomerId} = ? AND
          ${DbConstants.colTransactionIsDeleted} = 0 AND
          ${DbConstants.colTransactionDate} < ?
        ''',
        whereArgs: [customerId, beforeDate],
        orderBy: '${DbConstants.colTransactionDate} ASC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions before date',
        originalException: e,
      );
    }
  }

  /// Get transactions by business and date range for daybook
  Future<List<TransactionModel>> getTransactionsByBusinessAndDateRange({
    required int businessId,
    required int startDate,
    required int endDate,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colTransactionBusinessId} = ? AND
          ${DbConstants.colTransactionIsDeleted} = 0 AND
          ${DbConstants.colTransactionDate} BETWEEN ? AND ?
        ''',
        whereArgs: [businessId, startDate, endDate],
        orderBy: '${DbConstants.colTransactionDate} ASC, ${DbConstants.colTransactionCreatedAt} ASC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get transactions for daybook',
        originalException: e,
      );
    }
  }

  /// Get top customers by transaction value
  Future<List<Map<String, dynamic>>> getTopCustomers({
    required int businessId,
    int limit = 10,
  }) async {
    try {
      final db = await database;
      return await db.rawQuery('''
        SELECT
          t.${DbConstants.colTransactionCustomerId} as customer_id,
          c.${DbConstants.colCustomerName} as customer_name,
          SUM(CASE
            WHEN t.${DbConstants.colTransactionType} = 'DEBIT'
            THEN t.${DbConstants.colTransactionAmount}
            ELSE 0
          END) as total_amount,
          COUNT(t.${DbConstants.colTransactionId}) as transaction_count
        FROM $tableName t
        INNER JOIN ${DbConstants.tableCustomers} c
          ON t.${DbConstants.colTransactionCustomerId} = c.${DbConstants.colCustomerId}
        WHERE t.${DbConstants.colTransactionBusinessId} = ?
          AND t.${DbConstants.colTransactionIsDeleted} = 0
        GROUP BY t.${DbConstants.colTransactionCustomerId}, c.${DbConstants.colCustomerName}
        ORDER BY total_amount DESC
        LIMIT ?
      ''', [businessId, limit]);
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get top customers',
        originalException: e,
      );
    }
  }
}
