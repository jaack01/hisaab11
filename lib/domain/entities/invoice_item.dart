import 'package:equatable/equatable.dart';

/// Invoice item (line item) entity
class InvoiceItem extends Equatable {
  final int? id;
  final int invoiceId;
  final int? itemId; // Can be null for ad-hoc items
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

  const InvoiceItem({
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

  /// Calculate line total (quantity * rate)
  double get lineTotal => quantity * rate;

  /// Copy with method
  InvoiceItem copyWith({
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
    return InvoiceItem(
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

  @override
  List<Object?> get props => [
        id,
        invoiceId,
        itemId,
        itemName,
        description,
        hsnCode,
        quantity,
        unit,
        rate,
        discountPercentage,
        discountAmount,
        taxableAmount,
        taxRate,
        taxAmount,
        totalAmount,
        createdAt,
      ];
}
