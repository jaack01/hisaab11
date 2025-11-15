import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../repositories/item_repository.dart';

/// Use case for deleting an item (soft delete)
class DeleteItem {
  final ItemRepository repository;

  DeleteItem(this.repository);

  Future<Either<Failure, void>> call(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure(message: 'Invalid item ID'));
    }

    return repository.deleteItem(id);
  }
}
