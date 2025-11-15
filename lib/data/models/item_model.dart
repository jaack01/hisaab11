import '../../domain/entities/item.dart';

/// Item model for database operations
class ItemModel {
  final int? id;
  final int businessId;
  final String name;
  final String? description;
  final String? sku;
  final String? hsnCode;
  final String unit;
  final double salePrice;
  final double purchasePrice;
  final double taxRate;
  final double stockQuantity;
  final double lowStockThreshold;
  final String? imagePath;
  final String? category;
  final bool isActive;
  final int createdAt;
  final int updatedAt;

  const ItemModel({
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

  /// Convert model to entity
  Item toEntity() {
    return Item(
      id: id,
      businessId: businessId,
      name: name,
      description: description,
      sku: sku,
      hsnCode: hsnCode,
      unit: unit,
      salePrice: salePrice,
      purchasePrice: purchasePrice,
      taxRate: taxRate,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      imagePath: imagePath,
      category: category,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory ItemModel.fromEntity(Item item) {
    return ItemModel(
      id: item.id,
      businessId: item.businessId,
      name: item.name,
      description: item.description,
      sku: item.sku,
      hsnCode: item.hsnCode,
      unit: item.unit,
      salePrice: item.salePrice,
      purchasePrice: item.purchasePrice,
      taxRate: item.taxRate,
      stockQuantity: item.stockQuantity,
      lowStockThreshold: item.lowStockThreshold,
      imagePath: item.imagePath,
      category: item.category,
      isActive: item.isActive,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  /// Convert from database map
  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id'] as int?,
      businessId: map['business_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      sku: map['sku'] as String?,
      hsnCode: map['hsn_code'] as String?,
      unit: map['unit'] as String,
      salePrice: (map['sale_price'] as num).toDouble(),
      purchasePrice: (map['purchase_price'] as num).toDouble(),
      taxRate: (map['tax_rate'] as num).toDouble(),
      stockQuantity: (map['stock_quantity'] as num).toDouble(),
      lowStockThreshold: (map['low_stock_threshold'] as num).toDouble(),
      imagePath: map['image_path'] as String?,
      category: map['category'] as String?,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'business_id': businessId,
      'name': name,
      'description': description,
      'sku': sku,
      'hsn_code': hsnCode,
      'unit': unit,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'tax_rate': taxRate,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'image_path': imagePath,
      'category': category,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with method
  ItemModel copyWith({
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
    return ItemModel(
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
}
