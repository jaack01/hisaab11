/// Database table and column name constants
class DbConstants {
  // Private constructor
  DbConstants._();

  // ========== TABLE NAMES ==========
  static const String tableBusinesses = 'businesses';
  static const String tableCustomers = 'customers';
  static const String tableTransactions = 'transactions';
  static const String tableItems = 'items';
  static const String tableInvoices = 'invoices';
  static const String tableInvoiceItems = 'invoice_items';
  static const String tableReminders = 'reminders';
  static const String tableExpenses = 'expenses';
  static const String tablePayments = 'payments';
  static const String tableSettings = 'settings';
  static const String tableBackupLog = 'backup_log';
  static const String tableReportsCache = 'reports_cache';

  // ========== VIEW NAMES ==========
  static const String viewCustomerSummary = 'v_customer_summary';
  static const String viewRecentTransactions = 'v_recent_transactions';
  static const String viewPendingInvoices = 'v_pending_invoices';
  static const String viewBusinessSummary = 'v_business_summary';

  // ========== BUSINESSES TABLE COLUMNS ==========
  static const String colBusinessId = 'id';
  static const String colBusinessName = 'name';
  static const String colBusinessOwnerName = 'owner_name';
  static const String colBusinessPhone = 'phone';
  static const String colBusinessEmail = 'email';
  static const String colBusinessAddress = 'address';
  static const String colBusinessGstin = 'gstin';
  static const String colBusinessPan = 'pan';
  static const String colBusinessLogoPath = 'logo_path';
  static const String colBusinessCurrencySymbol = 'currency_symbol';
  static const String colBusinessIsDefault = 'is_default';
  static const String colBusinessIsActive = 'is_active';
  static const String colBusinessCreatedAt = 'created_at';
  static const String colBusinessUpdatedAt = 'updated_at';

  // ========== CUSTOMERS TABLE COLUMNS ==========
  static const String colCustomerId = 'id';
  static const String colCustomerBusinessId = 'business_id';
  static const String colCustomerName = 'name';
  static const String colCustomerPhone = 'phone';
  static const String colCustomerEmail = 'email';
  static const String colCustomerAddress = 'address';
  static const String colCustomerGstin = 'gstin';
  static const String colCustomerPan = 'pan';
  static const String colCustomerOpeningBalance = 'opening_balance';
  static const String colCustomerOpeningBalanceType = 'opening_balance_type';
  static const String colCustomerCurrentBalance = 'current_balance';
  static const String colCustomerProfileImagePath = 'profile_image_path';
  static const String colCustomerNotes = 'notes';
  static const String colCustomerIsActive = 'is_active';
  static const String colCustomerCreatedAt = 'created_at';
  static const String colCustomerUpdatedAt = 'updated_at';

  // ========== TRANSACTIONS TABLE COLUMNS ==========
  static const String colTransactionId = 'id';
  static const String colTransactionBusinessId = 'business_id';
  static const String colTransactionCustomerId = 'customer_id';
  static const String colTransactionType = 'transaction_type';
  static const String colTransactionAmount = 'amount';
  static const String colTransactionDescription = 'description';
  static const String colTransactionDate = 'transaction_date';
  static const String colTransactionAttachmentPath = 'attachment_path';
  static const String colTransactionPaymentMode = 'payment_mode';
  static const String colTransactionReferenceNumber = 'reference_number';
  static const String colTransactionIsDeleted = 'is_deleted';
  static const String colTransactionCreatedAt = 'created_at';
  static const String colTransactionUpdatedAt = 'updated_at';

