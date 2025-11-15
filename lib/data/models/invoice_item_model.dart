import '../../domain/entities/invoice_item.dart';

/// Invoice item model for database operations
class InvoiceItemModel {
  final int? id;
  final int invoiceId;
  final int? itemId;
  final String itemName;
  final String? description;
  final String? hsnCode;
  final double quantity;
  final String unit;
  final double rate;
  final double discountPercentage;
  final double discountAmount;
  final double taxableAmount;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final int createdAt;

  const InvoiceItemModel({
    this.id,
    required this.invoiceId,
    this.itemId,
    required this.itemName,
    this.description,
    this.hsnCode,
    required this.quantity,
    this.unit = 'PCS',
    required this.rate,
    this.discountPercentage = 0.0,
    this.discountAmount = 0.0,
    required this.taxableAmount,
    this.taxRate = 0.0,
    this.taxAmount = 0.0,
    required this.totalAmount,
    required this.createdAt,
  });

  /// Convert model to entity
  InvoiceItem toEntity() {
    return InvoiceItem(
      id: id,
      invoiceId: invoiceId,
      itemId: itemId,
      itemName: itemName,
      description: description,
      hsnCode: hsnCode,
      quantity: quantity,
      unit: unit,
      rate: rate,
      discountPercentage: discountPercentage,
      discountAmount: discountAmount,
      taxableAmount: taxableAmount,
      taxRate: taxRate,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      createdAt: createdAt,
    );
  }

  /// Create model from entity
  factory InvoiceItemModel.fromEntity(InvoiceItem item) {
    return InvoiceItemModel(
      id: item.id,
      invoiceId: item.invoiceId,
      itemId: item.itemId,
      itemName: item.itemName,
      description: item.description,
      hsnCode: item.hsnCode,
      quantity: item.quantity,
      unit: item.unit,
      rate: item.rate,
      discountPercentage: item.discountPercentage,
      discountAmount: item.discountAmount,
      taxableAmount: item.taxableAmount,
      taxRate: item.taxRate,
      taxAmount: item.taxAmount,
      totalAmount: item.totalAmount,
      createdAt: item.createdAt,
    );
  }

  /// Convert from database map
  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) {
    return InvoiceItemModel(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int,
      itemId: map['item_id'] as int?,
      itemName: map['item_name'] as String,
      description: map['description'] as String?,
      hsnCode: map['hsn_code'] as String?,
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'] as String,
      rate: (map['rate'] as num).toDouble(),
      discountPercentage: (map['discount_percentage'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num).toDouble(),
      taxableAmount: (map['taxable_amount'] as num).toDouble(),
      taxRate: (map['tax_rate'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      totalAmount: (map['total_amount'] as num).toDouble(),
      createdAt: map['created_at'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoice_id': invoiceId,
      'item_id': itemId,
      'item_name': itemName,
      'description': description,
      'hsn_code': hsnCode,
      'quantity': quantity,
      'unit': unit,
      'rate': rate,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'taxable_amount': taxableAmount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'created_at': createdAt,
    };
  }

  /// Copy with method
  InvoiceItemModel copyWith({
    int? id,
    int? invoiceId,
    int? itemId,
    String? itemName,
    String? description,
    String? hsnCode,
    double? quantity,
    String? unit,
    double? rate,
    double? discountPercentage,
    double? discountAmount,
    double? taxableAmount,
    double? taxRate,
    double? taxAmount,
    double? totalAmount,
    int? createdAt,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      itemId: itemId ?? this.itemId,
      itemName: itemName ?? this.itemName,
      description: description ?? this.description,
      hsnCode: hsnCode ?? this.hsnCode,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      rate: rate ?? this.rate,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
