import 'package:sqflite/sqflite.dart';
import '../../../../models/reminder_model.dart';
import 'base_dao.dart';

/// Data Access Object for reminders
class ReminderDao extends BaseDao<ReminderModel> {
  @override
  String get tableName => 'reminders';

  @override
  ReminderModel fromMap(Map<String, dynamic> map) => ReminderModel.fromMap(map);

  @override
  Map<String, dynamic> toMap(ReminderModel entity) => entity.toMap();

  /// Get all reminders for a business
  Future<List<ReminderModel>> getAllReminders({
    required int businessId,
  }) async {
    return await getAll(
      where: 'business_id = ?',
      whereArgs: [businessId],
      orderBy: 'reminder_date DESC',
    );
  }

  /// Get reminders by customer
  Future<List<ReminderModel>> getRemindersByCustomer({
    required int businessId,
    required int customerId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND customer_id = ?',
      whereArgs: [businessId, customerId],
      orderBy: 'reminder_date DESC',
    );
  }

  /// Get pending reminders
  Future<List<ReminderModel>> getPendingReminders({
    required int businessId,
  }) async {
    return await getAll(
      where: 'business_id = ? AND status = ?',
      whereArgs: [businessId, 'PENDING'],
      orderBy: 'reminder_date ASC',
    );
  }

  /// Get reminders for today
  Future<List<ReminderModel>> getTodayReminders({
    required int businessId,
    required int currentDate,
  }) async {
    final db = await database;

    // Calculate start and end of day
    final startOfDay = DateTime.fromMillisecondsSinceEpoch(currentDate * 1000);
    final endOfDay = DateTime(startOfDay.year, startOfDay.month, startOfDay.day, 23, 59, 59);

    final startTimestamp = startOfDay.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = endOfDay.millisecondsSinceEpoch ~/ 1000;

    final maps = await db.query(
      tableName,
      where: '''
        business_id = ? AND
        status = 'PENDING' AND
        reminder_date >= ? AND
        reminder_date <= ?
      ''',
      whereArgs: [businessId, startTimestamp, endTimestamp],
      orderBy: 'reminder_date ASC',
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Get overdue reminders
  Future<List<ReminderModel>> getOverdueReminders({
    required int businessId,
    required int currentDate,
  }) async {
    return await getAll(
      where: '''
        business_id = ? AND
        status = 'PENDING' AND
        reminder_date < ?
      ''',
      whereArgs: [businessId, currentDate],
      orderBy: 'reminder_date ASC',
    );
  }

  /// Get reminders by status
  Future<List<ReminderModel>> getRemindersByStatus({
    required int businessId,
    required String status,
  }) async {
    return await getAll(
      where: 'business_id = ? AND status = ?',
      whereArgs: [businessId, status],
      orderBy: 'reminder_date DESC',
    );
  }

  /// Mark reminder as sent
  Future<int> markAsSent(int reminderId) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return await db.update(
      tableName,
      {
        'status': 'SENT',
        'last_sent_date': now,
        'updated_at': now,
      },
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// Cancel reminder
  Future<int> cancelReminder(int reminderId) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'status': 'CANCELLED',
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }

  /// Get reminder count by status
  Future<int> getReminderCountByStatus({
    required int businessId,
    required String status,
  }) async {
    return await count(
      where: 'business_id = ? AND status = ?',
      whereArgs: [businessId, status],
    );
  }

  /// Get total reminder count
  Future<int> getReminderCount({
    required int businessId,
  }) async {
    return await count(
      where: 'business_id = ?',
      whereArgs: [businessId],
    );
  }

  /// Update next reminder date for recurring reminders
  Future<int> updateNextReminderDate({
    required int reminderId,
    required int nextDate,
  }) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'next_reminder_date': nextDate,
        'status': 'PENDING',
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [reminderId],
    );
  }
}