  // ========== ITEMS TABLE COLUMNS ==========
  static const String colItemId = 'id';
  static const String colItemBusinessId = 'business_id';
  static const String colItemName = 'name';
  static const String colItemDescription = 'description';
  static const String colItemSku = 'sku';
  static const String colItemHsnCode = 'hsn_code';
  static const String colItemUnit = 'unit';
  static const String colItemSalePrice = 'sale_price';
  static const String colItemPurchasePrice = 'purchase_price';
  static const String colItemTaxRate = 'tax_rate';
  static const String colItemStockQuantity = 'stock_quantity';
  static const String colItemLowStockThreshold = 'low_stock_threshold';
  static const String colItemImagePath = 'image_path';
  static const String colItemCategory = 'category';
  static const String colItemIsActive = 'is_active';
  static const String colItemCreatedAt = 'created_at';
  static const String colItemUpdatedAt = 'updated_at';

  // ========== INVOICES TABLE COLUMNS ==========
  static const String colInvoiceId = 'id';
  static const String colInvoiceBusinessId = 'business_id';
  static const String colInvoiceNumber = 'invoice_number';
  static const String colInvoiceCustomerId = 'customer_id';
  static const String colInvoiceDate = 'invoice_date';
  static const String colInvoiceDueDate = 'due_date';
  static const String colInvoiceSubtotal = 'subtotal';
  static const String colInvoiceDiscountPercentage = 'discount_percentage';
  static const String colInvoiceDiscountAmount = 'discount_amount';
  static const String colInvoiceTaxAmount = 'tax_amount';
  static const String colInvoiceTotalAmount = 'total_amount';
  static const String colInvoicePaidAmount = 'paid_amount';
  static const String colInvoiceBalanceAmount = 'balance_amount';
  static const String colInvoiceStatus = 'status';
  static const String colInvoicePaymentTerms = 'payment_terms';
  static const String colInvoiceNotes = 'notes';
  static const String colInvoiceTermsConditions = 'terms_conditions';
  static const String colInvoiceIsGstInvoice = 'is_gst_invoice';
  static const String colInvoiceTransactionId = 'transaction_id';
  static const String colInvoiceIsDeleted = 'is_deleted';
  static const String colInvoiceCreatedAt = 'created_at';
  static const String colInvoiceUpdatedAt = 'updated_at';

  // ========== INVOICE_ITEMS TABLE COLUMNS ==========
  static const String colInvoiceItemId = 'id';
  static const String colInvoiceItemInvoiceId = 'invoice_id';
  static const String colInvoiceItemItemId = 'item_id';
  static const String colInvoiceItemName = 'item_name';
  static const String colInvoiceItemDescription = 'description';
  static const String colInvoiceItemHsnCode = 'hsn_code';
  static const String colInvoiceItemQuantity = 'quantity';
  static const String colInvoiceItemUnit = 'unit';
  static const String colInvoiceItemRate = 'rate';
  static const String colInvoiceItemDiscountPercentage = 'discount_percentage';
  static const String colInvoiceItemDiscountAmount = 'discount_amount';
  static const String colInvoiceItemTaxableAmount = 'taxable_amount';
  static const String colInvoiceItemTaxRate = 'tax_rate';
  static const String colInvoiceItemTaxAmount = 'tax_amount';
  static const String colInvoiceItemTotalAmount = 'total_amount';
  static const String colInvoiceItemCreatedAt = 'created_at';

  // ========== REMINDERS TABLE COLUMNS ==========
  static const String colReminderId = 'id';
  static const String colReminderBusinessId = 'business_id';
  static const String colReminderCustomerId = 'customer_id';
  static const String colReminderType = 'reminder_type';
  static const String colReminderDate = 'reminder_date';
  static const String colReminderTime = 'reminder_time';
  static const String colReminderMessage = 'message';
  static const String colReminderChannel = 'channel';
  static const String colReminderIsSent = 'is_sent';
  static const String colReminderSentAt = 'sent_at';
  static const String colReminderIsRecurring = 'is_recurring';
  static const String colReminderRecurrencePattern = 'recurrence_pattern';
  static const String colReminderNextReminderDate = 'next_reminder_date';
  static const String colReminderCreatedAt = 'created_at';
  static const String colReminderUpdatedAt = 'updated_at';

