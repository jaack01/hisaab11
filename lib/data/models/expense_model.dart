import '../../domain/entities/expense.dart';

/// Expense model for database operations
class ExpenseModel {
  final int? id;
  final int businessId;
  final String title;
  final String? description;
  final double amount;
  final String category;
  final int expenseDate;
  final String? paymentMode;
  final String? referenceNumber;
  final String? attachmentPath;
  final String? vendor;
  final bool isRecurring;
  final String? recurringFrequency;
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;

  const ExpenseModel({
    this.id,
    required this.businessId,
    required this.title,
    this.description,
    required this.amount,
    required this.category,
    required this.expenseDate,
    this.paymentMode,
    this.referenceNumber,
    this.attachmentPath,
    this.vendor,
    this.isRecurring = false,
    this.recurringFrequency,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert model to entity
  Expense toEntity() {
    return Expense(
      id: id,
      businessId: businessId,
      title: title,
      description: description,
      amount: amount,
      category: category,
      expenseDate: expenseDate,
      paymentMode: paymentMode,
      referenceNumber: referenceNumber,
      attachmentPath: attachmentPath,
      vendor: vendor,
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
      isDeleted: isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory ExpenseModel.fromEntity(Expense expense) {
    return ExpenseModel(
      id: expense.id,
      businessId: expense.businessId,
      title: expense.title,
      description: expense.description,
      amount: expense.amount,
      category: expense.category,
      expenseDate: expense.expenseDate,
      paymentMode: expense.paymentMode,
      referenceNumber: expense.referenceNumber,
      attachmentPath: expense.attachmentPath,
      vendor: expense.vendor,
      isRecurring: expense.isRecurring,
      recurringFrequency: expense.recurringFrequency,
      isDeleted: expense.isDeleted,
      createdAt: expense.createdAt,
      updatedAt: expense.updatedAt,
    );
  }

  /// Convert from database map
  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int?,
      businessId: map['business_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      expenseDate: map['expense_date'] as int,
      paymentMode: map['payment_mode'] as String?,
      referenceNumber: map['reference_number'] as String?,
      attachmentPath: map['attachment_path'] as String?,
      vendor: map['vendor'] as String?,
      isRecurring: (map['is_recurring'] as int) == 1,
      recurringFrequency: map['recurring_frequency'] as String?,
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
      'title': title,
      'description': description,
      'amount': amount,
      'category': category,
      'expense_date': expenseDate,
      'payment_mode': paymentMode,
      'reference_number': referenceNumber,
      'attachment_path': attachmentPath,
      'vendor': vendor,
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_frequency': recurringFrequency,
      'is_deleted': isDeleted ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with method
  ExpenseModel copyWith({
    int? id,
    int? businessId,
    String? title,
    String? description,
    double? amount,
    String? category,
    int? expenseDate,
    String? paymentMode,
    String? referenceNumber,
    String? attachmentPath,
    String? vendor,
    bool? isRecurring,
    String? recurringFrequency,
    bool? isDeleted,
    int? createdAt,
    int? updatedAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      expenseDate: expenseDate ?? this.expenseDate,
      paymentMode: paymentMode ?? this.paymentMode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      vendor: vendor ?? this.vendor,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
