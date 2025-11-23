import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/business.dart';
import '../../domain/usecases/business/add_business_usecase.dart';
import '../../domain/usecases/business/get_business_by_id_usecase.dart';
import '../../domain/usecases/business/get_all_businesses_usecase.dart';
import '../../domain/usecases/business/update_business_usecase.dart';

/// Business state
class BusinessState {
  final List<Business> businesses;
  final Business? currentBusiness;
  final bool isLoading;
  final String? error;

  const BusinessState({
    this.businesses = const [],
    this.currentBusiness,
    this.isLoading = false,
    this.error,
  });

  BusinessState copyWith({
    List<Business>? businesses,
    Business? currentBusiness,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool clearCurrent = false,
  }) {
    return BusinessState(
      businesses: businesses ?? this.businesses,
      currentBusiness: clearCurrent ? null : (currentBusiness ?? this.currentBusiness),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Business provider
class BusinessNotifier extends StateNotifier<BusinessState> {
  final AddBusinessUseCase _addBusinessUseCase;
  final GetBusinessByIdUseCase _getBusinessByIdUseCase;
  final GetAllBusinessesUseCase _getAllBusinessesUseCase;
  final UpdateBusinessUseCase _updateBusinessUseCase;

  BusinessNotifier({
    required AddBusinessUseCase addBusinessUseCase,
    required GetBusinessByIdUseCase getBusinessByIdUseCase,
    required GetAllBusinessesUseCase getAllBusinessesUseCase,
    required UpdateBusinessUseCase updateBusinessUseCase,
  })  : _addBusinessUseCase = addBusinessUseCase,
        _getBusinessByIdUseCase = getBusinessByIdUseCase,
        _getAllBusinessesUseCase = getAllBusinessesUseCase,
        _updateBusinessUseCase = updateBusinessUseCase,
        super(const BusinessState());

  /// Load all businesses
  Future<void> loadAllBusinesses() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getAllBusinessesUseCase(null);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (businesses) {
        state = state.copyWith(
          isLoading: false,
          businesses: businesses,
          // Set first business as current if none selected
          currentBusiness: state.currentBusiness ?? (businesses.isNotEmpty ? businesses.first : null),
        );
      },
    );
  }

  /// Load business by ID
  Future<void> loadBusinessById(int businessId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _getBusinessByIdUseCase(businessId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (business) => state = state.copyWith(
        isLoading: false,
        currentBusiness: business,
      ),
    );
  }

  /// Add new business
  Future<bool> addBusiness(Business business) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _addBusinessUseCase(business);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (businessId) {
        // Reload businesses
        loadAllBusinesses();
        return true;
      },
    );
  }

  /// Update business
  Future<bool> updateBusiness(Business business) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _updateBusinessUseCase(business);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
        return false;
      },
      (_) {
        // Reload business
        loadBusinessById(business.id!);
        return true;
      },
    );
  }

  /// Set current business
  void setCurrentBusiness(Business business) {
    state = state.copyWith(currentBusiness: business);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Get current business ID
  int? get currentBusinessId => state.currentBusiness?.id;
}

// Provider instance (to be configured with dependency injection)
final businessProvider = StateNotifierProvider<BusinessNotifier, BusinessState>((ref) {
  throw UnimplementedError('businessProvider must be overridden with proper dependencies');
});
