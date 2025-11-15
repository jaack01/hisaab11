import 'package:equatable/equatable.dart';

/// Invoice entity
class Invoice extends Equatable {
  final int? id;
  final int businessId;
  final String invoiceNumber;
  final int customerId;
  final int invoiceDate;
  final int? dueDate;
  final double subtotal;
  final double discountPercentage;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double balanceAmount;
  final String status; // PAID, UNPAID, PARTIAL, CANCELLED
  final String? paymentTerms;
  final String? notes;
  final String? termsConditions;
  final bool isGstInvoice;
  final int? transactionId;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;

  const Invoice({
    this.id,
    required this.businessId,
    required this.invoiceNumber,
    required this.customerId,
    required this.invoiceDate,
    this.dueDate,
    this.subtotal = 0.0,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    this.paidAmount = 0.0,
    this.balanceAmount = 0.0,
    this.status = 'UNPAID',
    this.paymentTerms,
    this.notes,
    this.termsConditions,
    this.isGstInvoice = false,
    this.transactionId,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if invoice is paid
  bool get isPaid => status == 'PAID';

  /// Check if invoice is unpaid
  bool get isUnpaid => status == 'UNPAID';

  /// Check if invoice is partially paid
  bool get isPartial => status == 'PARTIAL';

  /// Check if invoice is overdue
  bool isOverdue(int currentTimestamp) {
    if (dueDate == null || isPaid) return false;
    return currentTimestamp > dueDate!;
  }

  /// Copy with method
  Invoice copyWith({
    int? id,
    int? businessId,
    String? invoiceNumber,
    int? customerId,
    int? invoiceDate,
    int? dueDate,
    double? subtotal,
    double? discountPercentage,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    double? paidAmount,
    double? balanceAmount,
    String? status,
    String? paymentTerms,
    String? notes,
    String? termsConditions,
    bool? isGstInvoice,
    int? transactionId,
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      customerId: customerId ?? this.customerId,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balanceAmount: balanceAmount ?? this.balanceAmount,
      status: status ?? this.status,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      notes: notes ?? this.notes,
      termsConditions: termsConditions ?? this.termsConditions,
      isGstInvoice: isGstInvoice ?? this.isGstInvoice,
      transactionId: transactionId ?? this.transactionId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        invoiceNumber,
        customerId,
        invoiceDate,
        dueDate,
        subtotal,
        discountPercentage,
        discountAmount,
        taxAmount,
        totalAmount,
        paidAmount,
        balanceAmount,
        status,
        paymentTerms,
        notes,
        termsConditions,
        isGstInvoice,
        transactionId,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
