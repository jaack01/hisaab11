/// Application-wide constants
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // App Information
  static const String appName = 'Hisaab';
  static const String appTagline = 'Digital Khata Book';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'hisaab.db';
  static const int databaseVersion = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date Formats
  static const String defaultDateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy hh:mm a';
  static const String timeFormat = 'hh:mm a';
  static const String monthYearFormat = 'MMMM yyyy';
  static const String reportDateFormat = 'dd-MM-yyyy';

  // Currency
  static const String defaultCurrencySymbol = '₹';
  static const String defaultCurrencyCode = 'INR';
  static const int currencyDecimalPlaces = 2;

  // Languages
  static const String defaultLanguage = 'en';
  static const List<String> supportedLanguages = ['en', 'hi'];

  // Validation
  static const int minPhoneNumberLength = 10;
  static const int maxPhoneNumberLength = 15;
  static const int minCustomerNameLength = 2;
  static const int maxCustomerNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const double minTransactionAmount = 0.01;
  static const double maxTransactionAmount = 99999999.99;

  // PIN Security
  static const int pinLength = 4;
  static const int maxPinAttempts = 3;
  static const int pinLockoutDuration = 300; // 5 minutes in seconds

  // Backup
  static const String backupFileExtension = '.backup';
  static const String backupFolderName = 'Hisaab_Backups';
  static const int maxBackupFiles = 10;
  static const int autoBackupIntervalDays = 1;

  // Cache
  static const int reportCacheExpiryHours = 24;
  static const int imageCacheSizeMB = 100;

  // Limits
  static const int maxCustomersPerBusiness = 10000;
  static const int maxTransactionsPerCustomer = 100000;
  static const int maxInvoiceItemsPerInvoice = 100;
  static const int maxBusinessBooks = 10;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double cardElevation = 2.0;
  static const double dialogElevation = 8.0;
  static const double borderRadius = 8.0;
  static const double cardBorderRadius = 12.0;

  // Animation Durations
  static const int defaultAnimationDuration = 300; // milliseconds
  static const int fastAnimationDuration = 150;
  static const int slowAnimationDuration = 500;

  // Snackbar
  static const int snackbarDuration = 3; // seconds
  static const int errorSnackbarDuration = 5;

  // PDF
  static const String pdfDateFormat = 'dd-MM-yyyy';
  static const double pdfPageMargin = 40.0;
  static const String defaultPdfFontFamily = 'Helvetica';

  // Invoice
  static const String invoiceNumberPrefix = 'INV';
  static const int invoiceNumberLength = 6; // INV000001
  static const int defaultPaymentTermsDays = 30;

  // Stock Alert
  static const double defaultLowStockThreshold = 10.0;

  // WhatsApp
  static const String whatsappBaseUrl = 'https://wa.me/';
  static const String whatsappBusinessUrl = 'https://api.whatsapp.com/send';

  // SMS
  static const String smsScheme = 'sms:';

  // Email
  static const String emailScheme = 'mailto:';
  static const String supportEmail = 'support@hisaab.com';

  // Regex Patterns
  static const String phoneNumberPattern = r'^[0-9]{10,15}$';
  static const String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String gstinPattern =
      r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$';
  static const String panPattern = r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$';
  static const String numberOnlyPattern = r'^[0-9]+$';
  static const String alphaNumericPattern = r'^[a-zA-Z0-9]+$';

  // Error Messages
  static const String genericErrorMessage =
      'Something went wrong. Please try again.';
  static const String networkErrorMessage =
      'No internet connection. Please check your network.';
  static const String databaseErrorMessage =
      'Database error occurred. Please try again.';
  static const String validationErrorMessage = 'Please check your input.';

  // Success Messages
  static const String saveSuccessMessage = 'Saved successfully';
  static const String updateSuccessMessage = 'Updated successfully';
  static const String deleteSuccessMessage = 'Deleted successfully';
  static const String backupSuccessMessage = 'Backup created successfully';
  static const String restoreSuccessMessage = 'Data restored successfully';

  // Settings Keys
  static const String settingsKeyLanguage = 'app_language';
  static const String settingsKeyCurrency = 'currency_symbol';
  static const String settingsKeyDateFormat = 'date_format';
  static const String settingsKeyThemeMode = 'theme_mode';
  static const String settingsKeyPinEnabled = 'enable_pin_lock';
  static const String settingsKeyBiometricEnabled = 'enable_biometric';
  static const String settingsKeyAutoBackup = 'auto_backup_enabled';
  static const String settingsKeyBackupFrequency = 'backup_frequency';
  static const String settingsKeyNotifications = 'notification_enabled';
  static const String settingsKeyFirstTimeSetup = 'first_time_setup_completed';
  static const String settingsKeyDefaultBusinessId = 'default_business_id';

  // Transaction Types
  static const String transactionTypeCredit = 'CREDIT'; // You Gave
  static const String transactionTypeDebit = 'DEBIT'; // You Got

  // Payment Modes
  static const List<String> paymentModes = [
    'CASH',
    'UPI',
    'CARD',
    'CHEQUE',
    'BANK_TRANSFER',
    'OTHER',
  ];

  // Invoice Status
  static const String invoiceStatusPaid = 'PAID';
  static const String invoiceStatusUnpaid = 'UNPAID';
  static const String invoiceStatusPartial = 'PARTIAL';
  static const String invoiceStatusCancelled = 'CANCELLED';

  // Expense Categories
  static const List<String> expenseCategories = [
    'RENT',
    'SALARY',
    'ELECTRICITY',
    'WATER',
    'INTERNET',
    'PHONE',
    'TRANSPORTATION',
    'OFFICE_SUPPLIES',
    'MAINTENANCE',
    'MARKETING',
    'INSURANCE',
    'TAXES',
    'OTHER',
  ];

  // Item Units
  static const List<String> itemUnits = [
    'PCS',
    'KG',
    'GM',
    'LITER',
    'ML',
    'METER',
    'CM',
    'BOX',
    'PACKET',
    'DOZEN',
    'OTHER',
  ];

  // GST Rates (India)
  static const List<double> gstRates = [0, 5, 12, 18, 28];

  // Reminder Channels
  static const String reminderChannelWhatsapp = 'WHATSAPP';
  static const String reminderChannelSMS = 'SMS';
  static const String reminderChannelBoth = 'BOTH';

  // Reminder Types
  static const String reminderTypePayment = 'PAYMENT';
  static const String reminderTypeFollowup = 'FOLLOWUP';
  static const String reminderTypeCustom = 'CUSTOM';

  // Report Types
  static const String reportTypeLedger = 'LEDGER';
  static const String reportTypeProfitLoss = 'PROFIT_LOSS';
  static const String reportTypeBalanceSheet = 'BALANCE_SHEET';
  static const String reportTypeDaybook = 'DAYBOOK';
  static const String reportTypeSales = 'SALES';
  static const String reportTypePurchase = 'PURCHASE';
  static const String reportTypeExpense = 'EXPENSE';
  static const String reportTypeItemWise = 'ITEM_WISE';

  // Theme Modes
  static const String themeModeLight = 'LIGHT';
  static const String themeModeDark = 'DARK';
  static const String themeModeSystem = 'SYSTEM';

  // Backup Frequency
  static const String backupFrequencyDaily = 'DAILY';
  static const String backupFrequencyWeekly = 'WEEKLY';
  static const String backupFrequencyMonthly = 'MONTHLY';
  static const String backupFrequencyManual = 'MANUAL';

  // Recurrence Patterns
  static const String recurrenceDaily = 'DAILY';
  static const String recurrenceWeekly = 'WEEKLY';
  static const String recurrenceMonthly = 'MONTHLY';
  static const String recurrenceYearly = 'YEARLY';
}
