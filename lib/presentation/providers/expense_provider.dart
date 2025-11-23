import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/expense.dart';
import '../../domain/usecases/expense/add_expense_usecase.dart';
import '../../domain/usecases/expense/get_expense_by_id_usecase.dart';
import '../../domain/usecases/expense/get_expenses_by_category_usecase.dart';
import '../../domain/usecases/expense/get_expenses_by_date_range_usecase.dart';
import '../../domain/usecases/expense/get_all_expenses_usecase.dart';
import '../../domain/usecases/expense/update_expense_usecase.dart';
import '../../domain/usecases/expense/delete_expense_usecase.dart';

/// Expense state
class ExpenseState {
  final List<Expense> expenses;
  final Expense? selectedExpense;
  final bool isLoading;
  final String? error;
  final String? selectedCategory;
  final int? startDate;
  final int? endDate;

  const ExpenseState({
    this.expenses = const [],
    this.selectedExpense,
    this.isLoading = false,
    this.error,
    this.selectedCategory,
    this.startDate,
    this.endDate,
  });

  ExpenseState copyWith({
    List<Expense>? expenses,
    Expense? selectedExpense,
    bool? isLoading,
    String? error,
    String? selectedCategory,
    int? startDate,
    int? endDate,
    bool clearError = false,
    bool clearSelected = false,
    bool clearFilters = false,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      selectedExpense: clearSelected ? null : (selectedExpense ?? this.selectedExpense),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedCategory: clearFilters ? null : (selectedCategory ?? this.selectedCategory),
      startDate: clearFilters ? null : (startDate ?? this.startDate),
      endDate: clearFilters ? null : (endDate ?? this.endDate),
    );
  }
}

/// Expense provider
class ExpenseNotifier extends StateNotifier<ExpenseState> {
  final AddExpenseUseCase _addExpenseUseCase;
  final GetExpenseByIdUseCase _getExpenseByIdUseCase;
  final GetExpensesByCategoryUseCase _getExpensesByCategoryUseCase;
  final GetExpensesByDateRangeUseCase _getExpensesByDateRangeUseCase;
  final GetAllExpensesUseCase _getAllExpensesUseCase;
  final UpdateExpenseUseCase _updateExpenseUseCase;
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  ExpenseNotifier({
    required AddExpenseUseCase addExpenseUseCase,
    required GetExpenseByIdUseCase getExpenseByIdUseCase,
    required GetExpensesByCategoryUseCase getExpensesByCategoryUseCase,
    required GetExpensesByDateRangeUseCase getExpensesByDateRangeUseCase,
    required GetAllExpensesUseCase getAllExpensesUseCase,
    required UpdateExpenseUseCase updateExpenseUseCase,
    required DeleteExpenseUseCase deleteExpenseUseCase,
  })  : _addExpenseUseCase = addExpenseUseCase,
        _getExpenseByIdUseCase = getExpenseByIdUseCase,
        _getExpensesByCategoryUseCase = getExpensesByCategoryUseCase,
        _getExpensesByDateRangeUseCase = getExpensesByDateRangeUseCase,
        _getAllExpensesUseCase = getAllExpensesUseCase,
        _updateExpenseUseCase = updateExpenseUseCase,
        _deleteExpenseUseCase = deleteExpenseUseCase,
        super(const ExpenseState());

  /// Load all expenses
  Future<void> loadAllExpenses({int? businessId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllExpensesUseCase(businessId ?? 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (expenses) => state = state.copyWith(
        isLoading: false,
        expenses: expenses,
      ),
    );
  }

  /// Load expense by ID
  Future<void> loadExpenseById(int expenseId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getExpenseByIdUseCase(expenseId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (expense) => state = state.copyWith(
        isLoading: false,
        selectedExpense: expense,
      ),
    );
  }

  /// Load expenses by category
  Future<void> loadExpensesByCategory(String category, {int? businessId}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedCategory: category,
    );

    final params = ExpensesByCategoryParams(
      category: category,
      businessId: businessId ?? 1,
    );

    final result = await _getExpensesByCategoryUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (expenses) => state = state.copyWith(
        isLoading: false,
        expenses: expenses,
      ),
    );
  }

  /// Load expenses by date range
  Future<void> loadExpensesByDateRange({
    required int startDate,
    required int endDate,
    int? businessId,
  }) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      startDate: startDate,
      endDate: endDate,
    );

    final params = ExpensesByDateRangeParams(
      businessId: businessId ?? 1,
      startDate: startDate,
      endDate: endDate,
    );

    final result = await _getExpensesByDateRangeUseCase(params);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (expenses) => state = state.copyWith(
        isLoading: false,
        expenses: expenses,
      ),
    );
  }

  /// Add new expense
  Future<bool> addExpense(Expense expense) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addExpenseUseCase(expense);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (expenseId) {
        // Reload expenses
        loadAllExpenses(businessId: expense.businessId);
        return true;
      },
    );
  }

  /// Update expense
  Future<bool> updateExpense(Expense expense) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateExpenseUseCase(expense);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload expenses
        loadAllExpenses(businessId: expense.businessId);
        return true;
      },
    );
  }

  /// Delete expense
  Future<bool> deleteExpense(int expenseId, int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deleteExpenseUseCase(expenseId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload expenses
        loadAllExpenses(businessId: businessId);
        return true;
      },
    );
  }

  /// Clear filters
  void clearFilters({int? businessId}) {
    state = state.copyWith(clearFilters: true);
    loadAllExpenses(businessId: businessId);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear selected expense
  void clearSelectedExpense() {
    state = state.copyWith(clearSelected: true);
  }

  /// Get expenses by category (from current state)
  List<Expense> getExpensesByCategory(String category) {
    return state.expenses
        .where((expense) => expense.category == category)
        .toList();
  }

  /// Calculate total expenses
  double get totalExpenses {
    return state.expenses.fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }

  /// Calculate total by category
  double getTotalByCategory(String category) {
    return getExpensesByCategory(category).fold(
      0.0,
      (sum, expense) => sum + expense.amount,
    );
  }

  /// Get unique categories
  List<String> get categories {
    final categoriesSet = state.expenses
        .map((expense) => expense.category)
        .toSet();
    return categoriesSet.toList()..sort();
  }

  /// Get expenses sorted by date (newest first)
  List<Expense> get expensesSortedByDate {
    final expenses = List<Expense>.from(state.expenses);
    expenses.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
    return expenses;
  }

  /// Get expenses sorted by amount (highest first)
  List<Expense> get expensesSortedByAmount {
    final expenses = List<Expense>.from(state.expenses);
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    return expenses;
  }
}

// Provider instance (to be configured with dependency injection)
final expenseProvider = StateNotifierProvider<ExpenseNotifier, ExpenseState>((ref) {
  throw UnimplementedError('expenseProvider must be overridden with proper dependencies');
});
