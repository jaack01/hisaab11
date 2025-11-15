import 'package:dartz/dartz.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/item.dart';
import '../../domain/repositories/item_repository.dart';
import '../datasources/local/database/dao/item_dao.dart';
import '../models/item_model.dart';

/// Implementation of ItemRepository
class ItemRepositoryImpl implements ItemRepository {
  final ItemDao dao;

  ItemRepositoryImpl(this.dao);

  @override
  Future<Either<Failure, Item>> addItem(Item item) async {
    try {
      final model = ItemModel.fromEntity(item);
      final id = await dao.insert(model);
      final insertedModel = model.copyWith(id: id);
      return Right(insertedModel.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getItems(int businessId) async {
    try {
      final models = await dao.getAllItems(businessId: businessId);
      final items = models.map((model) => model.toEntity()).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> getItemById(int id) async {
    try {
      final model = await dao.getById(id);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Item not found'));
      }
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> updateItem(Item item) async {
    try {
      if (item.id == null) {
        return Left(ValidationFailure(message: 'Item ID is required'));
      }

      final model = ItemModel.fromEntity(item);
      await dao.update(model, item.id!);
      return Right(item);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteItem(int id) async {
    try {
      await dao.deactivateItem(id);
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> searchItems({
    required int businessId,
    required String query,
  }) async {
    try {
      final models = await dao.searchItems(
        businessId: businessId,
        query: query,
      );
      final items = models.map((model) => model.toEntity()).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getItemsByCategory({
    required int businessId,
    required String category,
  }) async {
    try {
      final models = await dao.getItemsByCategory(
        businessId: businessId,
        category: category,
      );
      final items = models.map((model) => model.toEntity()).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Item>>> getLowStockItems(int businessId) async {
    try {
      final models = await dao.getLowStockItems(businessId: businessId);
      final items = models.map((model) => model.toEntity()).toList();
      return Right(items);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Item>> updateStock({
    required int itemId,
    required double quantity,
  }) async {
    try {
      await dao.updateStock(itemId: itemId, quantity: quantity);
      final model = await dao.getById(itemId);
      if (model == null) {
        return Left(NotFoundFailure(message: 'Item not found'));
      }
      return Right(model.toEntity());
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getItemCount(int businessId) async {
    try {
      final count = await dao.getItemCount(businessId: businessId);
      return Right(count);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
