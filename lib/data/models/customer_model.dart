import '../../domain/entities/customer.dart';
import '../../core/constants/db_constants.dart';

/// Customer model - Extends entity with data layer functionality
class CustomerModel extends Customer {
  const CustomerModel({
    super.id,
    required super.businessId,
    required super.name,
    super.phone,
    super.email,
    super.address,
    super.gstin,
    super.pan,
    super.openingBalance,
    super.openingBalanceType,
    super.currentBalance,
    super.profileImagePath,
    super.notes,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create CustomerModel from Customer entity
  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      businessId: customer.businessId,
      name: customer.name,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      gstin: customer.gstin,
      pan: customer.pan,
      openingBalance: customer.openingBalance,
      openingBalanceType: customer.openingBalanceType,
      currentBalance: customer.currentBalance,
      profileImagePath: customer.profileImagePath,
      notes: customer.notes,
      isActive: customer.isActive,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }

  /// Create CustomerModel from database map
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[DbConstants.colCustomerId] as int?,
      businessId: json[DbConstants.colCustomerBusinessId] as int,
      name: json[DbConstants.colCustomerName] as String,
      phone: json[DbConstants.colCustomerPhone] as String?,
      email: json[DbConstants.colCustomerEmail] as String?,
      address: json[DbConstants.colCustomerAddress] as String?,
      gstin: json[DbConstants.colCustomerGstin] as String?,
      pan: json[DbConstants.colCustomerPan] as String?,
      openingBalance: (json[DbConstants.colCustomerOpeningBalance] as num?)?.toDouble() ?? 0.0,
      openingBalanceType: json[DbConstants.colCustomerOpeningBalanceType] as String? ?? 'CREDIT',
      currentBalance: (json[DbConstants.colCustomerCurrentBalance] as num?)?.toDouble() ?? 0.0,
      profileImagePath: json[DbConstants.colCustomerProfileImagePath] as String?,
      notes: json[DbConstants.colCustomerNotes] as String?,
      isActive: (json[DbConstants.colCustomerIsActive] as int?) == 1,
      createdAt: json[DbConstants.colCustomerCreatedAt] as int,
      updatedAt: json[DbConstants.colCustomerUpdatedAt] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) DbConstants.colCustomerId: id,
      DbConstants.colCustomerBusinessId: businessId,
      DbConstants.colCustomerName: name,
      DbConstants.colCustomerPhone: phone,
      DbConstants.colCustomerEmail: email,
      DbConstants.colCustomerAddress: address,
      DbConstants.colCustomerGstin: gstin,
      DbConstants.colCustomerPan: pan,
      DbConstants.colCustomerOpeningBalance: openingBalance,
      DbConstants.colCustomerOpeningBalanceType: openingBalanceType,
      DbConstants.colCustomerCurrentBalance: currentBalance,
      DbConstants.colCustomerProfileImagePath: profileImagePath,
      DbConstants.colCustomerNotes: notes,
      DbConstants.colCustomerIsActive: isActive ? 1 : 0,
      DbConstants.colCustomerCreatedAt: createdAt,
      DbConstants.colCustomerUpdatedAt: updatedAt,
    };
  }

  /// Convert to entity
  Customer toEntity() {
    return Customer(
      id: id,
      businessId: businessId,
      name: name,
      phone: phone,
      email: email,
      address: address,
      gstin: gstin,
      pan: pan,
      openingBalance: openingBalance,
      openingBalanceType: openingBalanceType,
      currentBalance: currentBalance,
      profileImagePath: profileImagePath,
      notes: notes,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
