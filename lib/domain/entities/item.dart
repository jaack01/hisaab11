import 'package:equatable/equatable.dart';

/// Item/Product entity for inventory management
class Item extends Equatable {
  final int? id;
  final int businessId;
  final String name;
  final String? description;
  final String? sku;
  final String? hsnCode; // HSN code for GST
  final String unit; // PCS, KG, LITER, etc.
  final double salePrice;
  final double purchasePrice;
  final double taxRate; // GST percentage
  final double stockQuantity;
  final double lowStockThreshold;
  final String? imagePath;
  final String? category;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const Item({
    this.id,
    required this.businessId,
    required this.name,
    this.description,
    this.sku,
    this.hsnCode,
    this.unit = 'PCS',
    this.salePrice = 0.0,
    this.purchasePrice = 0.0,
    this.taxRate = 0.0,
    this.stockQuantity = 0.0,
    this.lowStockThreshold = 10.0,
    this.imagePath,
    this.category,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if item is low in stock
  bool get isLowStock => stockQuantity <= lowStockThreshold;

  /// Check if item is out of stock
  bool get isOutOfStock => stockQuantity <= 0;

  /// Get profit margin
  double get profitMargin => salePrice - purchasePrice;

  /// Get profit percentage
  double get profitPercentage {
    if (purchasePrice == 0) return 0;
    return ((salePrice - purchasePrice) / purchasePrice) * 100;
  }

  /// Copy with method
  Item copyWith({
    int? id,
    int? businessId,
    String? name,
    String? description,
    String? sku,
    String? hsnCode,
    String? unit,
    double? salePrice,
    double? purchasePrice,
    double? taxRate,
    double? stockQuantity,
    double? lowStockThreshold,
    String? imagePath,
    String? category,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return Item(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      sku: sku ?? this.sku,
      hsnCode: hsnCode ?? this.hsnCode,
      unit: unit ?? this.unit,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      taxRate: taxRate ?? this.taxRate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      imagePath: imagePath ?? this.imagePath,
      category: category ?? this.category,
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
        description,
        sku,
        hsnCode,
        unit,
        salePrice,
        purchasePrice,
        taxRate,
        stockQuantity,
        lowStockThreshold,
        imagePath,
        category,
        isActive,
        createdAt,
        updatedAt,
      ];
}
