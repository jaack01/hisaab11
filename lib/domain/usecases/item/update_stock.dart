import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

/// Use case for updating item stock quantity
class UpdateStock {
  final ItemRepository repository;

  UpdateStock(this.repository);

  Future<Either<Failure, Item>> call({
    required int itemId,
    required double quantity,
  }) async {
    if (itemId <= 0) {
      return Left(ValidationFailure(message: 'Invalid item ID'));
    }

    if (quantity < 0) {
      return Left(ValidationFailure(message: 'Stock quantity cannot be negative'));
    }

    return repository.updateStock(
      itemId: itemId,
      quantity: quantity,
    );
  }
}
