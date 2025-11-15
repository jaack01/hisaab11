import 'package:equatable/equatable.dart';

/// Reminder entity for payment reminders
class Reminder extends Equatable {
  final int? id;
  final int businessId;
  final int customerId;
  final String title;
  final String? message;
  final double amount;
  final int reminderDate;
  final String channel; // SMS, WHATSAPP, NOTIFICATION
  final String status; // PENDING, SENT, CANCELLED
  final bool isRecurring;
  final String? recurringFrequency; // DAILY, WEEKLY, MONTHLY
  final int? nextReminderDate;
  final int? lastSentDate;
  final int createdAt;
  final int updatedAt;

  const Reminder({
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

  /// Check if reminder is pending
  bool get isPending => status == 'PENDING';

  /// Check if reminder is sent
  bool get isSent => status == 'SENT';

  /// Check if reminder is cancelled
  bool get isCancelled => status == 'CANCELLED';

  /// Check if reminder is overdue
  bool isOverdue(int currentTimestamp) {
    return isPending && reminderDate < currentTimestamp;
  }

  /// Check if reminder is due today
  bool isDueToday(int currentTimestamp) {
    final reminderDay = DateTime.fromMillisecondsSinceEpoch(reminderDate * 1000);
    final today = DateTime.fromMillisecondsSinceEpoch(currentTimestamp * 1000);
    return reminderDay.year == today.year &&
        reminderDay.month == today.month &&
        reminderDay.day == today.day;
  }

  /// Check if reminder is for WhatsApp
  bool get isWhatsApp => channel == 'WHATSAPP';

  /// Check if reminder is for SMS
  bool get isSms => channel == 'SMS';

  /// Check if reminder is for notification
  bool get isNotification => channel == 'NOTIFICATION';

  /// Copy with method
  Reminder copyWith({
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
    return Reminder(
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

  @override
  List<Object?> get props => [
        id,
        businessId,
        customerId,
        title,
        message,
        amount,
        reminderDate,
        channel,
        status,
        isRecurring,
        recurringFrequency,
        nextReminderDate,
        lastSentDate,
        createdAt,
        updatedAt,
      ];
}
