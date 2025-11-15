import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

/// Use case for getting an item by ID
class GetItemById {
  final ItemRepository repository;

  GetItemById(this.repository);

  Future<Either<Failure, Item>> call(int id) async {
    if (id <= 0) {
      return Left(ValidationFailure(message: 'Invalid item ID'));
    }

    return repository.getItemById(id);
  }
}
