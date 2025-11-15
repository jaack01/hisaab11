import '../../domain/entities/invoice.dart';

/// Invoice model for database operations
class InvoiceModel {
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
  final String status;
  final String? paymentTerms;
  final String? notes;
  final String? termsConditions;
  final bool isGstInvoice;
  final int? transactionId;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;

  const InvoiceModel({
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

  /// Convert model to entity
  Invoice toEntity() {
    return Invoice(
      id: id,
      businessId: businessId,
      invoiceNumber: invoiceNumber,
      customerId: customerId,
      invoiceDate: invoiceDate,
      dueDate: dueDate,
      subtotal: subtotal,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      paidAmount: paidAmount,
      balanceAmount: balanceAmount,
      status: status,
      paymentTerms: paymentTerms,
      notes: notes,
      termsConditions: termsConditions,
      isGstInvoice: isGstInvoice,
      transactionId: transactionId,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory InvoiceModel.fromEntity(Invoice invoice) {
    return InvoiceModel(
      id: invoice.id,
      businessId: invoice.businessId,
      invoiceNumber: invoice.invoiceNumber,
      customerId: invoice.customerId,
      invoiceDate: invoice.invoiceDate,
      dueDate: invoice.dueDate,
      subtotal: invoice.subtotal,
      discountPercentage: invoice.discountPercentage,
      discountAmount: invoice.discountAmount,
      taxAmount: invoice.taxAmount,
      totalAmount: invoice.totalAmount,
      paidAmount: invoice.paidAmount,
      balanceAmount: invoice.balanceAmount,
      status: invoice.status,
      paymentTerms: invoice.paymentTerms,
      notes: invoice.notes,
      termsConditions: invoice.termsConditions,
      isGstInvoice: invoice.isGstInvoice,
      transactionId: invoice.transactionId,
      isDeleted: invoice.isDeleted,
      createdAt: invoice.createdAt,
      updatedAt: invoice.updatedAt,
    );
  }

  /// Convert from database map
  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int?,
      businessId: map['business_id'] as int,
      invoiceNumber: map['invoice_number'] as String,
      customerId: map['customer_id'] as int,
      invoiceDate: map['invoice_date'] as int,
      dueDate: map['due_date'] as int?,
      subtotal: (map['subtotal'] as num).toDouble(),
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      paidAmount: (map['paid_amount'] as num).toDouble(),
      balanceAmount: (map['balance_amount'] as num).toDouble(),
      status: map['status'] as String,
      paymentTerms: map['payment_terms'] as String?,
      notes: map['notes'] as String?,
      termsConditions: map['terms_conditions'] as String?,
      isGstInvoice: (map['is_gst_invoice'] as int) == 1,
      transactionId: map['transaction_id'] as int?,
      isDeleted: (map['is_deleted'] as int) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'business_id': businessId,
      'invoice_number': invoiceNumber,
      'customer_id': customerId,
      'invoice_date': invoiceDate,
      'due_date': dueDate,
      'subtotal': subtotal,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'balance_amount': balanceAmount,
      'status': status,
      'payment_terms': paymentTerms,
      'notes': notes,
      'terms_conditions': termsConditions,
      'is_gst_invoice': isGstInvoice ? 1 : 0,
      'transaction_id': transactionId,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with method
  InvoiceModel copyWith({
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
    return InvoiceModel(
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
}
