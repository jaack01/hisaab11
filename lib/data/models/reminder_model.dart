import '../../domain/entities/reminder.dart';

/// Reminder model for database operations
class ReminderModel {
  final int? id;
  final int businessId;
  final int customerId;
  final String title;
  final String? message;
  final double amount;
  final int reminderDate;
  final String channel;
  final String status;
  final bool isRecurring;
  final String? recurringFrequency;
  final int? nextReminderDate;
  final int? lastSentDate;
  final int createdAt;
  final int updatedAt;

  const ReminderModel({
    this.id,
    required this.businessId,
    required this.customerId,
    required this.title,
    this.message,
    required this.amount,
    required this.reminderDate,
    this.channel = 'NOTIFICATION',
    this.status = 'PENDING',
    this.isRecurring = false,
    this.recurringFrequency,
    this.nextReminderDate,
    this.lastSentDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert model to entity
  Reminder toEntity() {
    return Reminder(
      id: id,
      businessId: businessId,
      customerId: customerId,
      title: title,
      message: message,
      amount: amount,
      reminderDate: reminderDate,
      channel: channel,
      status: status,
      isRecurring: isRecurring,
      recurringFrequency: recurringFrequency,
      nextReminderDate: nextReminderDate,
      lastSentDate: lastSentDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create model from entity
  factory ReminderModel.fromEntity(Reminder reminder) {
    return ReminderModel(
      id: reminder.id,
      businessId: reminder.businessId,
      customerId: reminder.customerId,
      title: reminder.title,
      message: reminder.message,
      amount: reminder.amount,
      reminderDate: reminder.reminderDate,
      channel: reminder.channel,
      status: reminder.status,
      isRecurring: reminder.isRecurring,
      recurringFrequency: reminder.recurringFrequency,
      nextReminderDate: reminder.nextReminderDate,
      lastSentDate: reminder.lastSentDate,
      createdAt: reminder.createdAt,
      updatedAt: reminder.updatedAt,
    );
  }

  /// Convert from database map
  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] as int?,
      businessId: map['business_id'] as int,
      customerId: map['customer_id'] as int,
      title: map['title'] as String,
      message: map['message'] as String?,
      amount: (map['amount'] as num).toDouble(),
      reminderDate: map['reminder_date'] as int,
      channel: map['channel'] as String,
      status: map['status'] as String,
      isRecurring: (map['is_recurring'] as int) == 1,
      recurringFrequency: map['recurring_frequency'] as String?,
      nextReminderDate: map['next_reminder_date'] as int?,
      lastSentDate: map['last_sent_date'] as int?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'business_id': businessId,
      'customer_id': customerId,
      'title': title,
      'message': message,
      'amount': amount,
      'reminder_date': reminderDate,
      'channel': channel,
      'status': status,
      'is_recurring': isRecurring ? 1 : 0,
      'recurring_frequency': recurringFrequency,
      'next_reminder_date': nextReminderDate,
      'last_sent_date': lastSentDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with method
  ReminderModel copyWith({
    int? id,
    int? businessId,
    int? customerId,
    String? title,
    String? message,
    double? amount,
    int? reminderDate,
    String? channel,
    String? status,
    bool? isRecurring,
    String? recurringFrequency,
    int? nextReminderDate,
    int? lastSentDate,
    int? createdAt,
    int? updatedAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      title: title ?? this.title,
      message: message ?? this.message,
      amount: amount ?? this.amount,
      reminderDate: reminderDate ?? this.reminderDate,
      channel: channel ?? this.channel,
      status: status ?? this.status,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringFrequency: recurringFrequency ?? this.recurringFrequency,
      nextReminderDate: nextReminderDate ?? this.nextReminderDate,
      lastSentDate: lastSentDate ?? this.lastSentDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
