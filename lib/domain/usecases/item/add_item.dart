import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

/// Use case for adding a new item/product
class AddItem {
  final ItemRepository repository;

  AddItem(this.repository);

  Future<Either<Failure, Item>> call(Item item) async {
    // Validate item name
    if (item.name.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Item name is required'));
    }

    // Validate prices
    if (item.salePrice < 0) {
      return Left(ValidationFailure(message: 'Sale price cannot be negative'));
    }

    if (item.purchasePrice < 0) {
      return Left(ValidationFailure(message: 'Purchase price cannot be negative'));
    }

    // Validate tax rate
    if (item.taxRate < 0 || item.taxRate > 100) {
      return Left(ValidationFailure(message: 'Tax rate must be between 0 and 100'));
    }

    // Validate stock quantity
    if (item.stockQuantity < 0) {
      return Left(ValidationFailure(message: 'Stock quantity cannot be negative'));
    }

    return repository.addItem(item);
  }
}
