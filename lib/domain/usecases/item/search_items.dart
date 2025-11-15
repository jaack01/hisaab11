import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../entities/item.dart';
import '../../repositories/item_repository.dart';

/// Use case for searching items by name or SKU
class SearchItems {
  final ItemRepository repository;

  SearchItems(this.repository);

  Future<Either<Failure, List<Item>>> call({
    required int businessId,
    required String query,
  }) async {
    if (businessId <= 0) {
      return Left(ValidationFailure(message: 'Invalid business ID'));
    }

    if (query.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Search query cannot be empty'));
    }

    return repository.searchItems(
      businessId: businessId,
      query: query.trim(),
    );
  }
}
