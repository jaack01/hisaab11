import 'package:sqflite/sqflite.dart';
import '../app_database.dart';

/// Base Data Access Object providing common database operations
abstract class BaseDao<T> {
  final AppDatabase _database = AppDatabase();

  /// Get table name
  String get tableName;

  /// Convert database map to entity
  T fromMap(Map<String, dynamic> map);

  /// Convert entity to database map
  Map<String, dynamic> toMap(T entity);

  /// Get database instance
  Future<Database> get database async => await _database.database;

  /// Insert a record
  Future<int> insert(T entity) async {
    final db = await database;
    final map = toMap(entity);
    return await db.insert(tableName, map);
  }

  /// Insert multiple records in a batch
  Future<List<int>> insertBatch(List<T> entities) async {
    final db = await database;
    final batch = db.batch();
    for (final entity in entities) {
      batch.insert(tableName, toMap(entity));
    }
    final results = await batch.commit();
    return results.cast<int>();
  }

  /// Update a record
  Future<int> update(T entity, int id) async {
    final db = await database;
    final map = toMap(entity);
    return await db.update(
      tableName,
      map,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete a record by ID
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Soft delete (set is_deleted = 1)
  Future<int> softDelete(int id) async {
    final db = await database;
    return await db.update(
      tableName,
      {
        'is_deleted': 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get a record by ID
  Future<T?> getById(int id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return fromMap(maps.first);
  }

  /// Get all records
  Future<List<T>> getAll({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => fromMap(map)).toList();
  }

  /// Count records
  Future<int> count({
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    final result = await db.query(
      tableName,
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );

    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Check if record exists
  Future<bool> exists(int id) async {
    final count = await this.count(
      where: 'id = ?',
      whereArgs: [id],
    );
    return count > 0;
  }

  /// Execute raw query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await _database.rawQuery(sql, arguments);
  }

  /// Execute raw insert/update/delete
  Future<int> rawExecute(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    return await _database.rawExecute(sql, arguments);
  }

  /// Clear table
  Future<int> clearTable() async {
    final db = await database;
    return await db.delete(tableName);
  }
}
