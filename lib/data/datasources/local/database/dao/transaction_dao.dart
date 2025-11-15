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
}
