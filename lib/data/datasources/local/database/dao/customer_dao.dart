import 'package:sqflite/sqflite.dart';
import '../../../../../core/constants/db_constants.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../models/customer_model.dart';
import '../app_database.dart';
import 'base_dao.dart';

/// Customer Data Access Object
class CustomerDao extends BaseDao<CustomerModel> {
  CustomerDao() : super();

  @override
  String get tableName => DbConstants.tableCustomers;

  @override
  CustomerModel fromMap(Map<String, dynamic> map) {
    return CustomerModel.fromJson(map);
  }

  @override
  Map<String, dynamic> toMap(CustomerModel entity) {
    return entity.toJson();
  }

  /// Get all customers for a business
  Future<List<CustomerModel>> getAllCustomers({
    required int businessId,
    int? limit,
    int? offset,
  }) async {
    try {
      return await getAll(
        where: '${DbConstants.colCustomerBusinessId} = ? AND ${DbConstants.colCustomerIsActive} = 1',
        whereArgs: [businessId],
        orderBy: '${DbConstants.colCustomerName} COLLATE NOCASE ASC',
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get customers',
        originalException: e,
      );
    }
  }

  /// Search customers by name or phone
  Future<List<CustomerModel>> searchCustomers({
    required int businessId,
    required String query,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colCustomerBusinessId} = ? AND
          ${DbConstants.colCustomerIsActive} = 1 AND
          (${DbConstants.colCustomerName} LIKE ? OR ${DbConstants.colCustomerPhone} LIKE ?)
        ''',
        whereArgs: [businessId, '%$query%', '%$query%'],
        orderBy: '${DbConstants.colCustomerName} COLLATE NOCASE ASC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to search customers',
        originalException: e,
      );
    }
  }

  /// Get customers with outstanding balance (money to receive)
  Future<List<CustomerModel>> getCustomersWithOutstanding({
    required int businessId,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colCustomerBusinessId} = ? AND
          ${DbConstants.colCustomerIsActive} = 1 AND
          ${DbConstants.colCustomerCurrentBalance} > 0
        ''',
        whereArgs: [businessId],
        orderBy: '${DbConstants.colCustomerCurrentBalance} DESC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get customers with outstanding',
        originalException: e,
      );
    }
  }

  /// Get customers with credit balance (money to pay)
  Future<List<CustomerModel>> getCustomersWithCredit({
    required int businessId,
  }) async {
    try {
      final db = await database;
      final maps = await db.query(
        tableName,
        where: '''
          ${DbConstants.colCustomerBusinessId} = ? AND
          ${DbConstants.colCustomerIsActive} = 1 AND
          ${DbConstants.colCustomerCurrentBalance} < 0
        ''',
        whereArgs: [businessId],
        orderBy: '${DbConstants.colCustomerCurrentBalance} ASC',
      );

      return maps.map((map) => fromMap(map)).toList();
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get customers with credit',
        originalException: e,
      );
    }
  }

  /// Get total receivable amount for a business
  Future<double> getTotalReceivable({required int businessId}) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT SUM(${DbConstants.colCustomerCurrentBalance}) as total
        FROM $tableName
        WHERE ${DbConstants.colCustomerBusinessId} = ? AND
              ${DbConstants.colCustomerIsActive} = 1 AND
              ${DbConstants.colCustomerCurrentBalance} > 0
      ''', [businessId]);

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get total receivable',
        originalException: e,
      );
    }
  }

  /// Get total payable amount for a business
  Future<double> getTotalPayable({required int businessId}) async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT SUM(ABS(${DbConstants.colCustomerCurrentBalance})) as total
        FROM $tableName
        WHERE ${DbConstants.colCustomerBusinessId} = ? AND
              ${DbConstants.colCustomerIsActive} = 1 AND
              ${DbConstants.colCustomerCurrentBalance} < 0
      ''', [businessId]);

      return (result.first['total'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get total payable',
        originalException: e,
      );
    }
  }

  /// Get customer count for a business
  Future<int> getCustomerCount({required int businessId}) async {
    try {
      return await count(
        where: '${DbConstants.colCustomerBusinessId} = ? AND ${DbConstants.colCustomerIsActive} = 1',
        whereArgs: [businessId],
      );
    } catch (e) {
      throw DatabaseException(
        message: 'Failed to get customer count',
        originalException: e,
      );
    }
  }
}