  // ========== EXPENSES TABLE COLUMNS ==========
  static const String colExpenseId = 'id';
  static const String colExpenseBusinessId = 'business_id';
  static const String colExpenseCategory = 'category';
  static const String colExpenseAmount = 'amount';
  static const String colExpenseDescription = 'description';
  static const String colExpenseDate = 'expense_date';
  static const String colExpensePaymentMode = 'payment_mode';
  static const String colExpenseVendorName = 'vendor_name';
  static const String colExpenseAttachmentPath = 'attachment_path';
  static const String colExpenseIsRecurring = 'is_recurring';
  static const String colExpenseRecurrencePattern = 'recurrence_pattern';
  static const String colExpenseIsDeleted = 'is_deleted';
  static const String colExpenseCreatedAt = 'created_at';
  static const String colExpenseUpdatedAt = 'updated_at';

  // ========== PAYMENTS TABLE COLUMNS ==========
  static const String colPaymentId = 'id';
  static const String colPaymentBusinessId = 'business_id';
  static const String colPaymentCustomerId = 'customer_id';
  static const String colPaymentInvoiceId = 'invoice_id';
  static const String colPaymentAmount = 'amount';
  static const String colPaymentDate = 'payment_date';
  static const String colPaymentMode = 'payment_mode';
  static const String colPaymentReferenceNumber = 'reference_number';
  static const String colPaymentNotes = 'notes';
  static const String colPaymentTransactionId = 'transaction_id';
  static const String colPaymentIsDeleted = 'is_deleted';
  static const String colPaymentCreatedAt = 'created_at';
  static const String colPaymentUpdatedAt = 'updated_at';

  // ========== SETTINGS TABLE COLUMNS ==========
  static const String colSettingId = 'id';
  static const String colSettingBusinessId = 'business_id';
  static const String colSettingKey = 'key';
  static const String colSettingValue = 'value';
  static const String colSettingDataType = 'data_type';
  static const String colSettingUpdatedAt = 'updated_at';

  // ========== BACKUP_LOG TABLE COLUMNS ==========
  static const String colBackupId = 'id';
  static const String colBackupPath = 'backup_path';
  static const String colBackupSize = 'backup_size';
  static const String colBackupType = 'backup_type';
  static const String colBackupStatus = 'status';
  static const String colBackupErrorMessage = 'error_message';
  static const String colBackupCreatedAt = 'created_at';

  // ========== REPORTS_CACHE TABLE COLUMNS ==========
  static const String colReportCacheId = 'id';
  static const String colReportCacheBusinessId = 'business_id';
  static const String colReportCacheType = 'report_type';
  static const String colReportCacheParams = 'report_params';
  static const String colReportCacheFilePath = 'file_path';
  static const String colReportCacheGeneratedAt = 'generated_at';
  static const String colReportCacheExpiresAt = 'expires_at';

  // ========== COMMON COLUMNS ==========
  static const String colId = 'id';
  static const String colCreatedAt = 'created_at';
  static const String colUpdatedAt = 'updated_at';
  static const String colIsActive = 'is_active';
  static const String colIsDeleted = 'is_deleted';

  // ========== QUERY HELPERS ==========
  static const String orderByDesc = 'DESC';
  static const String orderByAsc = 'ASC';
  static const String whereEquals = '= ?';
  static const String whereIn = 'IN (?)';
  static const String whereLike = 'LIKE ?';
  static const String whereGreaterThan = '> ?';
  static const String whereLessThan = '< ?';
  static const String whereGreaterThanOrEqual = '>= ?';
  static const String whereLessThanOrEqual = '<= ?';
  static const String whereBetween = 'BETWEEN ? AND ?';
  static const String whereNotEqual = '!= ?';
  static const String whereIsNull = 'IS NULL';
  static const String whereIsNotNull = 'IS NOT NULL';
}
