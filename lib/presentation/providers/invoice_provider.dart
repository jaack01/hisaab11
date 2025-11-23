import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/invoice.dart';
import '../../domain/usecases/invoice/add_invoice_usecase.dart';
import '../../domain/usecases/invoice/get_invoice_by_id_usecase.dart';
import '../../domain/usecases/invoice/get_invoices_by_customer_usecase.dart';
import '../../domain/usecases/invoice/get_all_invoices_usecase.dart';
import '../../domain/usecases/invoice/update_invoice_usecase.dart';
import '../../domain/usecases/invoice/delete_invoice_usecase.dart';
import '../../domain/usecases/invoice/update_invoice_payment_status_usecase.dart';

/// Invoice state
class InvoiceState {
  final List<Invoice> invoices;
  final Invoice? selectedInvoice;
  final bool isLoading;
  final String? error;

  const InvoiceState({
    this.invoices = const [],
    this.selectedInvoice,
    this.isLoading = false,
    this.error,
  });

  InvoiceState copyWith({
    List<Invoice>? invoices,
    Invoice? selectedInvoice,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return InvoiceState(
      invoices: invoices ?? this.invoices,
      selectedInvoice: clearSelected ? null : (selectedInvoice ?? this.selectedInvoice),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Invoice provider
class InvoiceNotifier extends StateNotifier<InvoiceState> {
  final AddInvoiceUseCase _addInvoiceUseCase;
  final GetInvoiceByIdUseCase _getInvoiceByIdUseCase;
  final GetInvoicesByCustomerUseCase _getInvoicesByCustomerUseCase;
  final GetAllInvoicesUseCase _getAllInvoicesUseCase;
  final UpdateInvoiceUseCase _updateInvoiceUseCase;
  final DeleteInvoiceUseCase _deleteInvoiceUseCase;
  final UpdateInvoicePaymentStatusUseCase _updatePaymentStatusUseCase;

  InvoiceNotifier({
    required AddInvoiceUseCase addInvoiceUseCase,
    required GetInvoiceByIdUseCase getInvoiceByIdUseCase,
    required GetInvoicesByCustomerUseCase getInvoicesByCustomerUseCase,
    required GetAllInvoicesUseCase getAllInvoicesUseCase,
    required UpdateInvoiceUseCase updateInvoiceUseCase,
    required DeleteInvoiceUseCase deleteInvoiceUseCase,
    required UpdateInvoicePaymentStatusUseCase updatePaymentStatusUseCase,
  })  : _addInvoiceUseCase = addInvoiceUseCase,
        _getInvoiceByIdUseCase = getInvoiceByIdUseCase,
        _getInvoicesByCustomerUseCase = getInvoicesByCustomerUseCase,
        _getAllInvoicesUseCase = getAllInvoicesUseCase,
        _updateInvoiceUseCase = updateInvoiceUseCase,
        _deleteInvoiceUseCase = deleteInvoiceUseCase,
        _updatePaymentStatusUseCase = updatePaymentStatusUseCase,
        super(const InvoiceState());

  /// Load all invoices
  Future<void> loadAllInvoices({int? businessId}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllInvoicesUseCase(businessId ?? 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (invoices) => state = state.copyWith(
        isLoading: false,
        invoices: invoices,
      ),
    );
  }

  /// Load invoices for a specific customer
  Future<void> loadCustomerInvoices(int customerId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getInvoicesByCustomerUseCase(customerId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (invoices) => state = state.copyWith(
        isLoading: false,
        invoices: invoices,
      ),
    );
  }

  /// Load invoice by ID
  Future<void> loadInvoiceById(int invoiceId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getInvoiceByIdUseCase(invoiceId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (invoice) => state = state.copyWith(
        isLoading: false,
        selectedInvoice: invoice,
      ),
    );
  }

  /// Add new invoice
  Future<bool> addInvoice(Invoice invoice) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addInvoiceUseCase(invoice);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (invoiceId) {
        // Reload invoices
        loadAllInvoices(businessId: invoice.businessId);
        return true;
      },
    );
  }

  /// Update invoice
  Future<bool> updateInvoice(Invoice invoice) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateInvoiceUseCase(invoice);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload invoices
        loadAllInvoices(businessId: invoice.businessId);
        return true;
      },
    );
  }

  /// Delete invoice
  Future<bool> deleteInvoice(int invoiceId, int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _deleteInvoiceUseCase(invoiceId);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload invoices
        loadAllInvoices(businessId: businessId);
        return true;
      },
    );
  }

  /// Update payment status
  Future<bool> updatePaymentStatus({
    required int invoiceId,
    required String paymentStatus,
    int? paidDate,
    int? businessId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final params = UpdateInvoicePaymentStatusParams(
      invoiceId: invoiceId,
      paymentStatus: paymentStatus,
      paidDate: paidDate,
    );

    final result = await _updatePaymentStatusUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload invoice detail
        if (state.selectedInvoice?.id == invoiceId) {
          loadInvoiceById(invoiceId);
        }
        // Reload list
        if (businessId != null) {
          loadAllInvoices(businessId: businessId);
        }
        return true;
      },
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clear selected invoice
  void clearSelectedInvoice() {
    state = state.copyWith(clearSelected: true);
  }

  /// Filter invoices by status
  List<Invoice> getInvoicesByStatus(String status) {
    return state.invoices
        .where((invoice) => invoice.paymentStatus == status)
        .toList();
  }

  /// Get pending invoices
  List<Invoice> get pendingInvoices =>
      getInvoicesByStatus('PENDING');

  /// Get paid invoices
  List<Invoice> get paidInvoices =>
      getInvoicesByStatus('PAID');

  /// Get partially paid invoices
  List<Invoice> get partiallyPaidInvoices =>
      getInvoicesByStatus('PARTIAL');

  /// Get overdue invoices
  List<Invoice> get overdueInvoices =>
      getInvoicesByStatus('OVERDUE');

  /// Calculate total amount for all invoices
  double get totalAmount {
    return state.invoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
  }

  /// Calculate total paid amount
  double get totalPaidAmount {
    return paidInvoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
  }

  /// Calculate total pending amount
  double get totalPendingAmount {
    return pendingInvoices.fold(
      0.0,
      (sum, invoice) => sum + invoice.totalAmount,
    );
  }
}

// Provider instance (to be configured with dependency injection)
final invoiceProvider = StateNotifierProvider<InvoiceNotifier, InvoiceState>((ref) {
  // This will be properly injected from DI container
  // For now, throw an error to indicate it needs to be overridden
  throw UnimplementedError('invoiceProvider must be overridden with proper dependencies');
});
