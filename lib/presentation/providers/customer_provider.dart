import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/customer.dart';

/// Customer list state
class CustomerListState {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;

  const CustomerListState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
  });

  CustomerListState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? error,
  }) {
    return CustomerListState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Customer list provider
class CustomerListNotifier extends StateNotifier<CustomerListState> {
  CustomerListNotifier(this._getCustomers) : super(const CustomerListState());

  final dynamic _getCustomers;

  Future<void> loadCustomers(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getCustomers(businessId: businessId);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (customers) {
        state = state.copyWith(
          customers: customers,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final customerListProvider =
    StateNotifierProvider<CustomerListNotifier, CustomerListState>((ref) {
  final getCustomers = ref.read(getCustomersUseCaseProvider);
  return CustomerListNotifier(getCustomers);
});

/// Current business ID provider (hardcoded to 1 for MVP)
final currentBusinessIdProvider = Provider<int>((ref) => 1);
