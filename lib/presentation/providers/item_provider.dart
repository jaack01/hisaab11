import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/item.dart';
import '../../domain/usecases/item/add_item_usecase.dart';
import '../../domain/usecases/item/get_item_by_id_usecase.dart';
import '../../domain/usecases/item/get_all_items_usecase.dart';
import '../../domain/usecases/item/update_item_usecase.dart';
import '../../domain/usecases/item/delete_item_usecase.dart';
import '../../domain/usecases/item/search_items_usecase.dart';

/// Item state
class ItemState {
  final List<Item> items;
  final Item? selectedItem;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const ItemState({
    this.items = const [],
    this.selectedItem,
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  ItemState copyWith({
    List<Item>? items,
    Item? selectedItem,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return ItemState(
      items: items ?? this.items,
      selectedItem: clearSelected ? null : (selectedItem ?? this.selectedItem),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Item provider
class ItemNotifier extends StateNotifier<ItemState> {
  final AddItemUseCase _addItemUseCase;
  final GetItemByIdUseCase _getItemByIdUseCase;
  final GetAllItemsUseCase _getAllItemsUseCase;
  final UpdateItemUseCase _updateItemUseCase;
  final DeleteItemUseCase _deleteItemUseCase;
  final SearchItemsUseCase _searchItemsUseCase;

  ItemNotifier({
    required AddItemUseCase addItemUseCase,
    required GetItemByIdUseCase getItemByIdUseCase,
    required GetAllItemsUseCase getAllItemsUseCase,
    required UpdateItemUseCase updateItemUseCase,
    required DeleteItemUseCase deleteItemUseCase,
    required SearchItemsUseCase searchItemsUseCase,
  })  : _addItemUseCase = addItemUseCase,
        _getItemByIdUseCase = getItemByIdUseCase,
        _getAllItemsUseCase = getAllItemsUseCase,
        _updateItemUseCase = updateItemUseCase,
        _deleteItemUseCase = deleteItemUseCase,
        _searchItemsUseCase = searchItemsUseCase,
        super(const ItemState());

  /// Load all items
  Future<void> loadAllItems({int? businessId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllItemsUseCase(businessId ?? 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
      ),
    );
  }

  /// Load item by ID
  Future<void> loadItemById(int itemId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getItemByIdUseCase(itemId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (item) => state = state.copyWith(
        isLoading: false,
        selectedItem: item,
      ),
    );
  }

  /// Search items
  Future<void> searchItems(String query, {int? businessId}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      searchQuery: query,
    );

    if (query.isEmpty) {
      // Load all items if query is empty
      await loadAllItems(businessId: businessId);
      return;
    }

    final params = SearchItemsParams(
      query: query,
      businessId: businessId ?? 1,
    );

    final result = await _searchItemsUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        items: items,
      ),
    );
  }

  /// Add new item
  Future<bool> addItem(Item item) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addItemUseCase(item);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (itemId) {
        // Reload items
        loadAllItems(businessId: item.businessId);
        return true;
      },
    );
  }

  /// Update item
  Future<bool> updateItem(Item item) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateItemUseCase(item);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload items
        loadAllItems(businessId: item.businessId);
        return true;
      },
    );
  }

  /// Delete item
  Future<bool> deleteItem(int itemId, int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deleteItemUseCase(itemId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload items
        loadAllItems(businessId: businessId);
        return true;
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear selected item
  void clearSelectedItem() {
    state = state.copyWith(clearSelected: true);
  }

  /// Clear search
  void clearSearch({int? businessId}) {
    state = state.copyWith(searchQuery: '');
    loadAllItems(businessId: businessId);
  }

  /// Filter items by type
  List<Item> getItemsByType(String itemType) {
    return state.items
        .where((item) => item.itemType == itemType)
        .toList();
  }

  /// Get product items
  List<Item> get productItems => getItemsByType('PRODUCT');

  /// Get service items
  List<Item> get serviceItems => getItemsByType('SERVICE');

  /// Get active items (not deleted)
  List<Item> get activeItems {
    return state.items.where((item) => !item.isDeleted).toList();
  }

  /// Get items sorted by name
  List<Item> get itemsSortedByName {
    final items = List<Item>.from(state.items);
    items.sort((a, b) => a.name.compareTo(b.name));
    return items;
  }

  /// Get items sorted by price
  List<Item> get itemsSortedByPrice {
    final items = List<Item>.from(state.items);
    items.sort((a, b) => a.salePrice.compareTo(b.salePrice));
    return items;
  }
}

// Provider instance (to be configured with dependency injection)
final itemProvider = StateNotifierProvider<ItemNotifier, ItemState>((ref) {
  throw UnimplementedError('itemProvider must be overridden with proper dependencies');
});
