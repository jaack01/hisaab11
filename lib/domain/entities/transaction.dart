import 'package:equatable/equatable.dart';

/// Transaction entity - Pure business object
class Transaction extends Equatable {
  final int? id;
  final int businessId;
  final int customerId;
  final String transactionType; // CREDIT or DEBIT
  final double amount;
  final String? description;
  final int transactionDate; // Unix timestamp
  final String? attachmentPath;
  final String? paymentMode; // CASH, UPI, CARD, etc.
  final String? referenceNumber;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;

  const Transaction({
    this.id,
    required this.businessId,
    required this.customerId,
    required this.transactionType,
    required this.amount,
    this.description,
    required this.transactionDate,
    this.attachmentPath,
    this.paymentMode,
    this.referenceNumber,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if transaction is credit (You Gave - customer owes you)
  bool get isCredit => transactionType == 'CREDIT';

  /// Check if transaction is debit (You Got - customer paid)
  bool get isDebit => transactionType == 'DEBIT';

  /// Get transaction type display text
  String get transactionTypeDisplay => isCredit ? 'You Gave' : 'You Got';

  /// Check if transaction has attachment
  bool get hasAttachment => attachmentPath != null && attachmentPath!.isNotEmpty;

  /// Copy with method for immutability
  Transaction copyWith({
    int? id,
    int? businessId,
    int? customerId,
    String? transactionType,
    double? amount,
    String? description,
    int? transactionDate,
    String? attachmentPath,
    String? paymentMode,
    String? referenceNumber,
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        customerId,
        transactionType,
        amount,
        description,
        transactionDate,
        attachmentPath,
        paymentMode,
        referenceNumber,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
