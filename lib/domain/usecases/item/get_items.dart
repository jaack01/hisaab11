import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

/// Use case for getting all items for a business
class GetItems {
  final ItemRepository repository;

  GetItems(this.repository);

  Future<Either<Failure, List<Item>>> call(int businessId) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    return repository.getItems(businessId);
  }
}
