import 'package:equatable/equatable.dart';

/// Customer entity - Pure business object
class Customer extends Equatable {
  final int? id;
  final int businessId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstin;
  final String? pan;
  final double openingBalance;
  final String openingBalanceType; // CREDIT or DEBIT
  final double currentBalance;
  final String? profileImagePath;
  final String? notes;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const Customer({
    this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.gstin,
    this.pan,
    this.openingBalance = 0.0,
    this.openingBalanceType = 'CREDIT',
    this.currentBalance = 0.0,
    this.profileImagePath,
    this.notes,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if customer has outstanding balance (money to receive)
  bool get hasOutstanding => currentBalance > 0;

  /// Check if customer has credit balance (money to pay)
  bool get hasCredit => currentBalance < 0;

  /// Check if customer balance is settled
  bool get isSettled => currentBalance == 0;

  /// Get balance status
  String get balanceStatus {
    if (hasOutstanding) return 'TO_RECEIVE';
    if (hasCredit) return 'TO_PAY';
    return 'SETTLED';
  }

  /// Get absolute balance amount
  double get absoluteBalance => currentBalance.abs();

  /// Copy with method for immutability
  Customer copyWith({
    int? id,
    int? businessId,
    String? name,
    String? phone,
    String? email,
    String? address,
    String? gstin,
    String? pan,
    double? openingBalance,
    String? openingBalanceType,
    double? currentBalance,
    String? profileImagePath,
    String? notes,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceType: openingBalanceType ?? this.openingBalanceType,
      currentBalance: currentBalance ?? this.currentBalance,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        name,
        phone,
        email,
        address,
        gstin,
        pan,
        openingBalance,
        openingBalanceType,
        currentBalance,
        profileImagePath,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];
}
