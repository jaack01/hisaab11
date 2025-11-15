import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/transaction.dart';

/// Transaction list state
class TransactionListState {
  final List<Transaction> transactions;
  final bool isLoading;
  final String? error;

  const TransactionListState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  TransactionListState copyWith({
    List<Transaction>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return TransactionListState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Transaction list provider
class TransactionListNotifier extends StateNotifier<TransactionListState> {
  TransactionListNotifier(this._getTransactions) : super(const TransactionListState());

  final dynamic _getTransactions;

  Future<void> loadTransactions(int businessId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _getTransactions(businessId: businessId, limit: 50);

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (transactions) {
        state = state.copyWith(
          transactions: transactions,
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

final transactionListProvider =
    StateNotifierProvider<TransactionListNotifier, TransactionListState>((ref) {
  final getTransactions = ref.read(getTransactionsUseCaseProvider);
  return TransactionListNotifier(getTransactions);
});
