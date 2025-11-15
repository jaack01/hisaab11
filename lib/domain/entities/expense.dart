import 'package:equatable/equatable.dart';

/// Expense entity for business expense tracking
class Expense extends Equatable {
  final int? id;
  final int businessId;
  final String title;
  final String? description;
  final double amount;
  final String category;
  final int expenseDate;
  final String? paymentMode; // CASH, UPI, CARD, BANK_TRANSFER, CHEQUE
  final String? referenceNumber;
  final String? attachmentPath;
  final String? vendor;
  final bool isRecurring;
  final String? recurringFrequency; // DAILY, WEEKLY, MONTHLY, YEARLY
  final bool isDeleted;
  final int createdAt;
  final int updatedAt;

  const Expense({
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

  /// Check if expense is for today
  bool isToday(int currentTimestamp) {
    final expenseDay = DateTime.fromMillisecondsSinceEpoch(expenseDate * 1000);
    final today = DateTime.fromMillisecondsSinceEpoch(currentTimestamp * 1000);
    return expenseDay.year == today.year &&
        expenseDay.month == today.month &&
        expenseDay.day == today.day;
  }

  /// Check if expense is in current month
  bool isThisMonth(int currentTimestamp) {
    final expenseMonth = DateTime.fromMillisecondsSinceEpoch(expenseDate * 1000);
    final currentMonth = DateTime.fromMillisecondsSinceEpoch(currentTimestamp * 1000);
    return expenseMonth.year == currentMonth.year &&
        expenseMonth.month == currentMonth.month;
  }

  /// Check if expense has attachment
  bool get hasAttachment => attachmentPath != null && attachmentPath!.isNotEmpty;

  /// Copy with method
  Expense copyWith({
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
    return Expense(
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

  @override
  List<Object?> get props => [
        id,
        businessId,
        title,
        description,
        amount,
        category,
        expenseDate,
        paymentMode,
        referenceNumber,
        attachmentPath,
        vendor,
        isRecurring,
        recurringFrequency,
        isDeleted,
        createdAt,
        updatedAt,
      ];
}
