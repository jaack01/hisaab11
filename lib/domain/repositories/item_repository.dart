import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/item.dart';

/// Repository interface for item/product management
abstract class ItemRepository {
  /// Add a new item
  Future<Either<Failure, Item>> addItem(Item item);

  /// Get all items for a business
  Future<Either<Failure, List<Item>>> getItems(int businessId);

  /// Get item by ID
  Future<Either<Failure, Item>> getItemById(int id);

  /// Update an item
  Future<Either<Failure, Item>> updateItem(Item item);

  /// Delete an item (soft delete)
  Future<Either<Failure, void>> deleteItem(int id);

  /// Search items by name or SKU
  Future<Either<Failure, List<Item>>> searchItems({
    required int businessId,
    required String query,
  });

  /// Get items by category
  Future<Either<Failure, List<Item>>> getItemsByCategory({
    required int businessId,
    required String category,
  });

  /// Get low stock items
  Future<Either<Failure, List<Item>>> getLowStockItems(int businessId);

  /// Update stock quantity
  Future<Either<Failure, Item>> updateStock({
    required int itemId,
    required double quantity,
  });

  /// Get item count for a business
  Future<Either<Failure, int>> getItemCount(int businessId);
}
