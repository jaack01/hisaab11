import '../../domain/entities/transaction.dart';
import '../../core/constants/db_constants.dart';

/// Transaction model - Extends entity with data layer functionality
class TransactionModel extends Transaction {
  const TransactionModel({
    super.id,
    required super.businessId,
    required super.customerId,
    required super.transactionType,
    required super.amount,
    super.description,
    required super.transactionDate,
    super.attachmentPath,
    super.paymentMode,
    super.referenceNumber,
    super.isDeleted,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create TransactionModel from Transaction entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      businessId: transaction.businessId,
      customerId: transaction.customerId,
      transactionType: transaction.transactionType,
      amount: transaction.amount,
      description: transaction.description,
      transactionDate: transaction.transactionDate,
      attachmentPath: transaction.attachmentPath,
      paymentMode: transaction.paymentMode,
      referenceNumber: transaction.referenceNumber,
      isDeleted: transaction.isDeleted,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
    );
  }

  /// Create TransactionModel from database map
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json[DbConstants.colTransactionId] as int?,
      businessId: json[DbConstants.colTransactionBusinessId] as int,
      customerId: json[DbConstants.colTransactionCustomerId] as int,
      transactionType: json[DbConstants.colTransactionType] as String,
      amount: (json[DbConstants.colTransactionAmount] as num).toDouble(),
      description: json[DbConstants.colTransactionDescription] as String?,
      transactionDate: json[DbConstants.colTransactionDate] as int,
      attachmentPath: json[DbConstants.colTransactionAttachmentPath] as String?,
      paymentMode: json[DbConstants.colTransactionPaymentMode] as String?,
      referenceNumber: json[DbConstants.colTransactionReferenceNumber] as String?,
      isDeleted: (json[DbConstants.colTransactionIsDeleted] as int?) == 1,
      createdAt: json[DbConstants.colTransactionCreatedAt] as int,
      updatedAt: json[DbConstants.colTransactionUpdatedAt] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) DbConstants.colTransactionId: id,
      DbConstants.colTransactionBusinessId: businessId,
      DbConstants.colTransactionCustomerId: customerId,
      DbConstants.colTransactionType: transactionType,
      DbConstants.colTransactionAmount: amount,
      DbConstants.colTransactionDescription: description,
      DbConstants.colTransactionDate: transactionDate,
      DbConstants.colTransactionAttachmentPath: attachmentPath,
      DbConstants.colTransactionPaymentMode: paymentMode,
      DbConstants.colTransactionReferenceNumber: referenceNumber,
      DbConstants.colTransactionIsDeleted: isDeleted ? 1 : 0,
      DbConstants.colTransactionCreatedAt: createdAt,
      DbConstants.colTransactionUpdatedAt: updatedAt,
    };
  }

  /// Convert to entity
  Transaction toEntity() {
    return Transaction(
      id: id,
      businessId: businessId,
      customerId: customerId,
      transactionType: transactionType,
      amount: amount,
      description: description,
      transactionDate: transactionDate,
      attachmentPath: attachmentPath,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
